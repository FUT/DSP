require 'pry'
require 'RMagick'

SQUARE = [[-1, 0], [-1, 1], [-1, -1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

img = Magick::Image.read('image.jpg').first
img.write 'result1.jpg'
(med = img.median_filter(2)).write 'median.jpg'
(@bin = med.threshold(Magick::MaxRGB * 0.75)).write 'binarized.jpg'

@result = Magick::Image.read('result1.jpg').first
@result.each_pixel { |p, c, r| @result.pixel_color(c,r, 'white') }
$checked = {}
$stack = []

# def color_byte
#   '%02X' % rand(155)
# end
#
# def new_color
#   "##{color_byte}#{color_byte}#{color_byte}"
# end
# $color = new_color
#
# def in_group?(c, r)
#   SQUARE.all? { |dx, dy| @bin.pixel_color(c + dx, r + dy).intensity < 100 }
# end
#
# def group(c, r, color = new_color)
#   p "#{c} #{r}"
#   if in_group?(c, r)
#     $stack << [c, r]
#     while !$stack.empty?
#       sc, sr = $stack.shift
#       p "- #{sc} #{sr}              len #{$stack.length}"
#       $checked[sr] ||= []
#       next if $checked[sr].include?(sc)
#       $checked[sr] << sc
#       next unless in_group?(sc, sr)
#       @result.pixel_color(sc, sr, color)
#       SQUARE.each { |dx, dy| $stack << [sc + dx, sr + dy] }
#     end
#     $color = new_color
#   else
#     $checked[r] ||= []
#     $checked[r] << c
#   end
# end
#
# @result.each_pixel do |p, c, r|
#   next unless @result.pixel_color(c,r).intensity > 60000
#   p "row #{r}" if c == 0
#   group(c,r)
#   $checked[r] ||= []
#   $checked[r] << c
# end
# @result.write 'result.jpg'

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
