require 'pry'
require_relative 'lib/const'
require_relative 'lib/plotter'
require_relative 'lib/transform'

include Fourier

y = Proc.new{ |x| Math.cos 5 * x }
z = Proc.new{ |x| Math.sin 6 * x }

plot = Plotter.new 0.02
plot.draw('f(x) = cos(5x) + sin(5x)', 'black'){ |x| y.call(x) + z.call(x) }

plot.step = 0.1
cy = Proc.new{ |x| Transform.convolute x, y }
cz = Proc.new{ |x| Transform.convolute x, z }
plot.draw('F(x) = FT(f(x))', 'red'){ |x| (cy.call(x) + cz.call(x)).abs }

dcy = Proc.new{ |x| Transform.deconvolute x, cy }
dcz = Proc.new{ |x| Transform.deconvolute x, cz }
plot.draw('rf(x) = RFT(FT(x))', 'blue'){ |x| (dcy.call(x) + dcz.call(x)).real }

plot.save 'img/fourier.svg'
