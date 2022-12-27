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
