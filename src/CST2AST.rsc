module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Mapping from CST to AST
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("<f.name>", [ cst2ast(q) | q <- f.questions ], src=f@\loc);
}

AQuestion cst2ast(Question q) {
  switch (q) {
    case (Question)`<Str s> <Id x> : <Type t>`:
      return question("<s>"[1..-1], cst2ast(x), cst2ast(t), src=q@\loc);
    case (Question)`<Str s> <Id x> : <Type t> = <Expr e>`:
      return computed("<s>"[1..-1], cst2ast(x), cst2ast(t), cst2ast(e), src=q@\loc);
    case (Question)`if ( <Expr e> ) { <Question* qs> }`:
      return conditional(cst2ast(e), [cst2ast(q) | Question q <- qs], src=q@\loc);
    case (Question)`if ( <Expr e> ) { <Question* iqs> } else { <Question* eqs> }`:
      return extended(cst2ast(e), [cst2ast(q) | Question q <- iqs],
                      [cst2ast(q) | Question q <- eqs], src=q@\loc);
    default: throw "Unhandled question: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(cst2ast(x), src=x@\loc);
    case (Expr)`<Str s>`: return \str("<s>"[1..-1], src=s@\loc);
    case (Expr)`<Int i>`: return \int(toInt("<i>"), src=i@\loc);
    case (Expr)`<Bool b>`: return \bool((Bool)`true` := b, src=b@\loc);
    case (Expr)`( <Expr ex> )`: return par(cst2ast(ex), src=ex@\loc);
    case (Expr)`! <Expr ex>`: return not(cst2ast(ex), src=ex@\loc);
    case (Expr)`<Expr lhs> * <Expr rhs>`:
      return mul(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> / <Expr rhs>`:
      return div(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> + <Expr rhs>`:
      return add(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> - <Expr rhs>`:
      return sub(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \< <Expr rhs>`:
      return le(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \<= <Expr rhs>`:
      return leq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \> <Expr rhs>`:
      return gr(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \>= <Expr rhs>`:
      return geq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> == <Expr rhs>`:
      return eq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> != <Expr rhs>`:
      return neq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> && <Expr rhs>`:
      return and(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> || <Expr rhs>`:
      return or(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    default: throw "Unhandled expression: <e>";
  }
}

AId cst2ast(Id x) {
  return id("<x>", src=x@\loc);
}

AType cst2ast(Type t) {
  switch (t) {
    case (Type)`boolean`: return \bool(src=t@\loc);
    case (Type)`integer`: return \int(src=t@\loc);
    case (Type)`string`: return \str(src=t@\loc);
    default: throw "Unhandled type: <t>";
  }
}
