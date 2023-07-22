function Lerp(a, b, t)
  return a * (1 - t) + b * t
end

function LerpRGB(c0, c1, t)
  local r = Lerp(c0.red,   c1.red,   t)
  local g = Lerp(c0.green, c1.green, t)
  local b = Lerp(c0.blue,  c1.blue,  t)
  local a = c0.alpha
  return Color{ r = r, g = g, b = b, a = a }
end

function LerpHSV(c0, c1, t)
  local h0, h1 = c0.hsvHue, c1.hsvHue

  if h0 > h1 then
    local temp = h0
    h0 = h1
    h1 = temp
  end

  if h1 - h0 > 180 then
    h0 = h0 + 180
  end

  local h = Lerp(h0, h1, t)
  local s = Lerp(c0.hsvSaturation, c1.hsvSaturation, t)
  local v = Lerp(c0.hsvValue, c1.hsvValue, t)
  local a = c0.alpha
  return Color{ h = h, s = s, v = v, a = a }
end
