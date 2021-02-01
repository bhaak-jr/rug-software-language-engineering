module Example

import CST2AST;
import Eval;
import Resolve;
import Syntax;
import Transform;

import IO;
import ParseTree;

/*
 * Example usages of various features
 */

void evalExample() {
  loc l = |project://rug-software-language-engineering/examples/tax.myql|;
  ast = cst2ast(parse(#start[Form], l));
  
  VEnv venv = initialEnv(ast);
  venv = eval(ast, input("hasSoldHouse", vbool(true)), venv);
  venv = eval(ast, input("sellingPrice", vint(500)), venv);
  venv = eval(ast, input("privateDebt", vint(300)), venv);
  println(venv); // "valueResidue" should be vint(200)
}

void renameExample() {
  loc l = |project://rug-software-language-engineering/examples/tax.myql|;
  pt = parse(#start[Form], l);
  rg = resolve(cst2ast(pt));

  // use of "privateDebt"
  loc use = |project://rug-software-language-engineering/examples/tax.myql|(462,11,<20,45>,<20,56>);
  // def of "sellingPrice"
  loc def = |project://rug-software-language-engineering/examples/tax.myql|(307,12,<16,6>,<16,18>);

  pt = rename(pt, use, "privateDebtNew", rg.useDef); // "privateDebt" should now be "privateDebtNew"
  pt = rename(pt, def, "sellingPriceNew", rg.useDef); // "sellingPrice" should now be "sellingPriceNew"
  println(pt);
}
