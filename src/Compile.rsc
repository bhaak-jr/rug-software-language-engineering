module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library

/*
 * Compiler for QL to HTML and Javascript
 *
 * - Assumes the form is type- and name-correct
 * - Separates the compiler in two parts, form2html and form2js, producing 2 files
 * - Uses string templates to generate Javascript
 * - Uses the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - Use plain javascript for for event handling
 * - Maps booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - Computed questions are uneditable by the user
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

HTML5Node form2html(AForm f) =
  html(
    head(
      meta(charset("utf-8")),
      title("Questionnaire: <f.name>")),
    body(
      table([ question2html(q) | /AQuestion q := f.questions , q has def ]),
      script(src("<f.src[extension="js"].file>"))));

HTML5Node question2html(AQuestion q) =
  tr(td(q.label), td((q has expr
    ? input(type2html(q.\type), id("_" + q.def.name), disabled(""))
    : input(type2html(q.\type), id("_" + q.def.name)))));

HTML5Attr type2html(\bool()) = \type("checkbox");
HTML5Attr type2html(\int()) = \type("number");
default HTML5Attr type2html(AType _) = \type("text");

str form2js(AForm f) =
  "function update() {
  '  <for (AQuestion q <- f.questions) {>
  '  <question2js(q)>
  '  <}>
  '}
  '
  'function setVisibility(q, v) {
  '  return document.getElementById(q).closest(\'tr\').style.visibility = v;
  '}
  '
  'function getValue(q) {
  '  return (document.getElementById(q).type === \'checkbox\'
  '    ? document.getElementById(q).checked : document.getElementById(q).value);
  '}
  '
  'function setValue(q, x) {
  '  (document.getElementById(q).type === \'checkbox\'
  '    ? document.getElementById(q).checked = x : document.getElementById(q).value = x);
  '}
  '
  'document.querySelectorAll(\'input\').forEach(item =\> {
  '  item.addEventListener(\'input\', update);
  '})
  '
  'update();\n";

str question2js(AQuestion q) {
  str js = "";
  if (q has expr)
    js += "setValue(\'_<q.def.name>\', <expr2js(q.expr)>);";
  if (q has ifQuestions)
    js += question2js(q.ifQuestions, q.condition);
  if (q has elseQuestions)
    js += question2js(q.elseQuestions, not(q.condition));
  return js;
}

str question2js(list[AQuestion] qs, AExpr e) =
  "if (<expr2js(e)>) {
  '<for (AQuestion q <- qs) {>
  '  <question2js(q)>
  '<}>
  '<for (AQuestion q <- qs, q has def) {>
  '  setVisibility(\'_<q.def.name>\', \'visible\');
  '<}>
  '} else {
  '<for (/AQuestion q := qs, q has def) {>
  '  setVisibility(\'_<q.def.name>\', \'collapse\');
  '<}>
  '}\n";

str expr2js(AExpr e) {
  switch (e) {
    case ref(id(str x)): return "getValue(\'_<x>\')";
    case \bool(bool b): return "<b>";
    case \int(int n): return "<n>";
    case \str(str s): return "<s>";
    case par(AExpr e): return "(<expr2js(e)>)";
    case not(AExpr e): return "!<expr2js(e)>";
    case mul(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> * <expr2js(rhs)>";
    case div(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> / <expr2js(rhs)>";
    case add(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> + <expr2js(rhs)>";
    case sub(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> - <expr2js(rhs)>";
    case le(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> \< <expr2js(rhs)>";
    case leq(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> \<= <expr2js(rhs)>";
    case gr(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> \> <expr2js(rhs)>";
    case geq(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> \>= <expr2js(rhs)>";
    case eq(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> === <expr2js(rhs)>";
    case neq(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> !== <expr2js(rhs)>";
    case and(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> && <expr2js(rhs)>";
    case or(AExpr lhs, AExpr rhs):
      return "<expr2js(lhs)> || <expr2js(rhs)>";
    default: throw "Unsupported expression <e>";
  }
}
