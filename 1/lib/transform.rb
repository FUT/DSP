module Fourier
  class Transform
    class << self
      def convolute(k, f)
        (0...N).map { |m| f.call(m) * (Math::E ** (-Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+)
      end

      def deconvolute(k, f)
        (0...N).map { |m| f.call(m) * (Math::E ** (Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+) / N
      end
    end
  end
end
