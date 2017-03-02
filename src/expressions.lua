local class = require("class")
local common = require("common")

local M = {}

-- Lazy way to compare classes. Would be more efficient to implement a __eq for each class.
M.Equality = class()
function M.Equality:__eq(other)
  return common.tableEq(self, other)
end

-- Arithmetic expressions
M.IntAexp = class(Equality, function (a, value)
  a.value = value
end)
function M.IntAexp:__tostring()
  return string.format("IntAexp(%d)", self.value)
end

M.VarAexp = class(Equality, function(v, name)
  v.name = name
end)
function M.VarAexp:__tostring()
  return string.format("VarAexp(%s)", self.name)
end

return M
