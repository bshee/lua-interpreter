local class = require("class")
local common = require("common")

local M = {}

-- Lazy way to compare classes that is used generically.
-- Would be more efficient to implement a __eq for each class.
local function lazyEq(self, other)
  return common.tableEq(self, other)
end

-- Arithmetic expressions
M.IntAexp = class(function (a, value)
  a.value = value
end)
function M.IntAexp:__tostring()
  return string.format("IntAexp(%d)", self.value)
end
function M.IntAexp:eval(env)
  return self.value
end
M.IntAexp.__eq = lazyEq

M.VarAexp = class(function(v, name)
  v.name = name
end)
function M.VarAexp:__tostring()
  return string.format("VarAexp(%s)", self.name)
end
function M.VarAexp:eval(env)
  if env[self.value] ~= nil then
    return env[self.value]
  else
    return 0
  end
end
M.VarAexp.__eq = lazyEq

M.BinopAexp = class(function(b, op, left, right)
  b.op = op
  b.left = left
  b.right = right
end)
function M.BinopAexp:__tostring()
  return string.format("BinopAexp(%s, %s, %s)", self.op, self.left, self.right)
end
do
  local opToFunction = {
    ["+"] = function(left, right) return left + right end,
    ["-"] = function(left, right) return left - right end,
    ["*"] = function(left, right) return left * right end,
    ["/"] = function(left, right) return left / right end,
  }
function M.BinopAexp:eval(env)
  if opToFunction[self.op] ~= nil then
    local leftValue = self.left.eval(env)
    local rightValue = self.right.eval(env)
    return opToFunction[self.op](leftValue, rightValue)
  else
    error("Unknown operator: " .. self.op)
  end
end
end
M.BinopAexp.__eq = lazyEq

M.RelopBexp = class(function(r, op, left, right)
  r.op = op
  r.left = left
  r.right = right
end)
function M.RelopBexp:__tostring()
  return string.format("RelopBexp(%s, %s, %s)", self.op, self.left, self.right)
end
M.RelopBexp.__eq = lazyEq

M.AndBexp = class(function(r, left, right)
  r.left = left
  r.right = right
end)
function M.AndBexp:__tostring()
  return string.format("AndBexp(%s, %s)", self.left, self.right)
end
M.AndBexp.__eq = lazyEq

M.OrBexp = class(function(r, left, right)
  r.left = left
  r.right = right
end)
function M.OrBexp:__tostring()
  return string.format("OrBexp(%s, %s)", self.left, self.right)
end
M.OrBexp.__eq = lazyEq

M.NotBexp = class(function(bexp, exp)
  bexp.exp = exp
end)
function M.NotBexp:__tostring()
  return string.format("NotBexp(%s)", self.exp)
end
M.NotBexp.__eq = lazyEq

M.AssignStatement = class(function(stmt, name, aexp)
  stmt.name = name
  stmt.aexp = aexp
end)
function M.AssignStatement:__tostring()
  return string.format("AssignStatement(%s, %s)", self.name, self.aexp)
end
M.AssignStatement.__eq = lazyEq

M.CompoundStatement = class(function(stmt, first, second)
  stmt.first = first
  stmt.second = second
end)
function M.CompoundStatement:__tostring()
  return string.format("CompoundStatement(%s, %s)", self.first, self.second)
end
M.CompoundStatement.__eq = lazyEq

M.IfStatement = class(function(stmt, condition, trueStmt, falseStmt)
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
M.IfStatement.__eq = lazyEq

M.WhileStatement = class(function(stmt, condition, body)
  stmt.condition = condition
  stmt.body = body
end)
function M.WhileStatement:__tostring()
  return string.format("WhileStatement(%s, %s)", self.condition, self.body)
end
M.WhileStatement.__eq = lazyEq

return M
