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
    vertex_t a = '{200, 50};
    vertex_t b = '{50, 200};
    vertex_t c = '{100, 250};
    vertex_t d = '{300, 250};
    vertex_t e = '{350, 200};
    vertex_t f = '{200, 400};
    vertex_t g = '{40, 300};
    vertex_t h = '{500, 50};
    vertex_t i = '{450, 300};

    color_t  c1 = 'hCBEDD5;
    color_t  c2 = 'h97DECE;
    color_t  c3 = 'h62B6B7;
    color_t  c4 = 'h439A97;
    color_t  c5 = 'hFC8210;

    mem[0] = '{a, b, c, c3, 1};
    mem[1] = '{a, c, d, c1, 1};
    mem[2] = '{a, d, e, c3, 1};
    mem[3] = '{b, c, f, c4, 1};
    mem[4] = '{c, d, f, c2, 1};
    mem[5] = '{d, e, f, c4, 1};
    mem[6] = '{g, h, i, c5, 7};

    write_cursor = 7;
  end

endmodule
