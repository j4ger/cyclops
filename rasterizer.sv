`include "common.sv"
// each rasterizer scans pixels whose vertical coordinate ranges from X_RANGE_START to X_RANGE_END
module rasterizer
  import common::*;
#(
    parameter int X_RANGE_START = 0,
    int X_RANGE_END = 29,
    logic [9:0] HEIGHT = 479
) (
    input clock,
    reset,

    input object_t current_task,
    input next_task,
    input output_written,

    output pixel_info_t data_out,
    output data_write,
    output task_complete
);

  logic [9:0] current_x, current_y;
  logic cursor_at_end;
  assign cursor_at_end = (current_x == X_RANGE_END[9:0]) && (current_y == HEIGHT);

  typedef enum {
    idle = 0,
    calc_s1 = 1,
    calc_s2 = 2,
    calc_t1 = 3,
    calc_t2 = 4,
    calc_d1 = 5,
    calc_d2 = 6,
    wait_for_d2 = 7,
    calc_complete = 8,
    complete = 9
  } rasterizer_state_t;

  rasterizer_state_t state, next_state;

  logic multiplier_start, multiplier_complete;

  assign multiplier_start = (state != idle) && (state != complete);

  logic signed [21:0] s, d, t, s1, s2, d1, d2, t1, t2, sum_st;

  assign s = s1 - s2;
  assign d = d1 - d2;
  assign t = t1 - t2;
  assign sum_st = s + t;

  logic in_triangle;
  assign in_triangle = (s > 0 == t > 0) && (d > 0 == sum_st > 0);

  logic signed [10:0] mul_a, mul_b;
  logic signed [21:0] mul_c;

  multiplier mul (
      .clock(clock),
      .reset(reset),
      .a(mul_a),
      .b(mul_b),
      .start(multiplier_start),
      .c(mul_c),
      .valid(multiplier_complete)
  );

  logic written;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      current_x <= X_RANGE_START[9:0];
      current_y <= 0;
      state <= calc_s1;
      s1 <= 0;
      s2 <= 0;
      d1 <= 0;
      d2 <= 0;
      t1 <= 0;
      t2 <= 0;
      mul_a <= 0;
      mul_b <= 0;
      data_write <= 0;
      written <= 1;
      task_complete <= 0;
    end else begin
      state <= next_state;

      if (output_written) written <= 1;

      if (next_task) begin
        $display("==============new task==============");
        task_complete <= 0;
        current_x <= X_RANGE_START[9:0];
        current_y <= 0;
      end

      case (state)
        default: begin
        end
        idle: begin
          //          $display("idle, task_complete: %d, x: %d, y: %d, next_task:%d", task_complete, current_x,
          //                   current_y, next_task);
          data_write <= 0;
        end
        calc_s1: begin
          //          $display("calc s1");
          //          log_object(current_task);
          mul_a <= current_task.a.x - current_task.c.x;
          mul_b <= current_y - current_task.c.y;
        end
        calc_s2: begin
          mul_a <= current_task.a.y - current_task.c.y;
          mul_b <= current_x - current_task.c.x;
          s1 <= mul_c;
        end
        calc_t1: begin
          mul_a <= current_task.b.x - current_task.a.x;
          mul_b <= current_y - current_task.a.y;
          s2 <= mul_c;
        end
        calc_t2: begin
          mul_a <= current_task.b.y - current_task.a.y;
          mul_b <= current_x - current_task.a.x;
          t1 <= mul_c;
        end
        calc_d1: begin
          mul_a <= current_task.c.x - current_task.b.x;
          mul_b <= current_y - current_task.b.y;
          t2 <= mul_c;
        end
        calc_d2: begin
          mul_a <= current_task.c.y - current_task.b.y;
          mul_b <= current_x - current_task.b.x;
          d1 <= mul_c;
        end
        calc_complete: begin
          d2 <= mul_c;
          if (cursor_at_end) task_complete <= 1;
        end
        complete: begin
          //          $display("setting output for (%d, %d)", current_x, current_y);
          // write result if needed
          if (in_triangle & written) begin
            //           $display("writing");
            if (current_x == 50 && current_y == 0) begin
              $display("s:%d,d:%d,t:%d,sum_st:%d", s, d, t, sum_st);
              $display("d>0:%d,sum_st>0:%d,s>0:%d", d > 0, sum_st > 0, s > 0);
            end
            data_write <= 1;
            data_out <= '{
                x: current_x,
                y: current_y,
                pixel: '{
                    red: current_task.color.red,
                    green: current_task.color.green,
                    blue: current_task.color.blue,
                    depth: current_task.depth
                }
            };
            written <= 0;
          end else data_write <= 0;
          // move cursor
          if (!cursor_at_end) begin
            if (current_y == HEIGHT) begin
              current_y <= 0;
              current_x <= current_x + 1;
            end else current_y <= current_y + 1;
          end
        end
      endcase
    end

  end

  always_comb begin
    unique case (state)
      default: next_state = idle;
      idle: next_state = next_task ? calc_s1 : idle;
      calc_s1: next_state = multiplier_complete ? calc_s2 : calc_s1;
      calc_s2: next_state = multiplier_complete ? calc_t1 : calc_s2;
      calc_t1: next_state = multiplier_complete ? calc_t2 : calc_t1;
      calc_t2: next_state = multiplier_complete ? calc_d1 : calc_t2;
      calc_d1: next_state = multiplier_complete ? calc_d2 : calc_d1;
      calc_d2: next_state = multiplier_complete ? wait_for_d2 : calc_d2;
      wait_for_d2: next_state = multiplier_complete ? calc_complete : wait_for_d2;
      calc_complete: next_state = complete;
      complete: next_state = (!written) ? complete : (task_complete ? idle : calc_s1);
    endcase
  end

endmodule
