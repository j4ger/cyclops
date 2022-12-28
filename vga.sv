`include "common.sv"
module vga
  import common::*;
#(
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
    frame_complete,

    output [7:0] red,
    green,
    blue,

    output [9:0] x_address,
    output [9:0] y_address

);

  logic [9:0] x_cnt, y_cnt;
  logic h_valid, v_valid;

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      x_cnt <= 1;
      y_cnt <= 1;
    end else begin
      if (x_cnt == H_WIDTH) begin
        x_cnt <= 1;
        if (y_cnt == V_HEIGHT) y_cnt <= 1;
        else y_cnt <= y_cnt + 1;
      end else x_cnt <= x_cnt + 1;
    end
  end

  assign frame_complete = (x_cnt == H_WIDTH) & (y_cnt == V_HEIGHT);

  assign target_clock = ~clock;

  assign h_sync = (x_cnt > H_FRONTPORCH);
  assign v_sync = (y_cnt > V_FRONTPORCH);

  assign h_valid = (x_cnt > H_ACTIVE) & (x_cnt <= H_BACKPORCH);
  assign v_valid = (y_cnt > V_ACTIVE) & (y_cnt <= V_BACKPORCH);
  assign blank = h_valid & v_valid;

  assign x_address = h_valid ? (x_cnt - 10'd145) : 10'd0;
  assign y_address = v_valid ? (y_cnt - 10'd36) : 10'd0;

  assign red = data.red;
  assign green = data.green;
  assign blue = data.blue;

endmodule



