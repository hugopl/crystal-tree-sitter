{% skip_file if flag?(:docs) %}

require "colorize"
require "json"
require "semantic_version"

class Package
  include JSON::Serializable

  class TreeSitter
    include JSON::Serializable

    @[JSON::Field(key: "file-types")]
    getter file_types : Array(String)?

    @[JSON::Field(key: "injection-regex")]
    getter injection_regex : String?
  end

  getter version : String

  @[JSON::Field(key: "tree-sitter")]
  getter tree_sitter : Array(TreeSitter)?
end

struct Parser
  getter name : String
  getter title : String
  getter dir : Path
  getter version : SemanticVersion
  getter file_types : Array(String)?
  getter injection_regex : String?
  getter highlight_query : String?

  def initialize(@name, @title, dir)
    @dir = dir.expand

    package_json_path = @dir.join("package.json")
    pkg = Package.from_json(File.read(package_json_path))
    @version = SemanticVersion.parse(pkg.version)
    @file_types = pkg.tree_sitter.try(&.first.file_types)
    @injection_regex = pkg.tree_sitter.try(&.first.injection_regex)

    highlights_path = @dir.join("queries/highlights.scm")
    @highlight_query = File.read(highlights_path) if File.exists?(highlights_path)
  end
end

def compile_binding(parser : Parser)
  c_compiler = ENV["CC"]? || "cc"
  built_obj = parser.dir.join("parser.o")
  built_lib = parser.dir.join("libtree-sitter-#{parser.name}.a")

  # FIXME: Check if the .c file is newer than the .o.
  return if File.exists?(built_lib)

  source = parser.dir.join("src", "parser.c")
  cmd = "#{c_compiler} -c -o #{built_obj} #{source} && ar rcs #{built_lib} #{built_obj} && rm #{built_obj}"
  puts "{% puts #{cmd.inspect} %}"
  `#{cmd}`
  abort("Failed to compile #{source} using:\n#{cmd}") unless $?.success?
end

def generate_lib_declaration(parser : Parser)
  puts <<-EOT
  @[Link(lib: "tree-sitter-#{parser.name}", ldflags: "-L#{parser.dir}")]
  lib LibTreeSitter#{parser.title}
    fun tree_sitter_#{parser.name} : LibTreeSitter::TSLanguage
  end
  EOT
end

def generate_module(parser : Parser)
  # FIXME: This is a crystal stdlib bug
  prerelease = parser.version.prerelease unless parser.version.prerelease.to_s.empty?

  puts <<-EOT
  class #{parser.title}Language < Language
    def initialize
      @lang = LibTreeSitter#{parser.title}.tree_sitter_#{parser.name}
      Language.loaded_languages[@lang] = self
    end

    def self.new
      ptr = LibTreeSitter#{parser.title}.tree_sitter_#{parser.name}
      Language.loaded_languages[ptr] ||= begin
        instance = #{parser.title}Language.allocate
        instance.initialize
        instance
      end
    end

    def name
      #{parser.title.inspect}
    end

    def version : SemanticVersion
      SemanticVersion.new(#{parser.version.major}, #{parser.version.minor}, #{parser.version.patch},
                          #{prerelease.inspect}, #{parser.version.build.inspect})
    end
  EOT

  file_types = parser.file_types

  if file_types
    match_code = file_types.map { |ext| "filename.ends_with?(\".#{ext}\")" }.join(" || ")
    puts <<-EOT
      def self.match?(filename : String) : Bool
        #{match_code}
      end
    EOT
  end

  if parser.highlight_query
    puts <<-EOT
      def highlight_query : Query?
        Query.new(self, #{parser.highlight_query.inspect})
      end
    EOT
  end

  puts <<-EOT
  end
  EOT
end

def generate_parsers_enum(parsers : Array(Parser))
  print "LANGUAGE_NAMES = {"
  print parsers.map(&.title.inspect).join(", ")
  puts "}"
end

def find_parsers(args) : Array(Parser)
  args.map do |arg|
    sub_args = arg.split(':', 2)
    name = sub_args[0]
    title = sub_args[1]?
    name, dir = if Dir.exists?(name)
                  path = Path.new(name)
                  {path.basename.gsub(/\Atree\-sitter\-/, ""), path}
                else
                  {name, Path.new("parsers/tree-sitter-#{name}")}
                end
    title ||= name.titleize
    Parser.new(name, title, dir)
  end
end

def main
  args = ARGV.size == 1 ? ARGV.first.split(' ') : ARGV
  parsers = find_parsers(args)
  parsers.each do |parser|
    compile_binding(parser)
    generate_lib_declaration(parser)
  end

  puts "module TreeSitter"
  generate_parsers_enum(parsers)
  parsers.each do |parser|
    generate_module(parser)
  end
  puts "end"
end

main
