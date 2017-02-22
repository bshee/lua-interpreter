-- Inserts a global function class
--
-- Trying to ease the process of making classes
function class(base, init)
  -- Table to store the class info. The class is really a metatable for all objects.
  local classTable = {}
  -- Handle the base class being optional
  if not init and type(base) == 'function' then
    init = base
    base = nil
  elseif type(base) == 'table' then
    -- Shallow copy
    for key, value in pairs(base) do
      classTable[key] = value
    end
    -- Store reference to the base class.
    classTable._base = base
  end

  classTable.__index = classTable
  -- A constructor for the class.
  local mt = {}
  mt.__call = function(_, ...)
    local object = {}
    setmetatable(object, classTable)
    if init then
      init(object, ...)
    else
      if base and base.init then
        base.init(object, ...)
      end
    end
    return object
  end
  classTable.init = init
  function classTable:isInstanceOf(klass)
    local m = getmetatable(self)
    while m do
      if m == klass then return true end
      m = m._base
    end
  end
  setmetatable(classTable, mt)
  return classTable
end
