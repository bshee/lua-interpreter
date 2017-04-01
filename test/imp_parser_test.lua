require("init")
local pa = require("parser")
local ex = require("expressions")
local impPa = require("imp_parser")
local il = require("imp_lexer")
local t = require("unittest")
local Token = require("token")

t.addTest("keyword", function()
  local k = impPa.keyword("if")
  local tokens = {Token("if", il.RESERVED)}
  t.assertEqual(k(tokens, 1), pa.Result("if", 2))
end)

t.addTest("processGroup", function()
  local parsed = {{"(", 314}, ")"}
  t.assertEqual(impPa.processGroup(parsed), 314)
end)

t.addTest("processRelop", function()
  local parsed = {{"21", ">="}, "14"}
  t.assertEqual(impPa.processRelop(parsed), ex.RelopBexp(">=", "21", "14"))
end)

t.addTest("processLogic", function()
  t.assertEqual(
    impPa.processLogic("and")(true, true),
    ex.AndBexp(true, true)
  )
  t.assertEqual(
    impPa.processLogic("or")(false, true),
    ex.OrBexp(false, true)
  )
end)

t.addTest("processAssignStmt", function()
  local parsed = {{"x", ":="}, "apple"}
  t.assertEqual(impPa.processAssignStmt(parsed), ex.AssignStatement("x", "apple"))
end)

t.addTest("processIfStmt", function()
  local parsed1 = {
    {
      {
        {
          {"if", false},
          "then"
        },
        "x := 2"
      },
      {"else", "x := 3"}
    },
    "end"
  }
  t.assertEqual(impPa.processIfStmt(parsed1), ex.IfStatement(false, "x := 2", "x := 3"))
  local parsed2 = {
    {
      {
        {
          {"if", "true"},
          "then"
        },
        "y := 1"
      },
      nil
    },
    "end"
  }
  t.assertEqual(impPa.processIfStmt(parsed2), ex.IfStatement("true", "y := 1", nil))
end)

t.addTest("processWhileStmt", function()
  local parsed = {
    {
      {
        {
          "while",
          true
        },
        "do"
      },
      "x := x + 1"
    },
    "end"
  }
  t.assertEqual(impPa.processWhileStmt(parsed), ex.WhileStatement(true, "x := x + 1"))
end)

t.addTest("aexpValue number", function()
  local tokens = il.lex("123")
  local result = impPa.aexpValue()(tokens, 1)
  t.assertEqual(
    result,
    pa.Result(ex.IntAexp(123), 2)
  )
end)

t.addTest("aexpValue variable", function()
  local tokens = il.lex("wonderfulVariable")
  local result = impPa.aexpValue()(tokens, 1)
  t.assertEqual(
    result,
    pa.Result(ex.VarAexp("wonderfulVariable"), 2)
  )
end)

t.addTest("aexpGroup", function()
  local tokens = il.lex("(22)")
  local result = impPa.aexpGroup()(tokens, 1)
  t.assertEqual(
    result,
    pa.Result(ex.IntAexp(22), 4)
  )
end)

t.addTest("aexpTerm aexpValue", function()
  local tokens = il.lex("wonderfulVariable")
  local result = impPa.aexpTerm()(tokens, 1)
  t.assertEqual(
    result,
    pa.Result(ex.VarAexp("wonderfulVariable"), 2)
  )
end)

t.addTest("aexpTerm aexpGroup", function()
  local tokens = il.lex("(argh)")
  local result = impPa.aexpTerm()(tokens, 1)
  t.assertEqual(
    result,
    pa.Result(ex.VarAexp("argh"), 4)
  )
end)

t.runTests()
