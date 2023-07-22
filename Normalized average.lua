---------------------------
-- 
-- FILE
--   Normalized average.lua
-- 
-- AUTHOR
--   Doug Zwick
-- 
-- CREATED
--   22 July 2023
-- 
-- Averages the FG and BG colors, normalizes the result in OpenGL normal map
-- space, reconverts that into RGB space, and sets the FG color to be that color
-- 
---------------------------


function NormalizedAverage(c0, c1)
  -- Normally we'd want to use the slerp function, but since we always want the
  -- exact midpoint, we can just average the values and then normalize the
  -- vector, and the result will be precisely the same as if we had slerped.
  local x = (c0.red   + c1.red)   / 2 -- in 0 to 255 range
  local y = (c0.green + c1.green) / 2 -- in 0 to 255 range
  local z = (c0.blue  + c1.blue)  / 2 -- in 0 to 255 range
  x = 2 * (x / 255) - 1 -- in -1.0 to 1.0 range
  y = 2 * (y / 255) - 1 -- in -1.0 to 1.0 range
  z = 2 * (z / 255) - 1 -- in -1.0 to 1.0 range
  local magnitude = math.sqrt(x * x + y * y + z * z)
  x = x / magnitude
  y = y / magnitude
  z = z / magnitude
  x = 255 * (x + 1) / 2 -- in 0 to 255 range
  y = 255 * (y + 1) / 2 -- in 0 to 255 range
  z = 255 * (z + 1) / 2 -- in 0 to 255 range
  return Color{ r = x, g = y, b = z, a = c0.alpha }
end

do
  local fg = app.fgColor
  local bg = app.bgColor
  app.fgColor = NormalizedAverage(fg, bg, 0.5)
end
