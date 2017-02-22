local module = {}

require 'class'

local Token = class(function(t, value, tag)
  t.value = value
  t.tag = tag
end)

function Token:__tostring()
  return string.format("Token(%s, %s)", self.value, self.tag)
end

function Token:__eq(other)
  return self.value == other.value and self.tag == other.tag
end

module.Token = Token

function module.lex(characters, tokenExpressions)
  local pos = 1
  local tokens = {}
  local length = string.len(characters)
  while pos <= length do
    local tag, startMatch, endMatch
    for _, expression in ipairs(tokenExpressions) do
      local pattern = expression[1]
      tag = expression[2]
      -- Match only the beginning of the string.
      startMatch, endMatch = characters:find("^" .. pattern, pos)
      if startMatch == pos then
        break
      end
    end
    if startMatch then
      -- Store the token if it had a tag.
      if tag ~= nil then
        tokens[#tokens + 1] = Token(characters:sub(startMatch, endMatch), tag)
      end
      pos = endMatch + 1
    else
      error("Illegal character \"" .. characters:sub(pos, pos) .. "\" at " .. pos)
    end
  end
  return tokens
end

return module
