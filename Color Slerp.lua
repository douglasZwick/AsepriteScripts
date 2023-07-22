---------------------------
-- 
-- FILE
--   Color Slerp.lua
-- 
-- AUTHOR
--   Doug Zwick
-- 
-- CREATED
--   22 July 2023
-- 
-- Converts the FG and BG colors into normal space points, then slerps halfway
-- between them, converts the result back into a color, and sets it that as the
-- new FG color.
-- 
---------------------------


function Dot(p0, p1)
  return p0.x * p1.x + p0.y * p1.y + p0.z * p1.z
end

function PointScale(n, p)
  return { x = p.x * n, y = p.y * n, z = p.z * n }
end

function PointSum(p0, p1)
  return { x = p0.x + p1.x, y = p0.y + p1.y, z = p0.z + p1.z }
end

function PointLerp(p0, p1, t)
  return { x = Lerp(p0.x, p1.x, t),
           y = Lerp(p0.y, p1.y, t),
           z = Lerp(p0.z, p1.z, t) }
end

function Magnitude(p)
  return math.sqrt(Dot(p, p))
end

function Normalize(p)
  return PointScale(1 / Magnitude(p), p)
end

function Slerp(p0, p1, t)
  p0 = Normalize(p0)
  p1 = Normalize(p1)
  local dot = Dot(p0, p1)

  if dot <= -0.999 then return { x = 0, y = 0, z = 1 } end
  if dot >= 0.999 then return PointLerp(p0, p1, t) end

  local o = math.acos(dot)
  local sine = math.sin(o)
  local leftScalar = math.sin((1 - t) * o) / sine
  local rightScalar = math.sin(t * o) / sine
  return PointSum(PointScale(leftScalar, p0), PointScale(rightScalar, p1))
end

function ByteToNormal(byte)
  return 2 * byte / 255 - 1
end

function NormalToByte(n)
  return 255 * (n + 1) / 2
end

function ColorToNormal(c)
  return { x = ByteToNormal(c.red),
           y = ByteToNormal(c.green),
           z = ByteToNormal(c.blue) }
end

function NormalToColor(p)
  return Color{ r = NormalToByte(p.x),
                g = NormalToByte(p.y),
                b = NormalToByte(p.z) }
end

function SameColor(c0, c1)
  return c0.red == c1.red and c0.green == c1.green and c0.blue == c1.blue
end

function ColorSlerp(c0, c1, t)
  if SameColor(c0, c1) then return c0 end

  local p0 = ColorToNormal(c0)
  local p1 = ColorToNormal(c1)
  local normal = Slerp(p0, p1, t)
  return NormalToColor(normal)
end

do
  local fg = app.fgColor
  local bg = app.bgColor
  app.fgColor = ColorSlerp(fg, bg, 0.5)
end
