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
  inner = parsed[1]
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

return M
