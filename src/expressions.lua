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

M.AndBexp = class(Equality, function(r, left, right)
  r.left = left
  r.right = right
end)
function M.AndBexp:__tostring()
  return string.format("AndBexp(%s, %s)", self.left, self.right)
end

M.OrBexp = class(Equality, function(r, left, right)
  r.left = left
  r.right = right
end)
function M.OrBexp:__tostring()
  return string.format("OrBexp(%s, %s)", self.left, self.right)
end

M.NotBexp = class(Equality, function(bexp, exp)
  bexp.exp = exp
end)
function M.NotBexp:__tostring()
  return string.format("NotBexp(%s)", self.exp)
end

M.AssignStatement = class(Equality, function(stmt, name, aexp)
  stmt.name = name
  stmt.aexp = aexp
end)
function M.AssignStatement:__tostring()
  return string.format("AssignStatement(%s, %s)", self.name, self.aexp)
end

M.CompoundStatement = class(Equality, function(stmt, first, second)
  stmt.first = first
  stmt.second = second
end)
function M.CompoundStatement:__tostring()
  return string.format("CompoundStatement(%s, %s)", self.first, self.second)
end

M.IfStatement = class(Equality, function(stmt, condition, trueStmt, falseStmt)
  stmt.condition = condition
  stmt.trueStmt = trueStmt
  stmt.falseStmt = falseStmt
end)
function M.IfStatement:__tostring()
  return string.format(
    "IfStatement(%s, %s, %s)",
    self.condition,
    self.trueStmt,
    self.falseStmt
  )
end

M.WhileStatement = class(Equality, function(stmt, condition, body)
  stmt.condition = condition
  stmt.body = body
end)
function M.WhileStatement:__tostring()
  return string.format("WhileStatement(%s, %s)", self.condition, self.body)
end

return M
