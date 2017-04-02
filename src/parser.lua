local class = require("class")
local common = require("common")

local M = {}

local Result = class(function (r, value, pos)
  -- Value of the AST
  r.value = value
  -- Index of the next token in the stream.
  r.pos = pos
end)
function Result:__tostring()
  return string.format("Result(%s, %d)", self.value, self.pos)
end
function Result:__eq(other)
  if type(self.value) ~= type(other.value) or self.pos ~= other.pos then
    return false
  end

  if type(self.value) == "table" then
    return common.tableEq(self.value, other.value)
  else
    return self.value == other.value
  end
end
M.Result = Result

-- Parse reserved words and operators as Result
M.Reserved = class(function (r, value, tag)
  r.value = value
  r.tag = tag
end)
function M.Reserved:__call(tokens, pos)
  local currentToken = tokens[pos]
  -- Check matching token
  if pos <= #tokens and 
    currentToken.value == self.value and currentToken.tag == self.tag then
    return Result(self.value, pos + 1)
  else
    return nil
  end
end

M.Tag = class(function (t, tag)
  t.tag = tag
end)
function M.Tag:__call(tokens, pos)
  local currentToken = tokens[pos]
  -- Check matching token
  if pos <= #tokens and currentToken.tag == self.tag then
    return Result(currentToken.value, pos + 1)
  else
    return nil
  end
end

M.Concat = class(function (c, left, right)
  c.left = left
  c.right = right
end)
function M.Concat:__call(tokens, pos)
  local leftResult = self.left(tokens, pos)
  if leftResult then
    local rightResult = self.right(tokens, leftResult.pos)
    if rightResult then
      return Result({leftResult.value, rightResult.value}, rightResult.pos)
    end
  end
  return nil
end

M.Alternate = class(function (a, left, right)
  a.left = left
  a.right = right
end)
function M.Alternate:__call(tokens, pos)
  local leftResult = self.left(tokens, pos)
  if leftResult then
    return leftResult
  else
    return self.right(tokens, pos)
  end
end

M.Opt = class(function (o, parser)
  o.parser = parser
end)
function M.Opt:__call(tokens, pos)
  local result = self.parser(tokens, pos)
  if result then
    return result
  else
    return Result(nil, pos)
  end
end

-- Apply an input parser repeatedly until it fails.
M.Rep = class(function (r, parser)
  r.parser = parser
end)
function M.Rep:__call(tokens, pos)
  local results = {}
  local result = self.parser(tokens, pos)
  local updatedPos = pos
  while result do
    results[#results + 1] = result.value
    updatedPos = result.pos
    result = self.parser(tokens, updatedPos)
  end
  return Result(results, updatedPos)
end

M.Process = class(function (p, parser, map)
  p.parser = parser
  p.map = map
end)
function M.Process:__call(tokens, pos)
  local result = self.parser(tokens, pos)
  if result then
    -- Map the result value.
    result.value = self.map(result.value)
  end
  return result
end

M.Lazy = class(function (l, parserFunction)
  l.parserFunction = parserFunction
end)
function M.Lazy:__call(tokens, pos)
  if not self.parser then
    self.parser = self.parserFunction()
  end
  return self.parser(tokens, pos)
end

M.Phrase = class(function (p, parser)
  p.parser = parser
end)
function M.Phrase:__call(tokens, pos)
  local result = self.parser(tokens, pos)
  -- Consume all available tokens
  if result and result.pos == #tokens + 1 then
    return result
  else
    return nil
  end
end

M.Exp = class(function (e, parser, separator)
  e.parser = parser
  -- Separator returns a function combining elements parsed on left and right in single value
  e.separator = separator
end)
function M.Exp:__call(tokens, pos)
  local result = self.parser(tokens, pos)
  -- Create a closure over result so this function can be used in Process.
  local function processNext(parsed)
    -- parsed is an array of two elements from Concat
    sepfunc = parsed[1]
    right = parsed[2]
    return sepfunc(result.value, right)
  end

  local nextParser = M.Process(M.Concat(self.separator, self.parser), processNext)
  local nextResult = result
  while nextResult ~= nil do
    nextResult = nextParser(tokens, result.pos)
    if nextResult ~= nil then
      result = nextResult
    end
  end
  return result
end

return M
