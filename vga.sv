module vga #(
    parameter logic [9:0] H_WIDTH = 800,
    logic [9:0]    H_ACTIVE = 144,
    logic [9:0]    H_FRONTPORCH = 96,
    logic [9:0]    H_BACKPORCH = 784,

    logic [9:0]    V_HEIGHT = 525,
    logic [9:0]    V_ACTIVE = 35,
    logic [9:0]    V_FRONTPORCH = 2,
    logic [9:0]    V_BACKPORCH = 515
) (
    input clock,
    reset,

    input pixel_t data,

    output h_sync,
    v_sync,
    target_clock,
    blank,

    output [7:0] red,
    green,
    blue,

    output [9:0] x_address,
    output [9:0] y_address

);

  logic [ $clog2(H_WIDTH)-1:0] current_width;
  logic [$clog2(V_HEIGHT)-1:0] current_height;

  assign h_sync = current_width > H_FRONTPORCH;
  assign v_sync = current_height > V_FRONTPORCH;

  logic h_in_view = (current_width >= H_ACTIVE) && (current_width < H_BACKPORCH);
  logic v_in_view = (current_height >= V_FRONTPORCH) && (current_height < V_BACKPORCH);
  logic in_view = h_in_view && v_in_view;

  assign blank = in_view;

  assign target_clock = ~clock;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      current_width  <= 0;
      current_height <= 0;
    end else begin
      if (current_width == H_WIDTH) begin
        current_width <= 1;

        if (current_height == V_HEIGHT) current_height <= 1;
        else current_height <= current_height + 1;

      end else current_width <= current_width + 1;
    end

    if (in_view) begin
      x_address <= current_width - H_ACTIVE - 1;
      y_address <= current_height - V_ACTIVE - 1;
      red <= data.red;
      green <= data.green;
      blue <= data.blue;
    end
  end
endmodule

