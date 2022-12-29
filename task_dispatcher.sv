module task_dispatcher #(
    parameter logic [7:0] UNITS = 16
) (
    input clock,
    reset,

    input read_end,
    input [UNITS-1:0] task_complete,
    input depth_comparator_write_complete,
    input vga_complete,

    output logic next_task,  // object buffer control
    output logic switch_buffer  // buffer switcher control
);

  logic all_complete = &task_complete;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      switch_buffer <= 0;
      next_task <= 0;
    end else begin
      if (all_complete && (!read_end)) next_task <= 1;
      else next_task <= 0;

      if (all_complete && read_end && depth_comparator_write_complete && vga_complete)
        switch_buffer <= 1;
      else switch_buffer <= 0;
    end
  end

endmodule
