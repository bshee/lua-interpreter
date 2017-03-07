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

M.BinopAexp = class(Equality, function(b, op, left, right)
  b.op = op
  b.left = left
  b.right = right
end)
function M.BinopAexp:__tostring()
  return string.format("BinopAexp(%s, %s, %s)", self.op, self.left, self.right)
end

M.RelopBexp = class(Equality, function(r, op, left, right)
  r.op = op
  r.left = left
  r.right = right
end)
function M.RelopBexp:__tostring()
  return string.format("RelopBexp(%s, %s, %s)", self.op, self.left, self.right)
end

return M
