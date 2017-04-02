#!/usr/bin/env lua

require("init")
local lexer = require("imp_lexer")
local parser = require("imp_parser")

-- TODO: Figure out how to read from sysarg
local filepath = "factorial.imp"

io.input(filepath)
local text = io.read("*all")

local tokens = lexer.lex(text)
local parseResult = parser.parse(tokens)

if parseResult == nil then
  -- TODO: Should have error handling.
  error("Parse error")
end

local ast = parseResult.value
local env = {}
ast:eval(env)

print("Final variable values:")
for name, value in pairs(env) do
  print(string.format("%s: %s", name, value))
end

