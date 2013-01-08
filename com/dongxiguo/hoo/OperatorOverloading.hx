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
  
  private static function replaceOperators(dontOverloadAssignOperator:Bool, expr:Expr):Expr
  {
    switch (expr.expr)
    {
      case EBinop(op, e1, e2):
      {
        if (op == OpAssign && dontOverloadAssignOperator)
        {
          return
          {
            pos: expr.pos,
            expr: EBinop(op, replaceOperators(dontOverloadAssignOperator, e1), replaceOperators(dontOverloadAssignOperator, e2))
          };
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
        var leftExpr = replaceOperators(dontOverloadAssignOperator, e1);
        var rightExpr = replaceOperators(dontOverloadAssignOperator, e2);
        return macro 
        {
          var leftTypeHint = true ? null : $leftExpr;
          var rightTypeHint = true ? null : $rightExpr;
          (true ? null : cast(null, com.dongxiguo.hoo.selector.TypeInferenceHelper).makeBinaryOperatorSelector($tagExpr, leftTypeHint, rightTypeHint)).evaluate($leftExpr, $rightExpr);
        }
      }
      case EUnop(op, isPostfix, e):
      {
        var makeSelectorExpr =
        {
          pos: Context.currentPos(),
          expr: EField(
            macro cast(null, com.dongxiguo.hoo.selector.TypeInferenceHelper),
            isPostfix ? "makePostfixOperatorSelector" : "makePrefixOperatorSelector")
        }
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
        var operandExpr = replaceOperators(dontOverloadAssignOperator, e);
        return macro
        {
          var operandTypeHint = true ? null : $operandExpr;
          (true ? null : $makeSelectorExpr($tagExpr, operandTypeHint)).evaluate($operandExpr);
        }
      }
      case EConst(c):
      {
        return expr;
      }
      case EArray(e1, e2):
      {
        return
        {
          pos: expr.pos,
          expr: EArray(replaceOperators(dontOverloadAssignOperator, e1), replaceOperators(dontOverloadAssignOperator, e2))
        };
      }
      case EField(e, field):
      {
        return
        {
          pos: expr.pos,
          expr: EField(replaceOperators(dontOverloadAssignOperator, e), field)
        };
      }
      case EParenthesis(e):
      {
        return
        {
          pos: expr.pos,
          expr: EParenthesis(replaceOperators(dontOverloadAssignOperator, e))
        };
      }
      case EObjectDecl(fields):
      {
        return
        {
          pos: expr.pos,
          expr: EObjectDecl(Lambda.array(Lambda.map(fields, function(element)
          {
            return
            {
              field: element.field,
              expr: replaceOperators(dontOverloadAssignOperator, element.expr)
            };
          })))
        };
      }
      case EArrayDecl(values):
      {
        return
        {
          pos: expr.pos,
          expr: EArrayDecl(Lambda.array(Lambda.map(values, callback(replaceOperators, dontOverloadAssignOperator))))
        };
      }
      case ECall(e, params):
      {
        return
        {
          pos: expr.pos,
          expr: ECall(
            replaceOperators(dontOverloadAssignOperator, e),
            Lambda.array(Lambda.map(params, callback(replaceOperators, dontOverloadAssignOperator))))
        };
      }
      case ENew(t, params):
      {
        return
        {
          pos: expr.pos,
          expr: ENew(t, Lambda.array(Lambda.map(params, callback(replaceOperators, dontOverloadAssignOperator))))
        };
      }
      case EVars(vars):
      {
        return
        {
          pos: expr.pos,
          expr: EVars(Lambda.array(Lambda.map(vars, function(element)
          {
            return
            {
              name: element.name,
              type: element.type,
              expr: element.expr == null ? null : replaceOperators(dontOverloadAssignOperator, element.expr)
            };
          })))
        };
      }
      case EFunction(name, f):
      {
        return expr;
      }
      case EBlock(exprs):
      {
        return
        {
          pos: expr.pos,
          expr: EBlock(Lambda.array(Lambda.map(exprs, callback(replaceOperators, dontOverloadAssignOperator))))
        };
      }
      case EFor(it, expr):
      {
        return
        {
          pos: expr.pos,
          expr: EFor(replaceOperators(dontOverloadAssignOperator, it), replaceOperators(dontOverloadAssignOperator, expr))
        };
      }
      case EIn(e1, e2):
      {
        return
        {
          pos: expr.pos,
          expr: EIn(replaceOperators(dontOverloadAssignOperator, e1), replaceOperators(dontOverloadAssignOperator, e2))
        };
      }
      case EIf(econd, eif, eelse):
      {
        return
        {
          pos: expr.pos,
          expr: EIf(
            replaceOperators(dontOverloadAssignOperator, econd),
            replaceOperators(dontOverloadAssignOperator, eif),
            eelse == null ? null : replaceOperators(dontOverloadAssignOperator, eelse))
        };
      }
      case EWhile(econd, e, normalWhile):
      {
        return
        {
          pos: expr.pos,
          expr: EWhile(replaceOperators(dontOverloadAssignOperator, econd), replaceOperators(dontOverloadAssignOperator, e), normalWhile)
        };
      }
      case ESwitch(e, cases, edef):
      {
        return
        {
          pos: expr.pos,
          expr: ESwitch(
            replaceOperators(dontOverloadAssignOperator, e),
            Lambda.array(Lambda.map(cases, function(element)
            {
              return
              {
                values: Lambda.array(Lambda.map(element.values, callback(replaceOperators, dontOverloadAssignOperator))),
                expr: replaceOperators(dontOverloadAssignOperator, element.expr)
              };
            })),
            edef == null ? null : replaceOperators(dontOverloadAssignOperator, edef))
        };
      }
      case ETry(e, catches):
      {
        return
        {
          pos: expr.pos,
          expr: ETry(
            replaceOperators(dontOverloadAssignOperator, e),
            Lambda.array(Lambda.map(catches, function(element)
            {
              return
              {
                name: element.name,
                type: element.type,
                expr: replaceOperators(dontOverloadAssignOperator, element.expr)
              };
            })))
        };
      }
      case EReturn(e):
      {
        return
        {
          pos: expr.pos,
          expr: EReturn(e == null ? null : replaceOperators(dontOverloadAssignOperator, e))
        };
      }
      case EBreak, EContinue:
      {
        return expr;
      }
      case EUntyped(e):
      {
        return
        {
          pos: expr.pos,
          expr: EUntyped(replaceOperators(dontOverloadAssignOperator, e))
        };
      }
      case EThrow(e):
      {
        return
        {
          pos: expr.pos,
          expr: EThrow(replaceOperators(dontOverloadAssignOperator, e))
        };
      }
      case ECast(e, t):
      {
        return
        {
          pos: expr.pos,
          expr: ECast(replaceOperators(dontOverloadAssignOperator, e), t)
        };
      }
      case EDisplay(e, isCall):
      {
        return
        {
          pos: expr.pos,
          expr: EDisplay(replaceOperators(dontOverloadAssignOperator, e), isCall)
        };
      }
      case EDisplayNew(t):
      {
        return expr;
      }
      case ETernary(econd, eif, eelse):
      {
        return
        {
          pos: expr.pos,
          expr: ETernary(
            replaceOperators(dontOverloadAssignOperator, econd),
            replaceOperators(dontOverloadAssignOperator, eif),
            replaceOperators(dontOverloadAssignOperator, eelse))
        };
      }
      case ECheckType(e, t):
      {
        return
        {
          pos: expr.pos,
          expr: ECheckType(replaceOperators(dontOverloadAssignOperator, e), t)
        };
      }
    	#if !haxe3
      case EType(e, field):
      {
        return
        {
          pos: expr.pos,
          expr: EType(replaceOperators(dontOverloadAssignOperator, e), field)
        };
      }
      #end
    }
  }
  #end

  @:noUsing @:macro public static function enable(expr:Expr, ?dontOverloadAssignOperator:Bool = false):Expr
  {
    return replaceOperators(dontOverloadAssignOperator, expr);
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
}
