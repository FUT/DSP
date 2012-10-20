module Fourier
  class FastTransform
    class << self
      def fft(vec, back = false)
        return vec if vec.size <= 1

        odd, even = vec.each_slice(2).to_a.transpose

        fft_even = fft(even)
        fft_odd  = fft(odd)

        fft_even.concat(fft_even)
        fft_odd.concat(fft_odd)

        Array.new(vec.size) {|i| fft_even[i] + fft_odd [i] * omega(-i, vec.size, back)}
      end

      def omega(k, n, back)
        Math::E ** Complex(0, (back ? -1 : 1) * 2 * Math::PI * k / n)
      end
    end
  end
end
