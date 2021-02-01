module Check

import AST;
import Resolve;
import Message; // see standard library

/*
 * Type checker for QL
 */

data Type
  = tbool()
  | tint()
  | tstr()
  | tunknown()
  ;

// The type environment consisting of defined questions in the form
alias TEnv = rel[loc def, str name, str label, Type \type];

// Using deep match to avoid recursively traversing the form
TEnv collect(AForm f)
  = { <q.def.src, q.def.name, q.label, toType(q.\type)> | /AQuestion q := f, q has def };

set[Message] check(AForm f, TEnv tenv, UseDef useDef)
  = ( {} | it + check(q, tenv, useDef) | /AQuestion q := f );

// Checks:
// - Duplicate question declarations with different type
// - Expression of computed question has wrong type
// - Conditions that are not of the type boolean
// - Duplicate labels (warning)
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef)
  = { error("Type mismatch between declared questions with same name", q.src)
    | t <- tenv, q has def, t.name == q.def.name, t.\type != toType(q.\type), t.def != q.def.src }
  + { error("Type mismatch between question and assigned expression", q.src)
    | t <- tenv, q has expr, t.def == q.def.src, t.\type != typeOf(q.expr, tenv, useDef) }
  + { error("Condition is not of the type Boolean", q.condition.src)
    | q has condition && typeOf(q.condition, tenv, useDef) != tbool() }
  + { warning("Declared questions with duplicate labels", q.src)
    | t <- tenv, q has label, t.label == q.label, t.def != q.def.src }
  + ( q has condition ? check(q.condition, tenv, useDef) : {} )
  + ( q has expr ? check(q.expr, tenv, useDef) : {} );

Type toType(\bool()) = tbool();
Type toType(\int()) = tint();
Type toType(\str()) = tstr();
default Type toType(AType _) = tunknown();

// Checks:
// - Reference to undefined questions
// - Operands of invalid type to operators
set[Message] check(ref(AId x), TEnv tenv, UseDef useDef)
  = { error("Undeclared question", x.src) | useDef[x.src] == {} };
default set[Message] check(AExpr e, TEnv tenv, UseDef useDef)
  = { error("Unknown expression type", e.src) | typeOf(e, tenv, useDef) == tunknown() };
  // TODO: Add specialized messages for every kind of expression

Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
  when <u, loc d> <- useDef, <d, _, _, Type t> <- tenv;

Type typeOf(\bool(bool _), TEnv _, UseDef _) = tbool();
Type typeOf(\int(int _), TEnv _, UseDef _) = tint();
Type typeOf(\str(str _), TEnv _, UseDef _) = tstr();

Type typeOf(par(AExpr expr), TEnv tenv, UseDef useDef) = typeOf(expr, tenv, useDef);

Type typeOf(not(AExpr expr), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(expr, tenv, useDef) == tbool();

Type typeOf(mul(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tint()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
Type typeOf(div(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tint()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
Type typeOf(add(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tint()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
Type typeOf(sub(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tint()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
  
Type typeOf(le(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
Type typeOf(leq(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
Type typeOf(gr(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();
Type typeOf(geq(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint();

Type typeOf(eq(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = typeOf(lhs, tenv, useDef)
  when typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef);
Type typeOf(neq(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = typeOf(lhs, tenv, useDef)
  when typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef);

Type typeOf(and(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef) == tbool();
Type typeOf(or(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool()
  when typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef) == tbool();
default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
