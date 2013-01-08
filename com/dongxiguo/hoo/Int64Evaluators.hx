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

package com.dongxiguo.hoo;
using haxe.Int32;
using haxe.Int64;
import com.dongxiguo.hoo.selector.binopTag.AssignOpTag;
import com.dongxiguo.hoo.selector.binopTag.AddTag;
import com.dongxiguo.hoo.selector.binopTag.AndTag;
import com.dongxiguo.hoo.selector.binopTag.DivTag;
import com.dongxiguo.hoo.selector.binopTag.EqTag;
import com.dongxiguo.hoo.selector.binopTag.GteTag;
import com.dongxiguo.hoo.selector.binopTag.GtTag;
import com.dongxiguo.hoo.selector.binopTag.IntervalTag;
import com.dongxiguo.hoo.selector.binopTag.LteTag;
import com.dongxiguo.hoo.selector.binopTag.LtTag;
import com.dongxiguo.hoo.selector.binopTag.ModTag;
import com.dongxiguo.hoo.selector.binopTag.MultTag;
import com.dongxiguo.hoo.selector.binopTag.NotEqTag;
import com.dongxiguo.hoo.selector.binopTag.OrTag;
import com.dongxiguo.hoo.selector.binopTag.ShlTag;
import com.dongxiguo.hoo.selector.binopTag.ShrTag;
import com.dongxiguo.hoo.selector.binopTag.SubTag;
import com.dongxiguo.hoo.selector.binopTag.UShrTag;
import com.dongxiguo.hoo.selector.binopTag.XorTag;
import com.dongxiguo.hoo.selector.PrefixOperatorSelector;
import com.dongxiguo.hoo.selector.PostfixOperatorSelector;
import com.dongxiguo.hoo.selector.BinaryOperatorSelector;
import com.dongxiguo.hoo.selector.unopTag.DecrementTag;
import com.dongxiguo.hoo.selector.unopTag.IncrementTag;
import com.dongxiguo.hoo.selector.unopTag.NegBitsTag;
import com.dongxiguo.hoo.selector.unopTag.NegTag;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

@:final class Int64Evaluators
{
  @:noUsing @:extern public static inline function toFloat(int64:Int64):Float
  {
    return int64.getHigh().toInt() * 4294967296.0 + int64.getLow().toInt();
  }

#if macro
  @:noUsing public static function evaluateAssignOp<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<AssignOpTag<OperatorTag>, Dynamic, Dynamic>>,
    left:ExprOf<Int64>,
    right:Expr):ExprOf<Int64>
  {
    var selectorType = Context.typeof(selector);
    switch (Context.follow(selectorType))
    {
      case TAnonymous(a):
      {
        var binopTagType;
        var rightType;
        for (field in a.get().fields)
        {
          switch (field.name)
          {
            case "binaryOperator":
            {
              binopTagType = field.type;
            }
            case "left":
            case "right":
            {
              rightType = field.type;
            }
            default:
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
        }
        switch (binopTagType)
        {
          case TInst(t, innerParams):
          {
            var classType = t.get();
            if (classType.name == "AssignOpTag" && classType.module == "com.dongxiguo.hoo.selector.binopTag.AssignOpTag")
            {
              if (innerParams.length != 1)
              {
                throw Context.error(classType.name + " must not have one typeParameter!", Context.currentPos());
              }
              switch (innerParams[0])
              {
                case TInst(t, innerParams):
                {
                  var innerClassType = t.get();
                  if (innerClassType.module != "com.dongxiguo.hoo.selector.binopTag." + innerClassType.name)
                  {
                    throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
                  }
                  switch (innerClassType.name)
                  {
                    case "AssignOpTag":
                    {
                      throw Context.error(classType.name + "'s typeParameter must not " + innerClassType.name + "!", Context.currentPos());
                    }
                    default:
                    {
                      if (innerParams.length != 0)
                      {
                        throw Context.error(innerClassType.name + " must not have typeParameters!", Context.currentPos());
                      }
                      var varSelectorExpr =
                      {
                        pos: Context.currentPos(),
                        expr: EVars(
                        [
                          {
                            name: "selector",
                            type: TPath(
                            {
                              pack: [ "com", "dongxiguo", "hoo", "selector" ],
                              name: "BinaryOperatorSelector",
                              params:
                              [
                                TPType(TPath(
                                {
                                  pack: innerClassType.pack,
                                  name: innerClassType.name,
                                  params: []
                                })),
                                TPType(TPath(
                                {
                                  pack: [ "haxe" ],
                                  name: "Int64",
                                  params: []
                                })),
                                TPType(TPath(
                                  switch (Context.follow(rightType))
                                  {
                                    case TInst(t, params):
                                    {
                                      if (params.length != 0)
                                      {
                                        Context.error("Right operand must be Int or Int64", Context.currentPos());
                                      }
                                      var intType = t.get();
                                      
                                      {
                                        pack: intType.pack,//[ "com", "dongxiguo", "hoo", "selector", "binopTag" ],
                                        name: intType.name,
                                        params: []
                                      }
                                    }
                                    default:
                                    {
                                      Context.error("Right operand must be Int or Int64", Context.currentPos());
                                    }
                                  }))
                              ]
                            }),
                            expr: macro null
                          }
                        ])
                      }
                      return macro
                      {
                        $varSelectorExpr;
                        $left = selector.evaluate($left, $right);
                      }
                    }
                  }
                }
                default:
                {
                  throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
                }
              }
            }
            else
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
          default:
          {
            throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
          }
        }
      }
      default:
      {
        throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
      }
    }
  }
#end

}

@:final extern class NegInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector: PrefixOperatorSelector<NegTag, Int64>,
    operand:Int64):Int64
  {
    return operand.neg();
  }
}

@:final extern class NegBitsInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:PrefixOperatorSelector<NegBitsTag, Int64>,
    operand:Int64):Int64
  {
    return Int64.make(Int32.ofInt(~operand.getHigh().toNativeInt()), Int32.ofInt(~operand.getLow().toNativeInt()));
  }
}

@:final extern class Int64EqInt64Evaluator
{  
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<EqTag, Int64, Int64>,
    left:Int64,
    right:Int64):Bool
  {
    return left.compare(right) == 0;
  }
}

@:final extern class Int64NotEqInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<NotEqTag, Int64, Int64>,
    left:Int64,
    right:Int64):Bool
  {
    return left.compare(right) != 0;
  }
}

@:final extern class Int64GtInt64Evaluator
{  
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<GtTag, Int64, Int64>,
    left:Int64,
    right:Int64):Bool
  {
    return left.compare(right) > 0;
  }
}

@:final extern class Int64GteInt64Evaluator
{  
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<GteTag, Int64, Int64>,
    left:Int64,
    right:Int64):Bool
  {
    return left.compare(right) >= 0;
  }
}

@:final extern class Int64LtInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<LtTag, Int64, Int64>,
    left:Int64,
    right:Int64):Bool
  {
    return left.compare(right) < 0;
  }
}

@:final extern class Int64LteInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<LteTag, Int64, Int64>,
    left:Int64,
    right:Int64):Bool
  {
    return left.compare(right) <= 0;
  }
}

@:final extern class Int64IntervalInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<IntervalTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64Iterator
  {
    return new Int64Iterator(left, right);
  }
}

@:final extern class Int64AndInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<AndTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.and(right);
  }
}

@:final extern class Int64OrInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<OrTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.or(right);
  }
}

@:final extern class Int64XorInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<XorTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.xor(right);
  }
}

@:final extern class Int64ShlIntEvaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<ShlTag, Int64, Int>,
    left:Int64,
    right:Int):Int64
  {
    return left.shl(right);
  }
}

@:final extern class Int64ShrIntEvaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<ShrTag, Int64, Int>,
    left:Int64,
    right:Int):Int64
  {
    return left.shr(right);
  }
}

@:final extern class Int64UshrIntEvaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<UShrTag, Int64, Int>,
    left:Int64,
    right:Int):Int64
  {
    return left.ushr(right);
  }
}

@:final extern class Int64AddInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<AddTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.add(right);
  }
}

@:final extern class Int64MultInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<MultTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.mul(right);
  }
}

@:final extern class Int64DivInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<DivTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.div(right);
  }
}

@:final extern class Int64SubInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<SubTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.sub(right);
  }
}

@:final extern class Int64ModInt64Evaluator
{
  @:extern public static inline function evaluate(
    selector:BinaryOperatorSelector<ModTag, Int64, Int64>,
    left:Int64,
    right:Int64):Int64
  {
    return left.mod(right);
  }
}

@:final @:macro class Int64IncrementEvaluator
{  
  public static function evaluate(
    selector:ExprOf<PostfixOperatorSelector<IncrementTag, Int64>>,
    operand:ExprOf<Int64>):ExprOf<Int64>
  {
    return macro
    {
      var result = $operand;
      $operand = $operand.add(Int64.ofInt(1));
      result;
    };
  }
}

@:final @:macro class Int64DecrementEvaluator
{
  public static function evaluate(
    selector:ExprOf<PostfixOperatorSelector<DecrementTag, Int64>>,
    operand:ExprOf<Int64>):ExprOf<Int64>
  {
    return macro
    {
      var result = $operand;
      $operand = $operand.sub(Int64.ofInt(1));
      result;
    };
  }
}

@:final @:macro class IncrementInt64Evaluator
{
  public static function evaluate(
    selector:ExprOf<PrefixOperatorSelector<IncrementTag, Int64>>,
    operand:ExprOf<Int64>):ExprOf<Int64>
  {
    return macro
    {
      $operand = $operand.add(Int64.ofInt(1));
      $operand;
    };
  }
}

@:final @:macro class DecrementInt64Evaluator
{
  public static function evaluate(
    selector:ExprOf<PrefixOperatorSelector<DecrementTag, Int64>>,
    operand:ExprOf<Int64>):ExprOf<Int64>
  {
    return macro 
    {
      $operand = $operand.sub(Int64.ofInt(1));
      $operand;
    };
  }
}

@:final @:macro class Int64AssignOpIntEvalutor
{
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<AssignOpTag<OperatorTag>, Int64, Int>>,
    left:ExprOf<Int64>,
    right:ExprOf<Int>):ExprOf<Int64>
  {
    return Int64Evaluators.evaluateAssignOp(selector, left, right);
  }
}

@:final @:macro class Int64AssignOpInt64Evalutor
{
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<AssignOpTag<OperatorTag>, Int64, Int64>>,
    left:ExprOf<Int64>,
    right:ExprOf<Int64>):ExprOf<Int64>
  {
    return Int64Evaluators.evaluateAssignOp(selector, left, right);
  }
}

@:final @:macro class Int64IntEvalutor
{
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Int64, Int>>,
    left:ExprOf<Int64>,
    right:ExprOf<Int>):Expr
  {
    var selectorType = Context.typeof(selector);
    switch (Context.follow(selectorType))
    {
      case TAnonymous(a):
      {
        var binopTagType;
        for (field in a.get().fields)
        {
          switch (field.name)
          {
            case "binaryOperator":
            {
              binopTagType = field.type;
            }
            case "left", "right":
            default:
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
        }
        switch (binopTagType)
        {
          case TInst(t, innerParams):
          {
            var classType = t.get();
            if (classType.module != "com.dongxiguo.hoo.selector.binopTag." + classType.name)
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
            switch (classType.name)
            {
              case "AssignOpTag":
              {
                throw Context.error(classType.name + "'s typeParameter must not " + classType.name + "!", Context.currentPos());
              }
              default:
              {
                if (innerParams.length != 0)
                {
                  throw Context.error(classType.name + " must not have typeParameters!", Context.currentPos());
                }
                var varSelectorExpr =
                {
                  pos: Context.currentPos(),
                  expr: EVars(
                  [
                    {
                      name: "selector",
                      type: TPath(
                      {
                        pack: [ "com", "dongxiguo", "hoo", "selector" ],
                        name: "BinaryOperatorSelector",
                        params:
                        [
                          TPType(TPath(
                          {
                            pack: classType.pack,
                            name: classType.name,
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [ "haxe" ],
                            name: "Int64",
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [ "haxe" ],
                            name: "Int64",
                            params: []
                          }))
                        ]
                      }),
                      expr: macro null
                    }
                  ])
                }
                return macro
                {
                  $varSelectorExpr;
                  selector.evaluate($left, haxe.Int64.ofInt($right));
                }
              }
            }
          }
          default:
          {
            throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
          }
        }
      }
      default:
      {
        throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
      }
    }
  }
}

@:final @:macro class Int64FloatEvalutor
{
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Int64, Float>>,
    left:ExprOf<Int64>,
    right:ExprOf<Float>):Expr
  {
    var selectorType = Context.typeof(selector);
    switch (Context.follow(selectorType))
    {
      case TAnonymous(a):
      {
        var binopTagType;
        for (field in a.get().fields)
        {
          switch (field.name)
          {
            case "binaryOperator":
            {
              binopTagType = field.type;
            }
            case "left", "right":
            default:
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
        }
        switch (binopTagType)
        {
          case TInst(t, innerParams):
          {
            var classType = t.get();
            if (classType.module != "com.dongxiguo.hoo.selector.binopTag." + classType.name)
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
            switch (classType.name)
            {
              case "AssignOpTag":
              {
                throw Context.error(classType.name + "must not apply on Int64 and Float!", Context.currentPos());
              }
              default:
              {
                if (innerParams.length != 0)
                {
                  throw Context.error(classType.name + " must not have typeParameters!", Context.currentPos());
                }
                var varSelectorExpr =
                {
                  pos: Context.currentPos(),
                  expr: EVars(
                  [
                    {
                      name: "selector",
                      type: TPath(
                      {
                        pack: [ "com", "dongxiguo", "hoo", "selector" ],
                        name: "BinaryOperatorSelector",
                        params:
                        [
                          TPType(TPath(
                          {
                            pack: classType.pack,
                            name: classType.name,
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [],
                            name: "Float",
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [],
                            name: "Float",
                            params: []
                          }))
                        ]
                      }),
                      expr: macro null
                    }
                  ])
                }
                return macro
                {
                  $varSelectorExpr;
                  selector.evaluate(com.dongxiguo.hoo.Int64Evaluators.toFloat($left), $right);
                }
              }
            }
          }
          default:
          {
            throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
          }
        }
      }
      default:
      {
        throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
      }
    }
  }
}

@:final @:macro class IntInt64Evalutor
{
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Int, Int64>>,
    left:ExprOf<Int>,
    right:ExprOf<Int64>):Expr
  {
    var selectorType = Context.typeof(selector);
    switch (Context.follow(selectorType))
    {
      case TAnonymous(a):
      {
        var binopTagType;
        for (field in a.get().fields)
        {
          switch (field.name)
          {
            case "binaryOperator":
            {
              binopTagType = field.type;
            }
            case "left", "right":
            default:
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
        }
        switch (binopTagType)
        {
          case TInst(t, innerParams):
          {
            var classType = t.get();
            if (classType.module != "com.dongxiguo.hoo.selector.binopTag." + classType.name)
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
            switch (classType.name)
            {
              case "AssignOpTag":
              {
                throw Context.error(classType.name + " must not apply on Int and Int64!", Context.currentPos());
              }
              default:
              {
                if (innerParams.length != 0)
                {
                  throw Context.error(classType.name + " must not have typeParameters!", Context.currentPos());
                }
                var varSelectorExpr =
                {
                  pos: Context.currentPos(),
                  expr: EVars(
                  [
                    {
                      name: "selector",
                      type: TPath(
                      {
                        pack: [ "com", "dongxiguo", "hoo", "selector" ],
                        name: "BinaryOperatorSelector",
                        params:
                        [
                          TPType(TPath(
                          {
                            pack: classType.pack,
                            name: classType.name,
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [ "haxe" ],
                            name: "Int64",
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [ "haxe" ],
                            name: "Int64",
                            params: []
                          }))
                        ]
                      }),
                      expr: macro null
                    }
                  ])
                }
                return macro
                {
                  $varSelectorExpr;
                  selector.evaluate(haxe.Int64.ofInt($left), $right);
                }
              }
            }
          }
          default:
          {
            throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
          }
        }
      }
      default:
      {
        throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
      }
    }
  }
}

@:final @:macro class FloatInt64Evalutor
{
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Float, Int64>>,
    left:ExprOf<Float>,
    right:ExprOf<Int64>):Expr
  {
    var selectorType = Context.typeof(selector);
    switch (Context.follow(selectorType))
    {
      case TAnonymous(a):
      {
        var binopTagType;
        for (field in a.get().fields)
        {
          switch (field.name)
          {
            case "binaryOperator":
            {
              binopTagType = field.type;
            }
            case "left", "right":
            default:
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
        }
        switch (binopTagType)
        {
          case TInst(t, innerParams):
          {
            var classType = t.get();
            if (classType.module != "com.dongxiguo.hoo.selector.binopTag." + classType.name)
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
            switch (classType.name)
            {
              case "AssignOpTag":
              {
                // TODO:
                throw Context.error(classType.name + " must not apply on Float and Int64!", Context.currentPos());
              }
              default:
              {
                if (innerParams.length != 0)
                {
                  throw Context.error(classType.name + " must not have typeParameters!", Context.currentPos());
                }
                var varSelectorExpr =
                {
                  pos: Context.currentPos(),
                  expr: EVars(
                  [
                    {
                      name: "selector",
                      type: TPath(
                      {
                        pack: [ "com", "dongxiguo", "hoo", "selector" ],
                        name: "BinaryOperatorSelector",
                        params:
                        [
                          TPType(TPath(
                          {
                            pack: classType.pack,
                            name: classType.name,
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [],
                            name: "Float",
                            params: []
                          })),
                          TPType(TPath(
                          {
                            pack: [],
                            name: "Float",
                            params: []
                          }))
                        ]
                      }),
                      expr: macro null
                    }
                  ])
                }
                return macro
                {
                  $varSelectorExpr;
                  selector.evaluate($left, com.dongxiguo.hoo.Int64Evaluators.toFloat($right));
                }
              }
            }
          }
          default:
          {
            throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
          }
        }
      }
      default:
      {
        throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
      }
    }
  }
}