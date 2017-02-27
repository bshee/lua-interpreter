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

return Token
