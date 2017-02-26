require("init")
local lexer = require("lexer")
local inspect = require("inspect")

local test = require 'unittest'

local TOKEN_ASSIGNMENT = 1
local TOKEN_VARIABLE = 2
local TOKEN_NUMBER = 3


function compareTokenList(list1, list2)
  -- Assume the list length are normal arrays.
  if #list1 ~= #list2 then
    return false
  end
  for index, token in ipairs(list1) do
    if token ~= list2[index] then
      print(token)
      print(list2[index])
      print(token .. ' is not ' .. list2[index])
      return false
    end
  end
  return true
end

if pcall(function () 
  lexer.lex("x := 1", {{"fail", 1}})
end) then
  print("Should have created an error")
end

-- Test 2: Assignment

result = lexer.lex(
  "abc := 1", 
  { 
    {"%a+", TOKEN_VARIABLE}, 
    {":=", TOKEN_ASSIGNMENT},
    {" "},
    {"%d", TOKEN_NUMBER}
  }
) 
assert(
  compareTokenList(result, {
    lexer.Token("abc", TOKEN_VARIABLE),
    lexer.Token(":=", TOKEN_ASSIGNMENT), 
    lexer.Token("1", TOKEN_NUMBER)
  }), 
  "could not parse assignment " .. inspect(result)
)

test.addTest('Token:toString', function()
  local t = lexer.Token("value", "tag")
  test.assertEqual(tostring(t), "Token(value, tag)")
end)

test.runTests()
