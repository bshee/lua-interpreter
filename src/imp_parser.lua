local il = require("imp_lexer")
local ex = require("expressions")
local pa = require("parser")

local M = {}

M.keyword = function(keyword)
  return pa.Reserved(keyword, il.RESERVED)
end

M.id = pa.Tag(il.ID)

M.num = pa.Process(pa.Tag, tonumber)
  --function(i) return tonumber(i) end)

M.aexpValue = function()
  return pa.Alternate(
    pa.Process(M.num, function(i) return ex.IntAexp(i) end),
    pa.Process(M.id, function(v) return ex.VarAexp(v) end)
  )
end

  -- Destructure parsed from the Concat result of parentheses.
M.processGroup = function(parsed)
  local inner = parsed[1]
  return inner[2]
end

M.aexpGroup = function()
  return pa.Process(
    pa.Concat(
      pa.Concat(M.keyword("("), pa.Lazy(aexp)),
      M.keyword(")")
    ),
    M.processGroup
  )
end

M.aexpTerm = function()
  return pa.Alternate(aexpValue(), aexpGroup())
end

-- A factory function to create BinopAexp instances for use with Exp.
M.processBinop = function(op)
  return function(left, right) return ex.BinopAexp(op, left, right) end
end

-- Determine if any operators are in the list.
M.anyOperatorInList = function(ops)
  local length = #ops
  if length <= 1 then
    return nil
  end
  -- Reduce the parser into alternates.
  local parser = M.keyword(ops[1])
  for index, op in ipairs(ops) do
    if index > 1 then
      parser = pa.Alternate(parser, M.keyword(op))
    end
  end
  return parser
end

M.aexpPrecedenceLevels = {
  {"*", "/"},
  {"+", "-"}
}

M.precedence = function(valueParser, precedenceLevels, combine)
  local opParser = function(precedenceLevel)
    return pa.Process(M.anyOperatorInList(precedenceLevel), combine)
  end
  -- Screw safety checks! TODO: Add them.
  local parser = pa.Exp(valueParser, precedenceLevels[1])
  for index, precedenceLevel in ipairs(precedenceLevels) do
    if index > 1 then
      parser = pa.Exp(parser, opParser(precedenceLevel))
    end
  end
  return parser
end

M.aexp = function()
  return M.precedence(M.aexpTerm(), M.aexpPrecedenceLevels, M.processBinop)
end

-- Helper function to deconstruct Concat result.
M.processRelop = function(parsed)
  local inner = parsed[1]
  local left = inner[1]
  local op = inner[2]
  local right = parsed[2]
  return ex.RelopBexp(op, left, right)
end

M.relops = {
  "<",
  "<=",
  ">",
  ">=",
  "=",
  "!="
}

M.bexpRelop = function()
  return pa.Process(
    pa.Concat(
      pa.Concat(M.aexp(), M.anyOperatorInList(M.relops)),
      M.aexp()
    ),
    M.processRelop
  )
end

M.bexpNot = function()
  return pa.Process(
    pa.Concat(
      M.keyword("not"),
      pa.Lazy(M.bexpTerm)
    ),
    function(parsed) return ex.NotBexp(parsed[2]) end
  )
end

M.bexpGroup = function()
  return pa.Process(
    pa.Concat(
      pa.Concat(M.keyword("("), pa.Lazy(M.bexp)),
      M.keyword(")")
    ),
    M.processGroup
  )
end

M.bexpTerm = function()
  return pa.Alternate(pa.Alternate(M.bexpNot(), M.bexpRelop()), M.bexpGroup())
end

M.bexpPrecedenceLevels = {
  {"and"},
  {"or"}
}

M.processLogic = function(op)
  if op == 'and' then
    return ex.AndBexp
  elseif op == 'or' then
    return ex.OrBexp
  else
    error("Unknown logic operator: " + op)
  end
end

M.bexp = function()
  return M.precedence(M.bexpTerm(), M.bexpPrecedenceLevels, M.processLogic)
end

M.processAssignStmt = function(parsed)
  local inner = parsed[1]
  local name = inner[1]
  local exp = parsed[2]
  -- Ignore the assign operator.
  return ex.AssignStatement(name, exp)
end

M.assignStmt = function()
  return pa.Process(
    pa.Concat(
      pa.Concat(M.id, M.keyword(":=")),
      M.aexp()
    ),
    M.processAssignStmt
  )
end

M.stmtListSeparator = pa.Process(
  M.keyword(";"),
  -- Parameter passed here doesn't matter.
  function()
    return function(left, right)
      return ex.CompoundStatement(left, right)
    end
  end
)

M.stmtList = function()
  return pa.Exp(M.stmt(), M.stmtListSeprator)
end

M.processIfStmt = function(parsed)
  local level1 = parsed[1]
  local falseParsed = level1[2]
  local level2 = level1[1]
  local trueStmt = level2[2]
  local level3 = level2[1]
  local level4 = level3[1]
  local condition = level4[2]
  local falseStmt = nil
  if falseParsed then
    -- There was a false body.
    falseStmt = falseParsed[2]
  end
  return ex.IfStatement(condition, trueStmt, falseStmt)
end

M.ifStmt = function()
  return pa.Process(
    pa.Concat(
      pa.Concat(
        pa.Concat(
          pa.Concat(
              pa.Concat(M.keyword("if"), M.bexp()),
              M.keyword("then")
            ),
            pa.Lazy(M.stmtList)
        ),
        pa.Opt(pa.Concat(M.keyword("else"), pa.Lazy(M.stmtList)))
      ),
      M.keyword("end")
    ),
    M.processIfStmt
  )
end

M.processWhileStmt = function(parsed)
  local level1 = parsed[1]
  local body = level1[2]
  local level2 = level1[1]
  local level3 = level2[1]
  local condition = level3[2]
  return ex.WhileStatement(condition, body)
end

M.whileStmt = function()
  return pa.Process(
    pa.Concat(
      pa.Concat(
        pa.Concat(
          pa.Concat(M.keyword("while"), M.bexp()),
          M.keyword("do")
        ),
        pa.Lazy(M.stmtList)
      ),
      M.keyword("end")
    ),
    M.processWhileStmt
  )
end

M.stmt = function()
  return pa.Alternate(
    pa.Alternate(M.assignStmt(), M.ifStmt()),
    pa.whileStmt()
  )
end

M.parser = function()
  return pa.Phrase(M.stmtList())
end

M.impParse = function(tokens)
  local ast = M.parser()(tokens, 1)
  return ast
end

return M
