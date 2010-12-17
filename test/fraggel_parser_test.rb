require 'test/unit'
require 'stringio'
require 'fraggel'

class FraggelParserTest < Test::Unit::TestCase
  def test_parse_integer
    result = nil
    parser = Fraggel::Parser.new do |item, err|
      result = item
    end

    parser.receive_data(":5555\r\n")

    assert_equal(5555, result)
  end

  def test_parse_integer_partial
    result = nil
    parser = Fraggel::Parser.new do |item, err|
      result = item
    end

    ":5555\r\n".each_char do |x|
      assert_nil(result)
      parser.receive_data(x)
    end

    assert_equal(5555, result)
  end

  def test_parse_string_invalid_format
    parser = Fraggel::Parser.new do |item, err|
      assert false
    end

    assert_raise(StandardError) do
      parser.receive_data("$3\r\nfooAA")
    end
  end

  def test_parse_string
    result = nil
    parser = Fraggel::Parser.new do |item, err|
      result = item
    end

    "$3\r\nfoo\r\n".each_char do |x|
      assert_nil(result)
      parser.receive_data(x)
    end

    assert_equal("foo", result)
  end

  def test_parse_with_garbage_command_token
    parser = Fraggel::Parser.new do |item, err|
      assert false
    end

    assert_raise(StandardError) do
      parser.receive_data("(")
    end
  end

  def test_parse_array
    result = nil
    parser = Fraggel::Parser.new do |item, err|
      result = item
    end

    parser.receive_data("*3\r\n$1\r\na\r\n:1\r\n$1\r\n2\r\n")

    assert_equal(["a", 1, "2"], result)
  end

  def test_parse_nested_array
    result = nil
    parser = Fraggel::Parser.new do |item, err|
      result = item
    end

    parser.receive_data("*3\r\n$1\r\na\r\n*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n$1\r\n2\r\n")

    assert_equal(["a", ["foo", "bar"], "2"], result)
  end
end