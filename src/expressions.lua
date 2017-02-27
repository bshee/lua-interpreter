require 'class'
local class = class

-- Arithmetic expressions
-- Seems useless?
local Aexp = class()

local IntAexp = class(
  function (a, value)
    a.value = value
  end
)

local VarAexp = {}
function VarAexp:new(name)
  local object = {name = name}
  return object
end
