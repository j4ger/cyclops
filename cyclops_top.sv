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

  localparam logic [7:0] UNITS = 1;
  localparam int STEP = 640 / {24'b0, UNITS};

  logic [9:0] dbm_address_a_x, dbm_address_a_y, dbm_address_b_x, dbm_address_b_y;
  pixel_t dbm_data_a, dbm_data_b, dbm_write_data_b;
  logic dbm_write_enable_b;
  logic vga_frame_complete, next_frame, tasks_complete;

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
      .tasks_complete(tasks_complete),
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

  pixel_info_t [UNITS -1:0] dc_input_data;
  logic [UNITS -1:0] dc_input_valid, dc_written;
  logic dc_all_complete;

  depth_comparator #(
      .UNITS(UNITS)
  ) depth_comparator (
      .clock(clock),
      .reset(reset),
      .input_data(dc_input_data),
      .input_valid(dc_input_valid),
      .written(dc_written),
      .buffer_read_data(dbm_data_b),
      .write_enable(dbm_write_enable_b),
      .address_x(dbm_address_b_x),
      .address_y(dbm_address_b_y),
      .buffer_write_data(dbm_write_data_b),
      .all_complete(dc_all_complete)
  );

  object_t ob_data_a, ob_data_b;
  logic ob_write_a, next_task, ob_full, object_buffer_read_end;

  object_buffer object_buffer (
      .clock(clock),
      .reset(reset),
      .next_frame(next_frame),
      .data_a(ob_data_a),
      .write_a(ob_write_a),
      .read_b(next_task),
      .data_b(ob_data_b),
      .full(ob_full),
      .read_end(object_buffer_read_end)
  );

  instruction_handler instruction_handler (
      .clock(clock),
      .reset(reset),
      .full (ob_full),
      .data (ob_data_a),
      .write(ob_write_a)
  );

  logic [UNITS-1:0] task_complete;

  task_dispatcher #(
      .UNITS(UNITS)
  ) task_dispatcher (
      .clock(clock),
      .reset(reset),
      .read_end(object_buffer_read_end),
      .task_complete(task_complete),
      .depth_comparator_write_complete(dc_all_complete),
      .next_task(next_task),
      .tasks_complete(tasks_complete)
  );

  generate
    genvar i;
    for (i = 0; i < UNITS; i++) begin : gen_rasterizers
      rasterizer #(
          .X_RANGE_START((STEP * i)),
          .X_RANGE_END  (STEP * (i + 1) - 1)
      ) rasterizer_unit (
          .clock(clock),
          .reset(reset),
          .current_task(ob_data_b),
          .next_task(next_task),
          .output_written(dc_written[i]),
          .data_out(dc_input_data[i]),
          .data_write(dc_input_valid[i]),
          .task_complete(task_complete[i])
      );
    end
  endgenerate




















endmodule

