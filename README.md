Hoo
=================

**Haxe Operator Overloading** (<wbr/>**Hoo**), is a library that enables [operator overloading](https://en.wikipedia.org/wiki/Operator_overloading)
for [Haxe](http://www.haxe.org/).

Hoo has built-in overloaded operators for `haxe.Int64`. Here's an example:

    var i64 = Int64.ofInt(123456789);
    
    // Output: 12345678900000123
    trace(i64 * 100000000 + 123);

## Installation

I have uploaded Hoo to [haxelib](http://lib.haxe.org/p/hoo). To install it, run 
this in the shell:

    haxelib install hoo

Now you can use Hoo in your code.

You can compile to JavaScript:

    haxe -lib hoo -main Your.hx -js your-output.js

, or SWF:

    haxe -lib hoo -main Your.hx -swf your-output.swf

, or any other platform that Haxe supports.

Note that Hoo requires Haxe 2.10.

## Usage

In the following example, we'll overload the concatenation operator for Arrays.

### Step 1: Enable operator overloading

Create `Sample.hx` with the following content:

    @:build(com.dongxiguo.hoo.OperatorOverloading.enableByMeta("hoo"))
    class Sample
    {
      @hoo public static function main() 
      {
        var stringArray = ["H", "el", "lo, "] + [ "Wo", "rld!" ];
        trace(stringArray.join(""));
      }
    }

To enable operator overloading, you must add `@:build(com.dongxiguo.hoo.OperatorOverloading.enableByMeta("hoo"))`
for classes that use overloaded operators, and add `@hoo` for methods that use overloaded operators.

The operator `+` will be replaced to a function call to `evaluate`.
If you compile `Sample.hx`, Haxe will complain that it cannot find the field `evaluate`.

### Step 2: Implement the overloading function

Create `ArrayConcatenationEvaluator.hx` with the following content:

    import com.dongxiguo.hoo.selector.BinaryOperatorSelector;
    import com.dongxiguo.hoo.selector.binopTag.AddTag;
    class ArrayConcatenationEvaluator
    {
      public static function evaluate<T>(
        selector: BinaryOperatorSelector<AddTag, Array<T>, Array<T>>,
        left:Array<T>, right:Array<T>):Array<T>
      {
        return left.concat(right);
      }
    }

### Step 3: Use ArrayConcatenationEvaluator

Add `using ArrayConcatenationEvaluator;` to your `Sample.hx`:

    using ArrayConcatenationEvaluator;
    @:build(com.dongxiguo.hoo.OperatorOverloading.enableByMeta("hoo"))
    class Sample
    {
      @hoo public static function main() 
      {
        // stringArray is ["H", "el", "lo, ", "wo", "rld!" ];
        var stringArray = ["H", "el", "lo, "] + ["wo", "rld!"];
        trace(stringArray.join(""));
      }
    }

### Step 4: Run it!

    haxe -x Sample.hx

Now you will see it outputs `Hello, world!`.

## Build-in overloads

There are built-in overloaded operators for `haxe.Int64` and native types.
To enable them, type `using com.dongxiguo.hoo.Int64Evaluators;` and/or
`using com.dongxiguo.hoo.NativeEvaluators;`:

    #if haxe_211
    using com.dongxiguo.hoo.NativeEvaluators;
    using com.dongxiguo.hoo.Int64Evaluators;
    #else
    using com.dongxiguo.hoo.Int64Evaluators;
    using com.dongxiguo.hoo.NativeEvaluators;
    #end
    @:build(com.dongxiguo.hoo.OperatorOverloading.enableByMeta("hoo"))
    class Sample
    {
      @hoo public static function main() 
      {
        var i64 = Int64.ofInt(123456789);
        
        // Output: 12345678900000123
        trace(i64 * 100000000 + 123);
      }
    }

If you want to overload `==` for `haxe.Int64`, you must:
 * Put `using Int64Evaluators;` before `using NativeEvaluators;` for Haxe 2.10;
 * Put `using NativeEvaluators;` before `using Int64Evaluators;` for Haxe 2.11.

## License

See https://github.com/Atry/hoo/blob/master/LICENSE
