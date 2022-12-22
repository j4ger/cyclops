`include "pixel.sv"
module cyclops_top (
    input clock,
    reset,

    output VGA_CLK,
    VGA_HSYNC,
    VGA_VSYNC,
    VGA_BLANK_N,

    output [7:0] VGA_R,
    VGA_G,
    VGA_B
);

  pixel_t display_buffer[524288];

  logic [9:0] x_address;
  logic [9:0] y_address;

  pixel_t buffer_data;
  assign buffer_data = display_buffer[{y_address[8:0], x_address[9:0]}];

  vga vga (
      .clock(clock),
      .reset(reset),
      .data(buffer_data),
      .h_sync(VGA_HSYNC),
      .v_sync(VGA_VSYNC),
      .target_clock(VGA_CLK),
      .blank(VGA_BLANK_N),
      .x_address(x_address),
      .y_address(y_address),
      .red(VGA_R),
      .green(VGA_G),
      .blue(VGA_B)
  );

  initial $readmemh("./resources/xiaoke.hex", display_buffer);

endmodule

