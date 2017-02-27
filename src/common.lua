local M = {}

-- Simple table equality
function M.tableEq(t1, t2)
  if #t1 ~= #t2 then
    return false
  else
    -- Check all keys and values to see if they compare.
    for key, value in pairs(t1) do
      local t2Value = t2[key]
      if type(t2Value) == "table" then
        if not M.tableEq(value, t2Value) then
          return false
        end
      elseif t2Value ~= value then
        return false
      end
    end
  end
  return true
end

return M
