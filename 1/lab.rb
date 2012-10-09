require 'pry'
require 'rubyvis'

W = 1900
H = 1000

N = 32

Y = Proc.new do |x|
  Math.cos 5 * x
end

Z = Proc.new do |x|
  Math.sin 6 * x
end

def f_full(x)
  Y.call(x) + Z.call(x)
end

def cx(k, f)
  (0...N).map { |m| f.call(m) * (Math::PI ** (-Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+) / N
end

def c_full(k)
  (cx(k, Y) + cx(k, Z)).abs
end

def scale_y(data, h = H)
  pv.Scale.linear(data, lambda {|d| d.y}).range(0, h)
end

def scale_x(data, w = W)
  pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)
end

fx = pv.range(-30, 30, 0.07).map {|x| OpenStruct.new({ x: x, y: f_full(x) }) }
sfx = scale_x fx
sfy = scale_y fx

cx = pv.range(-30, 30, 0.07).map {|x| OpenStruct.new({ x: x, y: c_full(x) }) }
scx = scale_x cx
scy = scale_y cx, H/2

vis = pv.Panel.new()
  .width(W)
  .height(H)
  .fillStyle('white')

vis.add(pv.Rule)
  .line_width(3)

vis.add(pv.Rule)
  .line_width(3)
  .left(W/2)

vis.add(pv.Line)
  .data(fx)
  .line_width(1)
  .left(->(d) {sfx.scale(d.x)})
  .bottom(->(d) {sfy.scale(d.y)})

vis.add(pv.Line)
  .data(cx)
  .line_width(2)
  .left(->(d) {scx.scale(d.x)})
  .bottom(->(d) {scy.scale(d.y) + H/2})
  .strokeStyle('red')

vis.render()
File.open('fourier.svg', 'w') { |file| file << vis.to_svg }
