require "../../spec_helper"

describe "Call errors" do
  it "says wrong number of arguments (to few arguments)" do
    assert_error %(
      def foo(x)
      end

      foo
      ),
      "wrong number of arguments for 'foo' (given 0, expected 1)"
  end

  it "says wrong number of arguments even if other overloads don't match by block" do
    assert_error %(
      def foo(x)
      end

      def foo(x, y)
        yield
      end

      foo
      ),
      "wrong number of arguments for 'foo' (given 0, expected 1)"
  end

  it "says not expected to be invoked with a block" do
    assert_error %(
      def foo
      end

      foo {}
      ),
      "'foo' is not expected to be invoked with a block, but a block was given"
  end

  it "says expected to be invoked with a block" do
    assert_error %(
      def foo
        yield
      end

      foo
      ),
      "'foo' is expected to be invoked with a block, but no block was given"
  end

  it "says missing named argument" do
    assert_error %(
      def foo(*, x)
      end

      foo
      ),
      "missing argument: x"
  end

  it "says missing named arguments" do
    assert_error %(
      def foo(*, x, y)
      end

      foo
      ),
      "missing arguments: x, y"
  end

  it "says no parameter named" do
    assert_error %(
      def foo
      end

      foo(x: 1)
      ),
      "no parameter named 'x'"
  end

  it "says no parameters named" do
    assert_error %(
      def foo
      end

      foo(x: 1, y: 2)
      ),
      "no parameters named 'x', 'y'"
  end

  it "says argument already specified" do
    assert_error %(
      def foo(x)
      end

      foo(1, x: 2)
      ),
      "argument for parameter 'x' already specified"
  end

  it "says type mismatch for positional argument" do
    assert_error %(
      def foo(x : Int32, y : Int32)
      end

      foo(1, 'a')
      ),
      "expected argument #2 to 'foo' to be Int32, not Char"
  end

  it "says type mismatch for positional argument with two options" do
    assert_error %(
      def foo(x : Int32)
      end

      def foo(x : String)
      end

      foo('a')
      ),
      "expected argument #1 to 'foo' to be Int32 or String, not Char"
  end

  it "says type mismatch for positional argument with three options" do
    assert_error %(
      def foo(x : Int32)
      end

      def foo(x : String)
      end

      def foo(x : Bool)
      end

      foo('a')
      ),
      "expected argument #1 to 'foo' to be Bool, Int32 or String, not Char"
  end

  it "says type mismatch for named argument " do
    assert_error %(
      def foo(x : Int32, y : Int32)
      end

      foo(y: 1, x: 'a')
      ),
      "expected argument 'x' to 'foo' to be Int32, not Char"
  end

  it "replaces free variables in positional argument" do
    assert_error %(
      def foo(x : T, y : T) forall T
      end

      foo(1, 'a')
      ),
      "expected argument #2 to 'foo' to be Int32, not Char"
  end

  it "replaces free variables in named argument" do
    assert_error %(
      def foo(x : T, y : T) forall T
      end

      foo(x: 1, y: 'a')
      ),
      "expected argument 'y' to 'foo' to be Int32, not Char"
  end

  it "replaces generic type var in positional argument" do
    assert_error %(
      class Foo(T)
        def self.foo(x : T)
        end
      end

      Foo(Int32).foo('a')
      ),
      "expected argument #1 to 'Foo(Int32).foo' to be Int32, not Char"
  end

  it "replaces generic type var in named argument" do
    assert_error %(
      class Foo(T)
        def self.foo(x : T, y : T)
        end
      end

      Foo(Int32).foo(x: 1, y: 'a')
      ),
      "expected argument 'y' to 'Foo(Int32).foo' to be Int32, not Char"
  end

  it "says type mismatch for positional argument even if there are overloads that don't match" do
    assert_error %(
      def foo(x : Int32)
      end

      def foo(x : Char)
      end

      def foo(x : Char, y : Int32)
      end

      foo("hello")
      ),
      "expected argument #1 to 'foo' to be Char or Int32, not String"
  end

  it "says type mismatch for symbol against enum (did you mean)" do
    assert_error %(
      enum Color
        Red
        Green
        Blue
      end

      def foo(x : Color)
      end

      foo(:rred)
      ),
      "expected argument #1 to 'foo' to match a member of enum Color.\n\nDid you mean :red?"
  end

  it "says type mismatch for symbol against enum (list all possibilities when 10 or less)" do
    assert_error %(
      enum Color
        Red
        Green
        Blue
        Violet
        Purple
      end

      def foo(x : Color)
      end

      foo(:hello_world)
      ),
      "expected argument #1 to 'foo' to match a member of enum Color.\n\nOptions are: :red, :green, :blue, :violet and :purple"
  end

  it "says type mismatch for symbol against enum, named argument case" do
    assert_error %(
      enum Color
        Red
        Green
        Blue
      end

      def foo(x : Color)
      end

      foo(x: :rred)
      ),
      "expected argument 'x' to 'foo' to match a member of enum Color.\n\nDid you mean :red?"
  end
end
