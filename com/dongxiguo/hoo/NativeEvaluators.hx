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

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end
import com.dongxiguo.hoo.selector.BinaryOperatorSelector;
import com.dongxiguo.hoo.selector.PostfixOperatorSelector;
import com.dongxiguo.hoo.selector.PrefixOperatorSelector;
import com.dongxiguo.hoo.selector.binopTag.AddTag;
import com.dongxiguo.hoo.selector.binopTag.AssignTag;
import com.dongxiguo.hoo.selector.binopTag.AssignOpTag;
import com.dongxiguo.hoo.selector.binopTag.NotEqTag;
import com.dongxiguo.hoo.selector.binopTag.EqTag;

@:final extern class EqEvaluator
{
  @:extern public static inline function evaluate<Operand>(
    selector:BinaryOperatorSelector<EqTag, Operand, Operand>,
    left:Operand, right:Operand):Bool
  {
    return left == right;
  }
}

@:final extern class NotEqEvaluator
{
  @:extern public static inline function evaluate<Operand>(
    selector:BinaryOperatorSelector<NotEqTag, Operand, Operand>,
    left:Operand, right:Operand):Bool
  {
    return left != right;
  }
}

@:final class AssignEvaluator
{
  @:macro public static function evaluate<Operand>(
    selector:ExprOf<BinaryOperatorSelector<AssignTag, Operand, Operand>>,
    left:ExprOf<Operand>, right:ExprOf<Operand>):ExprOf<Operand>
  {
    return macro $left = $right;
  }
}

@:final class AddStringEvaluator
{
  @:macro public static function evaluate<Left>(
    selector:ExprOf<BinaryOperatorSelector<AddTag, Left, String>>,
    left:ExprOf<Left>, right:ExprOf<String>):ExprOf<String>
  {
    return macro $left + $right;
  }
}

@:final class StringAddEvaluator
{
  @:macro public static function evaluate<Right>(
    selector:ExprOf<BinaryOperatorSelector<AddTag, String, Right>>,
    left:ExprOf<String>, right:ExprOf<Right>):ExprOf<String>
  {
    return macro $left + $right;
  }
}

@:final class StringAddAssignEvaluator
{
  @:macro public static function evaluate<Operand>(
    selector:ExprOf<BinaryOperatorSelector<AssignOpTag<AddTag>, String, Operand>>,
    left:ExprOf<String>, right:ExprOf<Operand>):ExprOf<String>
  {
    return macro $left += $right;
  }
}

#if macro
@:final private class NativeEvaluators
{
  @:noUsing public static function operatorTagNameToEnumName(operatorTagName:String):String
  {
    if (operatorTagName.substring(operatorTagName.length - 3) != "Tag")
    {
      throw "Bad arugment value for operatorTagName: " + operatorTagName;
    }
    return "Op" + operatorTagName.substring(0, operatorTagName.length - 3);
  }
  
  @:noUsing public static function evaluateUnaryOperator<Operand>(
    selector:Expr,
    operand:ExprOf<Operand>):Expr
  {
    var selectorType = Context.typeof(selector);
    switch (Context.follow(selectorType))
    {
      case TAnonymous(a):
      {
        var unopTagType;
        var isPostfix;
        for (field in a.get().fields)
        {
          switch (field.name)
          {
            case "postfixOperator":
            {
              unopTagType = field.type;
              isPostfix = true;
            }
            case "prefixOperator":
            {
              unopTagType = field.type;
              isPostfix = false;
            }
            case "operand":
            default:
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
          }
        }
        switch (unopTagType)
        {
          case TInst(t, params):
          {
            var classType = t.get();
            if (classType.module != "com.dongxiguo.hoo.selector.unopTag." + classType.name)
            {
              throw Context.error("Illegal selector: " + selectorType, Context.currentPos());
            }
            switch (classType.name)
            {
              default:
              {
                if (params.length != 0)
                {
                  throw Context.error(classType.name + " must not have typeParameters!!", Context.currentPos());
                }
                var opEnumName = operatorTagNameToEnumName(classType.name);
                return
                {
                  pos: Context.currentPos(),
                  expr: EUnop(Type.createEnum(Unop, opEnumName), isPostfix, operand)
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
  
  @:noUsing public static function evaluateBinaryOperator<OperatorTag, Operand>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Operand, Operand>>,
    left:ExprOf<Operand>, right:ExprOf<Operand>):Expr
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
          case TInst(t, params):
          {
            var classType = t.get();
            if (classType.name == "AssignOpTag" && classType.module == "com.dongxiguo.hoo.selector.binopTag.AssignOpTag")
            {
              if (params.length != 1)
              {
                throw Context.error(classType.name + " must not have one typeParameter!!", Context.currentPos());
              }
              switch (params[0])
              {
                case TInst(t, params):
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
                      if (params.length != 0)
                      {
                        throw Context.error(innerClassType.name + " must not have typeParameters!!", Context.currentPos());
                      }
                      return
                      {
                        pos: Context.currentPos(),
                        expr: EBinop(
                          Binop.OpAssignOp(Type.createEnum(Binop, operatorTagNameToEnumName(innerClassType.name))),
                          left,
                          right)
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
            else if ("com.dongxiguo.hoo.selector.binopTag." + classType.name == classType.module)
            {
              if (params.length != 0)
              {
                throw Context.error(classType.name + " must not have typeParameters!!", Context.currentPos());
              }
              var opEnumName = operatorTagNameToEnumName(classType.name);
              return
              {
                pos: Context.currentPos(),
                expr: EBinop(
                  Type.createEnum(Binop, opEnumName),
                  left,
                  right)
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
}
#end

@:final class FloatBinaryEvaluator
{
  @:macro public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Float, Float>>,
    left:ExprOf<Float>, right:ExprOf<Float>):Expr
  {
    return NativeEvaluators.evaluateBinaryOperator(selector, left, right);
  }
}

@:final class FloatPrefixEvaluator
{
  @:macro public static function evaluate<OperatorTag>(
    selector:ExprOf<PrefixOperatorSelector<OperatorTag, Float>>,
    operant:ExprOf<Float>):Expr
  {
    return NativeEvaluators.evaluateUnaryOperator(selector, operant);
  }
}

@:final class FloatPostfixEvaluator
{
  @:macro
  public static function evaluate<OperatorTag>(
    selector:ExprOf<PostfixOperatorSelector<OperatorTag, Float>>,
    operant:ExprOf<Float>):Expr
  {
    return NativeEvaluators.evaluateUnaryOperator(selector, operant);
  }
}

@:final class BoolBinaryEvaluator
{
  @:macro
  public static function evaluate<OperatorTag>(
    selector:ExprOf<BinaryOperatorSelector<OperatorTag, Bool, Bool>>,
    left:ExprOf<Bool>, right:ExprOf<Bool>):Expr
  {
    return NativeEvaluators.evaluateBinaryOperator(selector, left, right);
  }
}

@:final class BoolPrefixEvaluator
{
  @:macro
  public static function evaluate<OperatorTag>(
    selector:ExprOf<PrefixOperatorSelector<OperatorTag, Bool>>,
    operant:ExprOf<Bool>):Expr
  {
    return NativeEvaluators.evaluateUnaryOperator(selector, operant);
  }
}

@:final class BoolPostfixEvaluator
{
  @:macro
  public static function evaluate<OperatorTag>(
    selector:ExprOf<PostfixOperatorSelector<OperatorTag, Bool>>,
    operant:ExprOf<Bool>):Expr
  {
    return NativeEvaluators.evaluateUnaryOperator(selector, operant);
  }
}
