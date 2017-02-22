local test = require 'unittest'
local parser = require 'parser'

test.addTest(function()
  -- Test result toString
  local r = parser.Result("value", 2)
  test.assertEqual(tostring(r), "Result(value, 2)")
end)

test.addTest(function()
  -- Test result equality
  local r1 = parser.Result("value", 2)
  local r2 = parser.Result("value", 2)
  test.assertEqual(r1, r2)
end)

test.runTests()
