require("init")
local t = require("unittest")
local e = require("expressions")

t.addTest("Equality compare", function()
  local e1 = e.Equality()
  e1.x = "x"
  e1.y = 1
  local e2 = e.Equality()
  e2.x = "x"
  e2.y = 1
  t.assertEqual(e1, e2)
end)

t.addTest("IntAexp tostring", function()
  local ia = e.IntAexp(13)
  t.assertEqual(tostring(ia), "IntAexp(13)")
end)

t.addTest("VarAexp tostring", function()
  local va = e.VarAexp("x")
  t.assertEqual(tostring(va), "VarAexp(x)")
end)

t.addTest("BinopAexp tostring", function()
  local b = e.BinopAexp("+", "1", "2")
  t.assertEqual(tostring(b), "BinopAexp(+, 1, 2)")
end)

t.addTest("RelopBexp tostring", function()
  local b = e.RelopBexp("<", "1", "2")
  t.assertEqual(tostring(b), "RelopBexp(<, 1, 2)")
end)

t.addTest("AndBexp tostring", function()
  local b = e.AndBexp(true, false)
  t.assertEqual(tostring(b), "AndBexp(true, false)")
end)

t.addTest("OrBexp tostring", function()
  local b = e.OrBexp(true, false)
  t.assertEqual(tostring(b), "OrBexp(true, false)")
end)

t.addTest("NotBexp tostring", function()
  local b = e.NotBexp(true)
  t.assertEqual(tostring(b), "NotBexp(true)")
end)

t.addTest("AssignStatement tostring", function()
  local s = e.AssignStatement("x", 1)
  t.assertEqual(tostring(s), "AssignStatement(x, 1)")
end)

t.addTest("CompoundStatement tostring", function()
  local s = e.CompoundStatement("x = 1", "y = 2")
  t.assertEqual(tostring(s), "CompoundStatement(x = 1, y = 2)")
end)

t.addTest("IfStatement tostring", function()
  local s = e.IfStatement("x > 0", "y = -1", "y = 1")
  t.assertEqual(tostring(s), "IfStatement(x > 0, y = -1, y = 1)")
end)

t.addTest("WhileStatement tostring", function()
  local s = e.WhileStatement("x == 0", "x += 1")
  t.assertEqual(tostring(s), "WhileStatement(x == 0, x += 1)")
end)
t.runTests()
