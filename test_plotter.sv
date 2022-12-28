module test_plotter #(
    parameter int MAX = 200,
    parameter int HEIGHT = 480,
    parameter int WIDTH = 640
) (
    input clock,
    reset,
    output [18:0] address,
    data
);


  pixel_t data;

  logic [$clog2(MAX)-1:0] counter;
  logic [$clog2(HEIGHT *WIDTH )-1:0] current_index;

  always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
      counter <= 0;
      address <= 0;
      current_index <= 0;
    end else begin
      if (counter == MAX - 1) counter <= 0;
      else counter += 1;

      if (current_index == HEIGHT * WIDTH - 1) current_index <= 0;
      else current_index += 1;

    end

    address <= current_index;
    data <= '{counter, counter, counter, counter};
  end


endmodule
