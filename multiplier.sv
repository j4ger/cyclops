// dummy implementation of a multi-cycle multiplier, should be replaced with
// vendor implementation
module multiplier #(
    parameter logic [7:0] WIDTH = 10
) (
    input clock,
    reset,

    input signed [WIDTH:0] a,
    b,
    input start,

    output logic signed [WIDTH *2+1:0] c,
    output logic valid
);

  typedef enum {
    read_input,
    calculate,
    write_output
  } multiplier_state_t;

  multiplier_state_t state, next_state;

  logic signed [WIDTH:0] cache_a, cache_b;

  assign valid = state == calculate;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      state <= read_input;
      c <= 0;
      cache_a <= 0;
      cache_b <= 0;
    end else begin
      state <= next_state;
    end

    case (state)
      read_input: begin
        cache_a <= a;
        cache_b <= b;
      end
      calculate: c <= cache_a * cache_b;
      default: begin
      end
    endcase

  end

  always_comb begin
    next_state = state;
    case (state)
      default: next_state = state;
      read_input:
      if (start) next_state = calculate;
      else next_state = state;
      calculate: next_state = write_output;
      write_output: next_state = read_input;
    endcase
  end



endmodule
