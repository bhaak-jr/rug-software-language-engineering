module Transform

import Syntax;
import Resolve;
import AST;
import ParseTree;

/* 
 * Transforming QL forms
 */
 
 
/*
 * Normalization: performs a flattening transformation.
 */
 
AForm flatten(AForm f) {
  list[AQuestion] qs = f.questions;
  f.questions = [];

  for (AQuestion q <- qs)
    f.questions += flatten(\bool(true), q);
  
  return f;
}

list[AQuestion] flatten(AExpr c, AQuestion q) {
  list[AQuestion] qs = [];

  if (q has def)
    qs += conditional(c, [q]);
  if (q has ifQuestions) {
    for (AQuestion qu <- q.ifQuestions)
      qs += flatten(and(c, q.condition), qu);
    if (q has elseQuestions) {
      for (AQuestion qu <- q.elseQuestions)
        qs += flatten(and(c, not(q.condition)), qu);
    }
  }

  return qs;
}

/* 
 * Rename refactoring: consistently renames all occurrences of the same name.
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
  set[loc] rnTargets = { useOrDef };
  
  if (<useOrDef, loc d> <- useDef)
    rnTargets += { d } + { u | <loc u, d> <- useDef };
  
  if (<loc _, useOrDef> <- useDef)
    rnTargets += { u | <loc u, useOrDef> <- useDef };

  return visit(f) {
    case Id x => [Id]newName
      when x@\loc in rnTargets
  }
 }
