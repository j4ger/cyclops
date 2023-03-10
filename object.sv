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

