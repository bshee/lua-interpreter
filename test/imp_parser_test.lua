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

t.runTests()
