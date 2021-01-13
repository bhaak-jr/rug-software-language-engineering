module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 * NB: Assumes the form is type- and name-correct
 */

// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input = input(str question, Value \value);

// Produces an environment which for each question has a default value
VEnv initialEnv(AForm f)
  = ( q.def.name: \default(q.\type) | /AQuestion q := f, q has \type );

Value \default(\bool()) = vbool(false);
Value \default(\int()) = vint(0);
Value \default(\str()) = vstr("");

// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) = initialEnv(f)
  + ( venv | eval(q, inp, it) | AQuestion q <- f.questions );

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  if (q has condition) {
    if (eval(q.condition, venv).b) {
      for (qu <- q.ifQuestions)
        venv = eval(qu, inp, venv);
    } else if (q has elseQuestions) {
      for (qu <- q.elseQuestions)
        venv = eval(qu, inp, venv);
    }
  }

  // evaluate inp and computed questions to return updated VEnv
  if (q has def && q.def.name == inp.question)
    venv[q.def.name] = inp.\value;
  else if (q has expr)
    venv[q.def.name] = eval(q.expr, venv);

  return venv;
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case \bool(bool b): return vbool(b);
    case \int(int n): return vint(n);
    case \str(str s): return vstr(s);
    case par(AExpr e): return eval(e, venv);
    case not(AExpr e): return vbool(!eval(e, venv).b);
    case mul(AExpr lhs, AExpr rhs):
      return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    case div(AExpr lhs, AExpr rhs):
      return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case add(AExpr lhs, AExpr rhs):
      return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case sub(AExpr lhs, AExpr rhs):
      return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    case le(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    case leq(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    case gr(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    case geq(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case eq(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv) == eval(rhs, venv));
    case neq(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv) != eval(rhs, venv));
    case and(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case or(AExpr lhs, AExpr rhs):
      return vbool(eval(lhs, venv).b || eval(rhs, venv).b);
    default: throw "Unsupported expression <e>";
  }
}
