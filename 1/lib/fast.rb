module Fourier
  module FastTransform
    def convolute(k, f)
      (0...N).map { |m| f.call(m) * (Math::E ** (-Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+) / N
    end

    def deconvolute(k, f)
      (0...N).map { |m| f.call(m) * (Math::E ** (Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+) / N
    end
  end
end
