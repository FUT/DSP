require 'pry'
require_relative 'lib/const'
require_relative 'lib/plotter'
require_relative 'lib/transform'
require_relative 'lib/fast'

include Fourier

y = Proc.new{ |x| Math.sin(6 * x) + Math.cos(5 * x) } #Math.sin(6 * x) + Math.cos(5 * x) }

plot = Plotter.new
plot.step = 0.0390625
values = plot.to_array{ |x| y.call(x) }
plot.draw('f(x) = cos(5x) + sin(6x)', 'black', values)

# DFT
convoluted = Transform.convolute values.map(&:y)
dots = values.each_with_index.map{|val, i| OpenStruct.new({x: val.x, y: convoluted[i].abs})}
plot.draw('F(x) = FT(f(x))', 'red', dots)

deconvoluted = Transform.deconvolute convoluted
dots = values.each_with_index.map{|val, i| OpenStruct.new({x: val.x, y: 0.1 + deconvoluted[i].real})}
plot.draw('F(x) = RFT(FT(f(x)))', 'blue', dots)

# Fast
convoluted = FastTransform.fft values.map(&:y), false
dots = values.each_with_index.map{|val, i| OpenStruct.new({x: val.x, y: convoluted[i].abs - 0.1})}
plot.draw('FFT', 'green', dots)

deconvoluted = FastTransform.fft convoluted, true
deconvoluted.map!{ |value| value / N }
dots = values.each_with_index.map{|val, i| OpenStruct.new({x: val.x, y: deconvoluted[i].real - 0.1})}
plot.draw('INV_FFT', 'orange', dots)

plot.save 'img/fourier.svg'
