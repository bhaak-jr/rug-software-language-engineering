module Example

import IO;
import ParseTree;
import CST2AST;
import Eval;
import Syntax;

/*
 * Demonstration of Eval
 */

void example() {
  loc l = |project://rug-software-language-engineering/examples/tax.myql|;
  ast = cst2ast(parse(#start[Form], l));
  
  VEnv venv = initialEnv(ast);
  venv = eval(ast, input("hasSoldHouse", vbool(true)), venv);
  venv = eval(ast, input("sellingPrice", vint(500)), venv);
  venv = eval(ast, input("privateDebt", vint(300)), venv);
  println(venv); // "valueResidue" should be vint(200)
}
