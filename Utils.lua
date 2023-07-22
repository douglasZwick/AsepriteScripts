function Lerp(a, b, t)
  return a * (1 - t) + b * t
end

function LerpRGB(c0, c1, t)
  local ro = Lerp(c0.red,   c1.red,   t)
  local go = Lerp(c0.green, c1.green, t)
  local bo = Lerp(c0.blue,  c1.blue,  t)
  local ao = c0.alpha
  return Color{ r = ro, g = go, b = bo, a = ao }
end

function LerpHSV(c0, c1, t)
  local ho = Lerp(c0.hsvHue,        c1.hsvHue, t)
  local so = Lerp(c0.hsvSaturation, c1.hsvSaturation, t)
  local vo = Lerp(c0.hsvValue,      c1.hsvValue, t)
  local ao = c0.alpha
  return Color{ h = ho, s = so, v = vo, a = ao }
end
