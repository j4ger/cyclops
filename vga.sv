module vga #(
    parameter integer WIDTH = 800,
    integer HEIGHT = 525,
    integer VIEW_WIDTH = 640,
    integer VIEW_HEIGHT = 480,
    integer FRONT_PORCH = 16,
    integer TOP_PORCH = 10,
    integer H_SYNC_PULSE = 96,
    integer V_SYNC_PULSE = 2
) (
    input         clock,
    reset,
    data,
    output        h_sync,
    v_sync,
    target_clock,
    blank,
    output [ 7:0] red,
    green,
    blue,
    output [18:0] address
);

  import interfaces::pixel_t;

  pixel_t data;

  logic [$clog2(WIDTH)-1:0] current_width;
  logic [$clog2(HEIGHT)-1:0] current_height;

  assign h_sync = !(current_width >= FRONT_PORCH && current_width < FRONT_PORCH + H_SYNC_PULSE);
  assign v_sync = !(current_height >= TOP_PORCH && current_height < TOP_PORCH + V_SYNC_PULSE);

  logic h_in_view = (current_width >= FRONT_PORCH) && (current_width < FRONT_PORCH + WIDTH);
  logic v_in_view = (current_height >= TOP_PORCH) && (current_height < TOP_PORCH + HEIGHT);
  logic in_view = h_in_view && v_in_view;

  assign blank = in_view;

  assign target_clock = ~clock;

  // internal state for skipping the first bit

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      current_width <= 0;
      current_height <= 0;

      address <= 0;
    end else begin
      if (current_width < WIDTH - 1) current_width += 1;
      else begin
        current_width <= 0;
        if (current_height < HEIGHT - 1) current_height += 1;
        else current_height <= 0;
      end
    end

    if (in_view) begin
      address <= (current_height - TOP_PORCH - 1) * WIDTH + (current_width - FRONT_PORCH - 1);
      red <= data.red;
      green <= data.green;
      blue <= data.blue;
    end else begin
      red   <= 0;
      green <= 0;
      blue  <= 0;
    end

  end
endmodule

