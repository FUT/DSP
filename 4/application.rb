require 'pry'
require 'RMagick'

img = Magick::Image.read('image.png').first
img.write('image.png')

def draw_hist(img, w=900, h=500, file='histogram.png')
  canvas = Magick::ImageList.new
  canvas.new_image(w, h)

  hist_data = img.quantize.color_histogram.to_a.sort { |a, b| a[1] <=> b[1] }
  hist_max = hist_data.map{ |d| d[1] }.max
  hist_step = 1.0 * w / hist_data.size - 1

  draw = Magick::Draw.new
  draw.stroke_width(hist_step)

  hist_data.each do |pixel, count|
    height = 1.0 * count / hist_max * h
    draw.stroke pixel.to_color
    hist_x = 1.0 * pixel.intensity / 65535 * w
    draw.line(hist_x, h - height, hist_x, h)
  end

  draw.draw(canvas)
  canvas.write(file)
end

#prepare images
draw_hist img
img.negate.write 'negated.png'
img.median_filter(2).write 'median.png'

def show(file)
  @buttons_x ||= 0
  button file, left: @buttons_x, top: 510 do
    fill "#{file}.png"
    rect 0, 0, 900, 500
  end
  @buttons_x += 200
end

Shoes.app height: 600, width: 900 do
  show 'image'
  show 'histogram'
  show 'negated'
  show 'median'
end
