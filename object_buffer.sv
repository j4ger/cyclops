`include "common.sv"
// port a for write only, writes to next available slot
// port b for read only, reads from first slot till last
// read cursor resets on reset signal
module object_buffer
  import common::*;
#(
    parameter int SIZE = 50
) (
    input clock,
    reset,
    switch_buffer,

    input object_t data_a,
    input write_a,

    input read_b,
    output object_t data_b,

    output full,
    read_end
);

  object_t mem[SIZE];
  logic [$clog2(SIZE)-1:0] write_cursor;
  logic [$clog2(SIZE)-1:0] read_cursor;

  assign full = write_cursor == SIZE[$clog2(SIZE)-1:0];
  assign read_end = write_cursor - 1 == read_cursor;

  assign data_b = mem[read_cursor];
  logic read_b_prev;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      // in reality we would want to reset write cursor, but in testing
      // environment initial value is written before reset, therefore write
      // cursor must not be reset
      // write_cursor<=0;
      read_cursor <= 0;
      read_b_prev <= 0;
    end else if (switch_buffer) begin
      read_cursor <= 0;
    end else begin
      if (write_a) begin
        mem[write_cursor] <= data_a;
        write_cursor <= write_cursor + 1;
      end
      if (read_b && (!read_b_prev)) begin
        read_cursor <= read_cursor + 1;  // should read before setting read_b signal
      end
    end
    read_b_prev <= read_b;
  end

  initial begin
    mem[0] = '{
        a: '{x: 10, y: 10},
        b: '{x: 100, y: 15},
        c: '{x: 50, y: 75},
        color: '{red: 100, green: 100, blue: 100},
        depth: 1
    };
    mem[1] = '{
        a: '{x: 500, y: 100},
        b: '{x: 600, y: 100},
        c: '{x: 600, y: 300},
        color: '{red: 7, green: 88, blue: 48},
        depth: 2
    };
    write_cursor = 2;
  end

endmodule
