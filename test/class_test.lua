require("init")
require("class")
local unittest = require("unittest")

local A = class(function(a, value) a.value = value end)
function A:__tostring() 
  return "A: " .. self.value
end

unittest.addTest(function()
  -- testCreateObject()
  local a = A(3)
  unittest.assertEqual(a.value, 3)
end)

unittest.addTest(function()
  -- testToString()
  local a2 = A("hello")
  unittest.assertEqual(tostring(a2), "A: hello")
end)


local B = class(A, function(b, value, num)
  A.init(b, value)
  b.num = num
end)

unittest.addTest(function()
  -- testInheritance
  local b = B("something", 2)
  unittest.assertEqual(b.value, "something")
  unittest.assertEqual(b.num, 2)
end)

local BChild = class(B)

unittest.addTest(function()
  -- Test nested
  local b = BChild("value", 0)
  unittest.assertEqual(b.value, "value")
  unittest.assertEqual(b.num, 0)
end)

unittest.addTest(function()
  -- Test isInstanceOf
  local b = BChild()
  assert(b:isInstanceOf(A))
  assert(b:isInstanceOf(B))
  assert(b:isInstanceOf(BChild))
end)

unittest.runTests()
