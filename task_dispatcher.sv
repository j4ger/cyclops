module task_dispatcher #(
    parameter logic [7:0] UNITS = 16
) (
    input read_end,
    input [UNITS-1:0] task_complete,
    input depth_comparator_write_complete,

    output next_object,    // object buffer control
    output tasks_complete  // buffer switcher control
);

  logic all_complete = &task_complete;
  assign tasks_complete = all_complete & read_end & depth_comparator_write_complete;
  assign next_object = all_complete;

endmodule
