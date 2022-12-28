`include "common.sv"
// provides buffer for rasterizers
// provides [written] signal to indicate a buffer is ready for further writes
// for each data, read from display buffer and compare depth, if current data
// has greater depth, write to display buffer
module depth_comparator
  import common::*;
#(
    parameter logic [7:0] UNITS = 16
) (
    input clock,
    reset,

    input pixel_info_t [UNITS-1:0] input_data,
    input [UNITS-1:0] input_valid,
    output logic [UNITS-1:0] written,

    input pixel_t buffer_read_data,
    output write_enable,
    output logic [9:0] address_x,
    address_y,
    output pixel_t buffer_write_data,

    output all_complete
);

  typedef enum {
    read,
    write
  } depth_comparator_state_t;

  depth_comparator_state_t state, next_state;

  assign all_complete = !(|input_valid);

  int   current_index;
  logic current_index_found;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      state <= read;
      current_index <= 0;
      written <= {UNITS{1'b1}};
      address_x <= 0;
      address_y <= 0;
    end else begin
      state <= next_state;

      case (state)
        default: begin
        end
        read: begin
          if (!all_complete) begin
            current_index_found <= 0;
            foreach (input_valid[i]) begin
              if (input_valid[i]) begin
                if (!current_index_found) begin
                  current_index <= i;
                  current_index_found <= 1;
                end
                written[i] <= 0;
              end
            end

            address_x <= input_data[current_index].x;
            address_y <= input_data[current_index].y;
            write_enable <= 0;

          end
        end
        write: begin
          written[current_index] <= 1;
          if (buffer_read_data.depth < input_data[current_index].pixel.depth) begin
            buffer_write_data <= input_data[current_index].pixel;
            write_enable <= 1;
          end
        end
      endcase

    end
  end

  always_comb begin
    next_state = read;
    case (state)
      default: next_state = read;
      read: next_state = all_complete ? read : write;
      write: next_state = read;
    endcase
  end

endmodule
