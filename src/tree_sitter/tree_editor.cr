module TreeSitter
  # Edit the syntax tree to keep it in sync with source code that has been
  # edited.
  #
  # You must provide a callback to transform `Point` coordinates into byte offsets and
  # byte offsets into `Point`.
  class TreeEditor
    @point_to_offset_callback : Proc(Int32, Int32, UInt32)
    @offset_to_point_callback : Proc(UInt32, Point)
    property tree : Tree

    def initialize(@tree, @point_to_offset_callback, @offset_to_point_callback)
    end

    # Edit the syntax tree at *line* and *column*, adding *n_bytes*.
    def insert(line : Int32, column : Int32, n_bytes : Int32)
      start_byte = @point_to_offset_callback.call(line, column)
      end_byte = start_byte + n_bytes

      edit = LibTreeSitter::TSInputEdit.new(
        start_byte: start_byte,
        old_end_byte: start_byte,
        new_end_byte: end_byte,
        start_point: LibTreeSitter::TSPoint.new(row: line, column: column),
        old_end_point: LibTreeSitter::TSPoint.new(row: line, column: column),
        new_end_point: @offset_to_point_callback.call(end_byte),
      )
      LibTreeSitter.ts_tree_edit(@tree, pointerof(edit))
    end

    # Edit the syntax tree at *line* and *column*, removing *n_bytes*.
    def delete(line : Int32, column : Int32, n_bytes : Int32)
      start_byte = @point_to_offset_callback.call(line, column)
      end_byte = start_byte + n_bytes

      edit = LibTreeSitter::TSInputEdit.new(
        start_byte: start_byte,
        old_end_byte: end_byte,
        new_end_byte: start_byte,
        start_point: LibTreeSitter::TSPoint.new(row: line, column: column),
        old_end_point: @offset_to_point_callback.call(end_byte),
        new_end_point: LibTreeSitter::TSPoint.new(row: line, column: column),
      )
      LibTreeSitter.ts_tree_edit(@tree, pointerof(edit))
    end
  end
end
