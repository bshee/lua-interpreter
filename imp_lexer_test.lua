local lexer = require("imp_lexer")
local inspect = require("inspect")

function tokenExpr(pattern, tag)
  return {pattern, tag}
end

function compare(table1, table2)
  -- cheat by using inspect because screw the rules!
  return inspect(table1) == inspect(table2)
end

-- Test 2: Assignment
result = lexer.lex(
  "abc := 139"
) 
assert(
  compare(result, {{"abc", lexer.ID}, {":=", lexer.RESERVED}, {"139", lexer.INT}}), 
  "could not parse assignment " .. inspect(result)
)

print("All tests passed. Maybe a library should be used.")
