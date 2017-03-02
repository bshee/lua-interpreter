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

t.addTest("IntAexp string", function()
  local ia = e.IntAexp(13)
  t.assertEqual(tostring(ia), "IntAexp(13)")
end)

t.runTests()
