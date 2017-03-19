require("init")
local pa = require("parser")
local impPa = require("imp_parser")
local il = require("imp_lexer")
local t = require("unittest")
local Token = require("token")

t.addTest("keyword", function()
  local k = impPa.keyword("if")
  local tokens = {Token("if", il.RESERVED)} 
  t.assertEqual(k(tokens, 1), pa.Result("if", 2))
end)

t.runTests()
