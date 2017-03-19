local il = require("imp_lexer")
local ex = require("expressions")
local pa = require("parser")

local M = {}

M.keyword = function(keyword)
  return pa.Reserved(keyword, il.RESERVED)
end

M.id = pa.Tag(il.ID)

M.num = pa.Process(pa.Tag, function(i) return tonumber(i) end)

return M
