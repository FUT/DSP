require 'pry'
require_relative 'lib/const'
require_relative 'lib/plotter'
require_relative 'lib/transform'
require_relative 'lib/fast'

include Fourier

y1 = Proc.new{ |x| Math.sin(6 * x) }
y2 = Proc.new{ |x| Math.cos(5 * x) }

plot = Plotter.new
plot.step = 0.0390625
values1 = plot.to_array{ |x| y1.call(x) }
plot.draw('f(x) = sin(6x)', 'black', values1)
values2 = plot.to_array{ |x| y2.call(x) }
plot.draw('f(x) = cos(5x)', 'gray', values2)

convoluted1 = FastTransform.fft values1.map(&:y), false
convoluted2 = FastTransform.fft values2.map(&:y), false

convoluted = convoluted1.zip(convoluted2).map { |a,b| a * b }
dots = values1.each_with_index.map{|val, i| OpenStruct.new({x: val.x, y: convoluted[i].abs - 0.1})}
plot.draw('convolution', 'green', dots)

correlated = convoluted1.zip(convoluted2.reverse).map { |a,b| a * b }
dots = values1.each_with_index.map{|val, i| OpenStruct.new({x: val.x, y: correlated[i].abs - 0.1})}
plot.draw('correlation', 'red', dots)

plot.save 'img/con_cor.svg'
