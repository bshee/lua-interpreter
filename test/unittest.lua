local module = {}
local testDriver = {}
local testIndex = 1

function module.addTest(test, testName)
  -- Gracefully handle the test being the testName
  if type(test) == 'string' and type(testName) == 'function' then
    test, testName = testName, test
  end
  local key = testIndex
  if testName and type(testName) == 'string' then
    key = testName
  else
    testIndex = testIndex + 1
  end
  testDriver[key] = test
end

function module.assertEqual(quantity1, quantity2)
  if quantity1 ~= quantity2 then
    error(string.format(
      "left and right do not match: '%s' and '%s'",
      quantity1,
      quantity2
    ))
  end
  return true
end

local function countTests()
  local count = 0
  for _ in pairs(testDriver) do
    count = count + 1
  end
  return count
end

function module.runTests()
  local passed = 0 
  local total = countTests()
  print("Running " .. total .. " tests")
  for testName, test in pairs(testDriver) do
    local testPassed, errorMessage = pcall(test)
    if testPassed then
      passed = passed + 1
    else
      if type(testName) == 'string' then
        testName = "'" .. testName .. "'"
      end
      print(string.format(" -> Test %s failed with error: %s", testName, errorMessage))
    end
  end
  print(string.format("%0.2f%% test(s) passed", passed / total * 100 ))
end

return module
