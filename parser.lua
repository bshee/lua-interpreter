require 'class'

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
  return self.value == other.value and self.pos == other.pos
end

-- Parse reserved words and operators as Result
-- local Reserved = class(Result), has value and tag.
-- tokens are value / tag pairs
local function reserved(value, tag, tokens, pos)
  local currentToken = tokens[pos]
  -- Check matching token
  if pos < tokens:len() and currentToken[0] == value and currentToken[1] == tag then
    return Result(value, pos + 1)
  else
    return nil
  end
end

local function tag(tag, tokens, pos)
  local currentToken = tokens[pos]
  -- Check matching token
  if pos < tokens:len() and currentToken[1] == tag then
    return Result(value, pos + 1)
  else
    return nil
  end
end

local function concat(left, right, tokens, pos)
  local leftResult = left(tokens, pos)
  if leftResult then
    local rightResult = right(tokens, leftResult.pos)
    if rightResult then
      return Result({leftResult.value, rightResult.value}, rightResult.pos)
    end
  end
  return nil
end

local function alternate(left, right, tokens, pos)
  local leftResult = left(tokens, pos)
  if leftResult then
    return leftResult
  else
    return right(tokens, pos)
  end
end

local function opt(parser, tokens, pos)
  local result = parser(tokens, pos)
  if result then
    return result
  else
    return Result(nil, pos)
  end
end

-- Apply an input parser repeatedly until it fails.
local function rep(parser, tokens, pos)
  local results = []
  local result = parser(tokens, pos)
  while result do
    results[#results + 1] = result
    -- Update position
    pos = result.pos
    result = parser(tokens, pos)
  end
  return Result(results, pos)
end

return {
  Result = Result,
  reserved = reserved,
  tag = tag,
  concat = concat,
  alternate = alternate,
  opt = opt,
  rep = rep
}

