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

t.runTests()
