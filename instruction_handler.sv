`include "common.sv"
module instruction_handler
  import common::*;
(
    input clock,
    reset,

    input full,
    output object_t data,
    output write
);

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      data  <= 0;
      write <= 0;
    end
    if (full) $display("object buffer full");
  end

endmodule
