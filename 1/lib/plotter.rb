require 'rubyvis'

module Fourier
  class Plotter
    W = 1900
    H = 1000

    SX = 100.0
    SY = 30.0

    attr_accessor :vis, :step

    def initialize(step = 0.1, range = -10..10)
      @step = step
      @range = range
      @label_pos = OpenStruct.new({x: 50, y: 50})
      init_graph
      draw_grid
    end

    def draw(name, color)
      data = pv.range(@range.begin, @range.end, @step).map do |x|
          OpenStruct.new({x: x, y: yield(x)})
      end

      @vis.add(pv.Line).
        data(data).
        stroke_style(color).
        line_width(1).
        left(->(d){d.x * SX + W / 2}).
        bottom(->(d){d.y * SY + H / 2})

      @vis.add(pv.Label).
        top(@label_pos.y).
        left(@label_pos.x).
        text(name).
        text_style(color)

      @label_pos.y += 30
    end

    def save(filename)
      @vis.render()
      File.open(filename, 'w').write @vis.to_svg
    end

    private
    def init_graph
      @vis = pv.Panel.new().
        width(W).
        height(H).
        fillStyle('white')
    end

    def draw_grid
      @vis.add(pv.Rule).bottom(H / 2)
      @vis.add(pv.Rule).left(W / 2)

      @vis.add(pv.Rule).
        data(Array(-5..5)).
        bottom(->(d){d * SY + H / 2}).
        width(10).
        add(pv.Label).left(W / 2)

      @vis.add(pv.Rule).
        data(pv.range(-50,50,1)).
        height(10).
        left(->(d){d * SX + W / 2}).
        anchor('bottom').
        add(pv.Label)
    end
  end
end
