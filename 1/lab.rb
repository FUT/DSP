require 'pry'
require 'rubyvis'

N = 32

Y = Proc.new do |x|
  Math.cos 5 * x
end

Z = Proc.new do |x|
  Math.sin 6 * x
end

def step(n)
  n * Math::PI * 2 / N
end

def f_full(n)
  Y.call(step n) + Z.call(step n)
end

def cx(k, f)
  (0...N).map { |m| f.call(step m) * (Math::PI ** (-Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+) / N
end

def c_full(k)
  cx(k, Y) + cx(k, Z)
end

def plot
  data = pv.range(0, 10, 0.1).map {|x|
    OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+rand()})
  }
end

fx = (0...N).map{ |i| OpenStruct.new({ x: step(i), y: f_full(i) }) }
cx = (0...N).map{ |i| OpenStruct.new({ x: step(i), y: c_full(i) }) }

vis = pv.Panel.new do
  width 800
  height 500
  line do
    data fx
    line_width 5
    stroke_style 'red'
  end
end

vis.render()
p vis.to_svg
File.open('fourier.svg', 'w') { |file| file << vis.to_svg }
