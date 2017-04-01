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

return M
