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

  logic [9:0] address_a_x, address_a_y, address_b_x, address_b_y;
  pixel_t data_a, data_b, write_data_b;
  logic write_enable_b;
  logic frame_complete;

  display_buffer_mux display_buffer_mux (
      .clock(clock),
      .reset(reset),
      .address_a_x(address_a_x),
      .address_a_y(address_a_y),
      .address_b_x(address_b_x),
      .address_b_y(address_b_y),
      .data_a(data_a),
      .data_b(data_b),
      .write_data_b(write_data_b),
      .write_enable_b(write_enable_b),
      .frame_complete(frame_complete)
  );

  vga vga (
      .clock(clock),
      .reset(reset),
      .data(data_a),
      .h_sync(VGA_HSYNC),
      .v_sync(VGA_VSYNC),
      .target_clock(VGA_CLK),
      .blank(VGA_BLANK_N),
      .x_address(address_a_x),
      .y_address(address_a_y),
      .red(VGA_R),
      .green(VGA_G),
      .blue(VGA_B),
      .frame_complete(frame_complete)
  );

endmodule

