#include <Vcyclops_top.h>
#include <nvboard.h>

static Vcyclops_top cyclops_top;

void nvboard_bind_all_pins(Vcyclops_top *top);

static void single_cycle() {
  cyclops_top.clock = 0;
  cyclops_top.eval();
  cyclops_top.clock = 1;
  cyclops_top.eval();
}

static void reset(int n) {
  cyclops_top.reset = 1;
  while (n-- > 0)
    single_cycle();
  cyclops_top.reset = 0;
}

int main() {
  nvboard_bind_all_pins(&cyclops_top);
  nvboard_init();

  reset(10);

  while (1) {
    nvboard_update();
    single_cycle();
  }
}
