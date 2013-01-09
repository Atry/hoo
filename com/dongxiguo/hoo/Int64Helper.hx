package com.dongxiguo.hoo;

using haxe.Int64;
using haxe.Int32;

/**
 * @author 杨博
 */
@:final
extern class Int64Helper 
{

  @:extern public static inline function floatToInt64(float:Float):Int64
  {
    return Int64.make(Int32.ofInt(Math.floor(float / 4294967296.0)), Int32.ofInt(cast float));
  }
  
  @:extern public static inline function int64ToFloat(int64:Int64):Float
  {
    return int64.getHigh().toNativeInt() * 4294967296.0 + int64.getLow().toNativeInt();
  }
  
}