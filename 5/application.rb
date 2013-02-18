require 'RMagick'
require 'pry'

SQUARE = [[-1, 0], [-1, 1], [-1, -1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

img = Magick::Image.read('image.jpg').first
img.write 'result1.jpg'
(med = img).write 'median.jpg' #img.median_filter(2)).write 'median.jpg'
(@bin = med.threshold(Magick::MaxRGB * 0.75)).write 'binarized.jpg'

@result = Magick::Image.read('result1.jpg').first
@result.each_pixel { |p, c, r| @result.pixel_color(c,r, 'white') }
$checked = []
2000.times { |i| $checked[i] = Array.new(2000) }
$stack = []
$attrs = []

def color_byte
  '%02X' % rand(155)
end

def new_color
  "##{color_byte}#{color_byte}#{color_byte}"
end
$color = new_color

def in_group?(c, r)
  SQUARE.any? { |dx, dy| @bin.pixel_color(c + dx, r + dy).intensity < 100 }
end

def moment(dots, mass, i, j)
  dots.inject(0) { |sum, (x, y)| sum + ((x - mass[0]) ** i) * ((y - mass[1]) ** j) }
end

def group(c, r, color = new_color)
  if in_group?(c, r)
    $stack << [c, r]
    curr_attr = {
      mass: [0, 0],
      count: 0,
      p: 0,
      dots: []
    }
    $attrs << curr_attr

    while !$stack.empty?
      sc, sr = $stack.shift
      next if $checked[sr][sc]
      next if sc < 0 || sr < 0 || sc > 1024 || sr > 680

      # store all dots
      curr_attr[:dots] << [sc, sr]

      # calculate mass
      curr_attr[:mass][0] += sc
      curr_attr[:mass][1] += sr
      curr_attr[:count] += 1

      $checked[sr][sc] = true
      if in_group?(sc, sr)
        @result.pixel_color(sc, sr, color)
        SQUARE.each { |dx, dy| ($stack << [sc + dx, sr + dy]) }
      else
        curr_attr[:p] += 1
      end
    end

    #mass
    curr_attr[:mass][0] /= curr_attr[:count]
    curr_attr[:mass][1] /= curr_attr[:count]

    #compact
    curr_attr[:comp] = curr_attr[:p] ** 2 / curr_attr[:count]

    #decentered
    m20 = moment curr_attr[:dots], curr_attr[:mass], 2, 0
    m02 = moment curr_attr[:dots], curr_attr[:mass], 0, 2
    m11 = moment curr_attr[:dots], curr_attr[:mass], 1, 1
    s1 = m20 + m02
    s2 = ((m20 - m02) ** 2 + 4 * m11 * m11) ** 0.5
    curr_attr[:decentered] = (s1 + s2) / (s1 - s2)

    #orientation
    curr_attr[:orient] = Math.atan(2 * m11 / (m20 - m02)) / 2

    $color = new_color
  else
    $checked[r][c] = true
  end
end

@result.each_pixel do |p, c, r|
  next unless @result.pixel_color(c,r).intensity > 60000
  p "row #{r}" if c == 0
  group(c,r)
  $checked[r][c] = true
end

def med(els)
  med = els.inject([0, 0]) do |sum, e|
    sum[0] += e[:count]
    sum[1] += e[:comp]
    sum
  end

  med[0] /= els.count
  med[1] /= els.count
  {count: med[0], comp: med[1]}
end

def dst(a, b)
  (a[:count] - b[:count]) ** 2 + ((b[:comp] - a[:comp])) ** 2
end

def near(all, m)
  all.inject(all.first)  do |el, next_el|
    if dst(el, m) > dst(next_el, m)
      next_el
    else
      el
    end
  end
end

# $groups = $attrs.sample(3).map { |e| [e] }
$groups = [[$attrs[0]], [$attrs[1]], [$attrs[6]]]
while $groups.flatten.count < $attrs.count
  el = ($attrs - $groups.flatten).first

  dsts = $groups.map { |els| dst(el, med(els)) }
  group = 0
  dst = Float::INFINITY
  dsts.each_with_index do |next_dst, i|
    if dst > next_dst
      dst = next_dst
      group = i
    end
  end

  $groups[group] << el
end

$groups.each do |els|
  color = new_color
  els.each do |el|
    el[:dots].each do |x, y|
      @result.pixel_color(x, y, color)
    end

    #remove dots
    el.delete :dots
  end
end

puts $groups

@result.write 'result.jpg'

def show(file)
  @buttons_x ||= 0
  button file, left: @buttons_x, top: 400 do
    fill "#{file}.jpg"
    rect 0, 0, 500, 333
  end
  @buttons_x += 100
end

Shoes.app height: 500, width: 600 do
  show 'image'
  show 'median'
  show 'binarized'
  show 'result'
end
