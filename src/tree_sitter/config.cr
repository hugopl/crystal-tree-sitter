require "json"

module TreeSitter
  class Config
    include JSON::Serializable

    @[JSON::Field(key: "parser-directories")]
    property parser_directories : Array(Path)

    @@current : Config?

    def self.current : Config
      @@current ||= load_config
    end

    def self.parser_directories
      current.parser_directories
    end

    private def self.load_config : Config
      path = ENV["XDG_CONFIG_HOME"]? || Path.home.join(".config")
      path = Path.new(path)

      File.open(path.join("tree-sitter", "config.json")) do |fp|
        Config.from_json(fp)
      end
    end
  end
end
