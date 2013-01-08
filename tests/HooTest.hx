// Copyright (c) 2012, 杨博 (Yang Bo)
// All rights reserved.
// 
// Author: 杨博 (Yang Bo) <pop.atry@gmail.com>
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of the <ORGANIZATION> nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

package tests;

using com.dongxiguo.hoo.NativeEvaluators;
using com.dongxiguo.hoo.Int64Evaluators;
import haxe.Int64;

/**
 * @author 杨博
 */
@:build(com.dongxiguo.hoo.OperatorOverloading.enableByMeta("hoo"))
@:final class HooTest 
{
  private static var setter(never, null):Int = 0;
  
  @hoo public static function foo():Int
  {
    return 1;
  }
  
  @hoo(true) public static function main():Void
  {
    foo();
    setter = 1;
    "sss" + "ss";
    var a = "xx";
    var i = 0;
    trace(i++);
    trace(++i);
    trace(i);
    var i2:Int = -i;
    - - - - --i2 - - -1 + 1.5 / 4;
    a = "xx" + [] + "";
    a += a += "xx" + [] + "";
    a = "xx" + [] + "";
    a += a += "xx" + [] + "";

    1 / 1 * 1 - 3;
    1 % 1.01;
    
    
    var i64 = Int64.ofInt(3);
    var f3 = 1 - 5 * i64 / 5 + 3 - 4 * 5.0;
    trace(f3);
    i64 *= i;
    var i2 = Int64.ofInt(2 * 3);
    trace(Int64.toStr(i2));
    i64 = i2 << 2 << 3 << 4;
    trace(Int64.toStr(i64));
    -Int64.toInt(Int64.ofInt(3));
    trace(Int64.toStr(i64));
    i64 = Int64.ofInt(3) << 2;
    trace(Int64.toStr(i64));
    i64 += Int64.ofInt(3) << 2;
    trace(Int64.toStr(i64));
    i64 *= Int64.ofInt(3) * Int64.ofInt(3);
    trace(Int64.toStr(i64));
    i64 <<= 3;
    trace(Int64.toStr(i64));
    i2 += i64 += 3;
    trace(Int64.toStr(i64));
    trace(Int64.toStr(i2));
    i64 += 3 + i64 + 3;
    trace(Int64.toStr(i64) + "xxx" + "yyy");
    trace(a += i2 += i64);
    //computeSingleQuantity(i64);
    //true ? "" : 0;
  }
  //@hoo public static function computeSingleQuantity(totalQuantity:Int64):Int64
  //{
    //return Int64.ofInt(1);
  //
  //}
}
