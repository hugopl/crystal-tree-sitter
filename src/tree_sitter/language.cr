require "semantic_version"

module TreeSitter
  # A `Language` defines how to parse a particular programming language. The code for each `Language`
  # is generated by Tree-sitter. Many languages are already available in separate git repositories
  # within the the [Tree-sitter GitHub organization](https://github.com/tree-sitter).
  class Language
    @lang : LibTreeSitter::TSLanguage
    protected class_property loaded_languages = Hash(LibTreeSitter::TSLanguage, Language).new

    @@loaded_languages = Hash(LibTreeSitter::TSLanguage, Language).new

    # :nodoc:
    def self.new(ptr : LibTreeSitter::TSLanguage)
      @@loaded_languages[ptr]? || raise Error.new("Language not initiated.")
    end

    protected def initialize(@lang)
    end

    # Get the number of distinct node types in the language.
    def symbol_count : UInt32
      LibTreeSitter.ts_language_symbol_count(to_unsafe)
    end

    # Get the number of distinct field names in the language.
    def field_count : UInt32
      LibTreeSitter.ts_language_field_count(to_unsafe)
    end

    # LibTreeSitter.ts_language_symbol_name(to_unsafe, symbol : TSSymbol) : LibC::Char*
    # LibTreeSitter.ts_language_symbol_for_name(to_unsafe, name : LibC::Char*, name_length : UInt32, is_named : Bool) : TSSymbol
    # LibTreeSitter.ts_language_field_name_for_id(to_unsafe, field_id : TSFieldId) : LibC::Char*
    # LibTreeSitter.ts_language_field_id_for_name(to_unsafe, name : LibC::Char*, name_length : UInt32) : TSFieldId
    # LibTreeSitter.ts_language_symbol_type(to_unsafe, symbol : TSSymbol) : TSSymbolType

    # Get the ABI version number for this language. This version number is used
    # to ensure that languages were generated by a compatible version of
    # Tree-sitter.
    #
    # See also `Parser#language=`.
    def version : UInt32
      LibTreeSitter.ts_language_version(to_unsafe)
    end

    def self.detect(filename : String) : Language?
      {% for lang in @type.all_subclasses %}
        return {{ lang.id }}.new if {{ lang.id }}.match?(filename)
      {% end %}
    end

    def self.match?(str) : Bool
      false
    end

    def name : String
      raise NotImplementedError.new(nil)
    end

    def version : SemanticVersion
      raise NotImplementedError.new(nil)
    end

    def file_types : Array(String)
      Array(String).new
    end

    def injection_regex : Regex?
      nil
    end

    def highlight_query? : Query?
      nil
    end

    def highlight_query : Query
      highlight_query?.not_nil!
    end

    # :nodoc:
    def to_unsafe
      @lang
    end
  end
end
