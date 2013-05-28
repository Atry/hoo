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

/**
 * @author 杨博 <pop.atry@gmail.com>
 */
@:final
#if !macro
extern
#end
class OperatorOverloading 
{
  #if macro
  private static function operatorEnumNameToTagName(operatorEnumName:String):String
  {
    if (operatorEnumName.substring(0, 2) != "Op")
    {
      throw "Bad arugment value for operatorEnumName: " + operatorEnumName;
    }
    return operatorEnumName.substring(2) + "Tag";
  }
  
  private static function reflectiveReplace(dontOverloadAssignOperator:Bool, searchIn:Dynamic):Void
  {
    if (Reflect.hasField(searchIn, "expr") &&
        Type.getEnum(searchIn.expr) == ExprDef &&
        Reflect.hasField(searchIn, "pos") &&
        Type.getEnum(searchIn.pos) == Position)
    {
      replaceOperators(dontOverloadAssignOperator, cast searchIn);
    }
    else if (Std.is(searchIn, Array))
    {
      for (v in cast(searchIn, Array<Dynamic>))
      {
        reflectiveReplace(dontOverloadAssignOperator, v);
      }
    }
    else if (Type.getEnum(searchIn) != null)
    {
      for (v in Type.enumParameters(searchIn))
      {
        reflectiveReplace(dontOverloadAssignOperator, v);
      }
    }
    else
    {
      for (p in Reflect.fields(searchIn))
      {
        reflectiveReplace(dontOverloadAssignOperator, Reflect.field(searchIn, p));
      }
    }
  }

  private static function replaceOperators(dontOverloadAssignOperator:Bool, expr:Expr):Void
  {
    switch (expr.expr)
    {
      case EBinop(op, e1, e2):
      {
        replaceOperators(dontOverloadAssignOperator, e1);
        replaceOperators(dontOverloadAssignOperator, e2);
        if (op == OpAssign && dontOverloadAssignOperator)
        {
          return;
        }
        var tagExpr = switch(op)
        {
          case OpAssignOp(op):
          {
            var varExpr =
            {
              pos: Context.currentPos(),
              expr: EVars(
              [
                {
                  name: "__assingOpTag",
                  type: TPath(
                  {
                    pack: [ "com", "dongxiguo", "hoo", "selector", "binopTag" ],
                    name: "AssignOpTag",
                    params:
                    [
                      TPType(TPath(
                      {
                        pack: [ "com", "dongxiguo", "hoo", "selector", "binopTag" ],
                        name: operatorEnumNameToTagName(Type.enumConstructor(op)),
                        params: []
                      }))
                    ]
                  }),
                  expr: macro null,
                }
              ])
            };
            macro { $varExpr; __assingOpTag; }
          }
          default:
          {
            pos: Context.currentPos(),
            expr: ECast(macro null, TPath(
            {
              pack: [ "com", "dongxiguo", "hoo", "selector", "binopTag" ],
              name: operatorEnumNameToTagName(Type.enumConstructor(op)),
              params: []
            }))
          }
        }
        var evaluateExpr =
        {
          pos: expr.pos,
          expr: ECall(
          {
            pos: expr.pos,
            expr: EField(macro selector, "evaluate")
          },
          [
            e1,
            e2
          ])
        }
        var replaced = macro 
        {
          var selector:haxe.macro.MacroType<[
            haxe.macro.Context.typeof(
            {
              binaryOperator: $tagExpr,
              left: $e1,
              right: $e2
            })] > = null;
          $evaluateExpr;
          //selector.evaluate($e1, $e2);
        }
        expr.expr = replaced.expr;
      }
      case EUnop(op, isPostfix, e):
      {
        replaceOperators(dontOverloadAssignOperator, e);
        var tagExpr =
        {
          pos: Context.currentPos(),
          expr: ECast(
            macro null,
            TPath(
            {
              pack: [ "com", "dongxiguo", "hoo", "selector", "unopTag" ],
              name: operatorEnumNameToTagName(Type.enumConstructor(op)),
              params: []
            }))
        }
        var selectorExpr =
        {
          pos: Context.currentPos(),
          expr: EObjectDecl(
          [
            {
              field: isPostfix ? "postfixOperator" : "prefixOperator",
              expr: tagExpr
            },
            {
              field: "operand",
              expr: e
            }
          ])
        };
        var replaced = macro
        {
          var selector:haxe.macro.MacroType<[haxe.macro.Context.typeof($selectorExpr)]> = null;
          selector.evaluate($e);
        }
        expr.expr = replaced.expr;
      }
      default:
      {
        reflectiveReplace(dontOverloadAssignOperator, expr.expr);
      }
    }
  }
  #end

  @:noUsing @:macro public static function enable(expr:Expr, ?dontOverloadAssignOperator:Bool = false):Expr
  {
    replaceOperators(dontOverloadAssignOperator, expr);
    return expr;
  }
  
  @:noUsing @:macro public static function enableByMeta(metaName:String, ?dontOverloadAssignOperator:Bool = false):Array<Field>
  {
    var bf = Context.getBuildFields();
    for (field in bf)
    {
      switch (field.kind)
      {
        case FFun(f):
        {
          for (m in field.meta)
          {
            if (m.name == metaName)
            {
              var dontOverloadAssignOperatorExpr =
                if (m.params.length == 1)
                {
                  m.params[0];
                }
                else if (m.params.length == 0)
                {
                  Context.makeExpr(dontOverloadAssignOperator, f.expr.pos);
                }
                else
                {
                  throw Context.error("@" + m.name + " must have 0 or 1 parmeters!", f.expr.pos);
                }
              var originExpr = f.expr;
              // 这样的表达式：enable(if (xxx)"s"else 0)无法通过编译，所以必须增加一个空代码块
              var emptyBlock =
              {
                expr: EBlock([]),
                pos: Context.currentPos()
              }
              switch (originExpr.expr)
              {
                case EBlock(exprs):
                {
                  exprs.push(emptyBlock);
                  f.expr = macro com.dongxiguo.hoo.OperatorOverloading.enable($originExpr, $dontOverloadAssignOperatorExpr);
                }
                default:
                {
                  f.expr = macro com.dongxiguo.hoo.OperatorOverloading.enable( { $originExpr; $emptyBlock; }, $dontOverloadAssignOperatorExpr);
                }
              }
              break;
            }
          }
        }
        default:
        {
          continue;
        }
      }
    }
    return bf;
  }
  
  @:noUsing @:macro public static function enableAll(?dontOverloadAssignOperator:Bool = false):Array<Field>
  {
    var bf = Context.getBuildFields();
    for (field in bf)
    {
      switch (field.kind)
      {
        case FFun(f):
        {
              var dontOverloadAssignOperatorExpr = Context.makeExpr(dontOverloadAssignOperator, f.expr.pos);
              var originExpr = f.expr;
              // 这样的表达式：enable(if (xxx)"s"else 0)无法通过编译，所以必须增加一个空代码块
              var emptyBlock =
              {
                expr: EBlock([]),
                pos: Context.currentPos()
              }
              switch (originExpr.expr)
              {
                case EBlock(exprs):
                {
                  exprs.push(emptyBlock);
                  f.expr = macro com.dongxiguo.hoo.OperatorOverloading.enable($originExpr, $dontOverloadAssignOperatorExpr);
                }
                default:
                {
                  f.expr = macro com.dongxiguo.hoo.OperatorOverloading.enable( { $originExpr; $emptyBlock; }, $dontOverloadAssignOperatorExpr);
                }
              }
        }
        default:
        {
          continue;
        }
      }
    }
    return bf;
  }
}
