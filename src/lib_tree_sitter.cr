@[Link("tree-sitter", pkg_config: "tree-sitter")]
lib LibTreeSitter
  type TSSymbol = UInt16
  type TSFieldId = UInt16
  type TSLanguage = Void*
  type TSParser = Void*
  type TSTree = Void*
  type TSQuery = Void*
  type TSQueryCursor = Void*

  enum TSInputEncoding
    UTF8
    UTF16
  end

  struct TSNode
    context : UInt32[4]
    id : Void*
    tree : TSTree
  end

  struct TSPoint
    # TreeSitter API uses unsigned integers here, to avoid habing a lot of uint/int casts
    # we just consider that people are good and don't have files with 2 billions+ of rows or
    # columns
    row : Int32
    column : Int32
  end

  struct TSRange
    start_point : TSPoint
    end_point : TSPoint
    start_byte : UInt32
    end_byte : UInt32
  end

  struct TSInput
    payload : Void*
    read : Void*, UInt32, TSPoint, UInt32* -> LibC::Char*
    encoding : TSInputEncoding
  end

  struct TSQueryCapture
    node : TSNode
    index : UInt32
  end

  struct TSQueryMatch
    id : UInt32
    pattern_index : UInt16
    capture_count : UInt16
    captures : TSQueryCapture*
  end

  enum TSQueryPredicateStepType
    Done
    Capture
    String
  end

  struct TSQueryPredicateStep
    type : TSQueryPredicateStepType
    value_id : UInt32
  end

  enum TSQueryError
    None      = 0
    Syntax
    NodeType
    Field
    Capture
    Structure
    Language
  end

  # Parser
  fun ts_parser_new : TSParser
  fun ts_parser_delete(parser : TSParser)
  fun ts_parser_set_language(self : TSParser, language : TSLanguage) : Bool
  fun ts_parser_language(self : TSParser) : TSLanguage

  fun ts_parser_parse(self : TSParser, old_tree : TSTree, input : TSInput) : TSTree
  fun ts_parser_parse_string(self : TSParser, old_tree : TSTree, string : LibC::Char*, length : UInt32) : TSTree
  fun ts_parser_parse_string_encoding(self : TSParser, old_tree : TSTree, string : LibC::Char*, length : UInt32, encoding : Int32) : TSTree

  fun ts_parser_reset(self : TSParser)
  fun ts_parser_print_dot_graphs(self : TSParser, fd : Int32)
  # Language
  fun ts_language_symbol_count(self : TSLanguage) : UInt32
  fun ts_language_symbol_name(self : TSLanguage, symbol : TSSymbol) : LibC::Char*
  fun ts_language_symbol_for_name(self : TSLanguage, name : LibC::Char*, name_length : UInt32, is_named : Bool) : TSSymbol
  fun ts_language_field_count(self : TSLanguage) : UInt32
  fun ts_language_field_name_for_id(self : TSLanguage, field_id : TSFieldId) : LibC::Char*
  fun ts_language_field_id_for_name(self : TSLanguage, name : LibC::Char*, name_length : UInt32) : TSFieldId
  # fun ts_language_symbol_type(self : TSLanguage, symbol : TSSymbol) : TSSymbolType
  fun ts_language_version(self : TSLanguage) : UInt32

  # Tree
  fun ts_tree_copy(self : TSTree) : TSTree
  fun ts_tree_delete(self : TSTree)
  fun ts_tree_root_node(self : TSTree) : TSNode
  fun ts_tree_print_dot_graph(self : TSTree, file_descriptor : Int32)

  # Node
  fun ts_node_type(self : TSNode) : LibC::Char*
  fun ts_node_named_child(self : TSNode, index : UInt32) : TSNode
  fun ts_node_is_named(self : TSNode) : Bool
  fun ts_node_child_count(self : TSNode) : UInt32
  fun ts_node_named_child_count(self : TSNode) : UInt32
  fun ts_node_string(self : TSNode) : LibC::Char*
  fun ts_node_start_byte(self : TSNode) : UInt32
  fun ts_node_start_point(self : TSNode) : TSPoint
  fun ts_node_end_byte(self : TSNode) : UInt32
  fun ts_node_end_point(self : TSNode) : TSPoint
  fun ts_node_descendant_for_byte_range(self : TSNode, start_byte : UInt32, end_byte : UInt32) : TSNode
  fun ts_node_descendant_for_point_range(self : TSNode, start_point : TSPoint, end_point : TSPoint) : TSNode

  # Query
  fun ts_query_new(language : TSLanguage, source : LibC::Char*, source_len : UInt32,
                   error_offset : UInt32*, error_type : TSQueryError*) : TSQuery
  fun ts_query_delete(self : TSQuery)
  fun ts_query_predicates_for_pattern(self : TSQuery, pattern_index : UInt32, length : UInt32*) : TSQueryPredicateStep*
  fun ts_query_pattern_count(self : TSQuery) : UInt32
  fun ts_query_capture_count(self : TSQuery) : UInt32
  fun ts_query_string_count(self : TSQuery) : UInt32

  # QueryCursor
  fun ts_query_cursor_new : TSQueryCursor
  fun ts_query_cursor_delete(self : TSQueryCursor)
  fun ts_query_cursor_exec(self : TSQueryCursor, query : TSQuery, node : TSNode)
  fun ts_query_cursor_next_capture(self : TSQueryCursor, match : TSQueryMatch*, capture_index : UInt32*) : Bool
  fun ts_query_capture_name_for_id(self : TSQuery, id : UInt32, length : UInt32*) : LibC::Char*

  # Memory
  fun ts_set_allocator(new_malloc : (LibC::SizeT -> Void*),
                       new_calloc : (LibC::SizeT, LibC::SizeT -> Void*),
                       realloc : (Void*, LibC::SizeT -> Void*),
                       new_free : (Void* ->))
end
