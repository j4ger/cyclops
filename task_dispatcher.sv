module task_dispatcher #(
    parameter logic [7:0] UNITS = 16
) (
    input clock,
    reset,

    input read_end,
    input [UNITS-1:0] task_complete,
    input depth_comparator_write_complete,

    output logic next_task,  // object buffer control
    output logic tasks_complete  // buffer switcher control
);

  logic all_complete = &task_complete;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      tasks_complete <= 0;
      next_task <= 0;
    end else begin
      tasks_complete <= all_complete & read_end & depth_comparator_write_complete;
      next_task <= all_complete;
    end
  end

endmodule
