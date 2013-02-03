require 'pry'
require 'RMagick'

# img = Magick::Image.read('image.jpg').first
# img.write 'result1.jpg'
# (med = img.median_filter(2)).write 'median.jpg'
# (bin = med.threshold(Magick::MaxRGB * 0.75)).write 'binarized.jpg'
#
# result = Magick::Image.read('result1.jpg').first
# result.each_pixel do |p, c, r|
#   p "row #{r}" if c == 0
#   square = ([-1, 0, 1] * 2).permutation(2).to_a.uniq
#   in_group = square.all? { |dx, dy| bin.pixel_color(c + dx, r + dy).intensity < 100 }
#   result.pixel_color(c, r, in_group ? 'red' : 'white')
# end
# result.write 'result.jpg'

def show(file)
  @buttons_x ||= 0
  button file, left: @buttons_x, top: 760 do
    fill "#{file}.jpg"
    rect 0, 0, 1200, 750
  end
  @buttons_x += 200
end

Shoes.app height: 800, width: 1200 do
  show 'image'
  show 'median'
  show 'binarized'
  show 'result'
end
