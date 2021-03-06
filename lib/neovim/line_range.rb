module Neovim
  # Provide an enumerable interface for dealing with ranges of lines.
  class LineRange
    include Enumerable

    def initialize(buffer, _begin, _end)
      @buffer = buffer
      @begin = _begin
      @end = _end
    end

    # Resolve to an array of lines as strings.
    #
    # @return [Array<String>]
    def to_a
      @buffer.get_line_slice(@begin, @end, true, true)
    end

    # Yield each line in the range.
    #
    # @yield [String] The current line
    # @return [Array<String>]
    def each(&block)
      to_a.each(&block)
    end

    # Access the line at the given index within the range.
    #
    # @overload [](index)
    #   @param index [Integer]
    #
    # @overload [](range)
    #   @param range [Range]
    #
    # @overload [](index, length)
    #   @param index [Integer]
    #   @param length [Integer]
    #
    # @example Get the first line using an index
    #   line_range[0] # => "first"
    # @example Get the first two lines using a +Range+
    #   line_range[0..1] # => ["first", "second"]
    # @example Get the first two lines using an index and length
    #   line_range[0, 2] # => ["first", "second"]
    def [](pos, len=nil)
      case pos
      when Range
        LineRange.new(
          @buffer,
          abs_line(pos.begin),
          abs_line(pos.exclude_end? ? pos.end - 1 : pos.end)
        )
      else
        if len
          LineRange.new(
            @buffer,
            abs_line(pos),
            abs_line(pos + len - 1)
          )
        else
          @buffer.get_line(abs_line(pos))
        end
      end
    end
    alias_method :slice, :[]

    # Set the line at the given index within the range.
    #
    # @overload []=(index, string)
    #   @param index [Integer]
    #   @param string [String]
    #
    # @overload []=(index, length, strings)
    #   @param index [Integer]
    #   @param length [Integer]
    #   @param strings [Array<String>]
    #
    # @overload []=(range, strings)
    #   @param range [Range]
    #   @param strings [Array<String>]
    #
    # @example Replace the first line using an index
    #   line_range[0] = "first"
    # @example Replace the first two lines using a +Range+
    #   line_range[0..1] = ["first", "second"]
    # @example Replace the first two lines using an index and length
    #   line_range[0, 2] = ["first", "second"]
    def []=(*args)
      *target, val = args
      pos, len = target

      case pos
      when Range
        @buffer.set_line_slice(
          abs_line(pos.begin),
          abs_line(pos.end),
          true,
          !pos.exclude_end?,
          val
        )
      else
        if len
          @buffer.set_line_slice(
            abs_line(pos),
            abs_line(pos + len),
            true,
            false,
            val
          )
        else
          @buffer.set_line(abs_line(pos), val)
        end
      end
    end

    # Replace the range of lines.
    #
    # @param other [Array] The replacement lines
    def replace(other)
      self[0..-1] = other
      self
    end

    # Insert line(s) at the given index within the range.
    #
    # @param index [Integer]
    # @param lines [String]
    def insert(index, lines)
      @buffer.insert(index, Array(lines))
    end

    # Delete the line at the given index within the range.
    #
    # @param index [Integer]
    def delete(index)
      @buffer.del_line(abs_line(index))
    end

    private

    def abs_line(n)
      n < 0 ? (@end + n + 1) : @begin + n
    end
  end
end
