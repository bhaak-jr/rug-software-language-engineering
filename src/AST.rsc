module AST

/*
 * Abstract Syntax of QL
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str label, AId def, AType \type)
  | computed(str label, AId def, AType \type, AExpr expr)
  | conditional(AExpr condition, list[AQuestion] ifQuestions)
  | extended(AExpr condition, list[AQuestion] ifQuestions, list[AQuestion] elseQuestions)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | \bool(bool boolean)
  | \int(int integer)
  | \str(str string)
  | par(AExpr expr)
  | not(AExpr expr)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | sub(AExpr lhs, AExpr rhs)
  | le(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | gr(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | eq(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = \bool()
  | \int()
  | \str()
  ;
