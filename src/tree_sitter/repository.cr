require "colorize"
require "./config"
require "./language"

module TreeSitter
  class Repository
    @@language_paths : Hash(String, Path)?

    def self.language_paths : Hash(String, Path)
      @@language_paths ||= begin
        languages = Hash(String, Path).new
        Config.parser_directories.each do |dir|
          Dir[dir.join("**", "src", "grammar.json")].each do |grammar_path|
            languages[$2] = Path.new($1) if grammar_path =~ %r{(.*/tree\-sitter\-([\w\-_]+))/src/grammar.json\z}
          end
        end
        languages
      end
    end

    def self.preload_all
      language_paths.each_key { |name| load_language?(name) }
    end

    def self.language_names : Array(String)
      language_paths.keys
    end

    def self.load_language(name : String) : Language
      lang_path = language_paths[name]?
      raise Error.new("Unknown language: #{name}.") if lang_path.nil?

      ts_lang = load_shared_object(lang_path, name)
      Language.new(name, ts_lang)
    end

    def self.load_language?(name : String) : Language?
      load_language(name)
    rescue Error
      nil
    end

    def self.load_shared_object(path : Path, name : String) : LibTreeSitter::TSLanguage
      so_path = path.join("src", "#{name}.so")
      raise Error.new("#{so_path} doesn't exists.") unless File.exists?(so_path)

      handle = LibC.dlopen(so_path.to_s, LibC::RTLD_LAZY | LibC::RTLD_LOCAL)
      raise Error.new("Can't load language #{name}. #{so_path} was not found.") if handle.null?

      ptr = LibC.dlsym(handle, "tree_sitter_#{name}")
      raise Error.new("Can't find symbol tree_sitter_#{name} at #{so_path}.") unless ptr

      Proc(LibTreeSitter::TSLanguage).new(ptr, Pointer(Void).null).call
    end
  end
end

TreeSitter::Repository.load_language?("ruby")
