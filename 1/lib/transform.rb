module Fourier
  class Transform
    class << self
      def convolute(data)
        data.each_with_index.map do |_, k|
          (0...N).map { |m| data[m] * (Math::E ** (-Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+)
        end
      end

      def deconvolute(data)
        data.each_with_index.map do |_, k|
          (0...N).map { |m| data[m] * (Math::E ** (Complex::I * 2 * Math::PI * k * m / N)) }.reduce(&:+) / N
        end
      end
    end
  end
end
