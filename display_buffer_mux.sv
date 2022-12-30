`include "common.sv"
// port a: read only, routes to current_buffer
// port b: read-write, routes to the-other-buffer
// reading/writing takes one cycle for the result to become stable
module display_buffer_mux
  import common::*;
(
    input clock,
    reset,

    input [9:0] address_a_x,
    address_a_y,
    output pixel_t data_a,

    input [9:0] address_b_x,
    address_b_y,
    input write_enable_b,
    input pixel_t write_data_b,
    output pixel_t data_b,

    input switch_buffer
);

  pixel_t display_buffer_1[524288];
  pixel_t display_buffer_2[524288];

  initial $readmemh("./resources/buffer1.hex", display_buffer_1);
  initial $readmemh("./resources/buffer2.hex", display_buffer_2);

  logic current_buffer;  // 0 for buffer_1, 1 for buffer_2

  assign data_a = current_buffer?
    display_buffer_2[{address_a_y[8:0],address_a_x[9:0]}]:
    display_buffer_1[{address_a_y[8:0],address_a_x[9:0]}];

  assign data_b = current_buffer?
    display_buffer_1[{address_b_y[8:0],address_b_x[9:0]}]:
    display_buffer_2[{address_b_y[8:0],address_b_x[9:0]}];

  always_ff @(posedge clock) begin
    if (write_enable_b) begin
      if (current_buffer) display_buffer_1[{address_b_y[8:0], address_b_x[9:0]}] <= write_data_b;
      else display_buffer_2[{address_b_y[8:0], address_b_x[9:0]}] <= write_data_b;
    end
  end

  // switching logic
  always_ff @(posedge clock or posedge reset) begin
    if (reset) current_buffer <= 0;
    else if (switch_buffer) begin
      // buffer clear mechanism
      //      if (current_buffer) display_buffer_2 <= '{default: 0};
      //      else display_buffer_1 <= '{default: 0};
      current_buffer <= ~current_buffer;
    end
  end
endmodule
