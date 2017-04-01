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

-- TODO: This could be local?
M.processGroup = function(parsed)
  -- Destructure parsed from the Concat result.
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

return M
