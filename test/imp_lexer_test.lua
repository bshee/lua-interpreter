require("init")
local common = require("common")
local lexer = require("imp_lexer")
local Token = require("Token")
local test = require("unittest")

test.addTest("assignment", function()
  result = lexer.lex(
    "abc := 139"
  ) 
  assert(
    common.tableEq(result, {
      Token("abc", lexer.ID), 
      Token(":=", lexer.RESERVED), 
      Token("139", lexer.INT)
    })
  )
end)

test.runTests()

