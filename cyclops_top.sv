`include "common.sv"
module cyclops_top
  import common::*;
(
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

  logic [9:0] dbm_address_a_x, dbm_address_a_y, dbm_address_b_x, dbm_address_b_y;
  pixel_t dbm_data_a, dbm_data_b, dbm_write_data_b;
  logic dbm_write_enable_b;
  logic vga_frame_complete, next_frame, object_buffer_read_end;

  display_buffer_mux display_buffer_mux (
      .clock(clock),
      .reset(reset),
      .address_a_x(dbm_address_a_x),
      .address_a_y(dbm_address_a_y),
      .address_b_x(dbm_address_b_x),
      .address_b_y(dbm_address_b_y),
      .data_a(dbm_data_a),
      .data_b(dbm_data_b),
      .write_data_b(dbm_write_data_b),
      .write_enable_b(dbm_write_enable_b),
      .vga_frame_complete(vga_frame_complete),
      .object_buffer_read_end(object_buffer_read_end),
      .next_frame(next_frame)
  );



  vga vga (
      .clock(clock),
      .reset(reset),
      .data(dbm_data_a),
      .h_sync(VGA_HSYNC),
      .v_sync(VGA_VSYNC),
      .target_clock(VGA_CLK),
      .blank(VGA_BLANK_N),
      .x_address(dbm_address_a_x),
      .y_address(dbm_address_a_y),
      .red(VGA_R),
      .green(VGA_G),
      .blue(VGA_B),
      .frame_complete(vga_frame_complete)
  );

endmodule

