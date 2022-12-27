`include "object.sv"
module task_dispatcher #(
    parameter logic [7:0] UNITS = 16
) (
    input read_end,
    input [UNITS-1:0] task_complete,

    output next_object,  // object buffer control
    output next_frame    // buffer switcher control
);

  logic all_complete = &task_complete;
  assign next_frame  = all_complete & read_end;
  assign next_object = all_complete;

endmodule
