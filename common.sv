`ifndef COMMON_MODULE
`define COMMON_MODULE
package common;
  typedef struct packed {
    logic [9:0] x;
    logic [9:0] y;
  } vertex_t;

  typedef struct packed {
    logic [7:0] red;
    logic [7:0] green;
    logic [7:0] blue;
  } color_t;

  typedef struct packed {
    vertex_t a;
    vertex_t b;
    vertex_t c;
    color_t color;
    logic [7:0] depth;
  } object_t;

  typedef struct packed {
    logic [7:0] red;
    logic [7:0] green;
    logic [7:0] blue;
    logic [7:0] depth;
  } pixel_t;

  typedef struct packed {
    logic [9:0] x, y;
    pixel_t pixel;
  } pixel_info_t;

  task automatic log_vertex(input vertex_t vertex, input string name);
    $display("  vertex %s:, x: %d, y: %d", name, vertex.x, vertex.y);
  endtask
  task automatic log_object(input object_t object);
    $display("object:");
    log_vertex(object.a, "a");
    log_vertex(object.b, "b");
    log_vertex(object.c, "c");
    $display("  color: %h", object.color);
  endtask
  task automatic log_pixel(input pixel_t pixel);
    $display("pixel: r: %h, g: %h, b: %h, depth: %d", pixel.red, pixel.green, pixel.blue,
             pixel.depth);
  endtask

endpackage
`endif
