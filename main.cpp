#include <Vcyclops_top.h>
#include <nvboard.h>
//#define DUMP

#ifdef DUMP
#include <verilated_vcd_c.h>
#endif

void nvboard_bind_all_pins(Vcyclops_top *top);

static void single_cycle_0(Vcyclops_top *cyclops_top) {
  cyclops_top->clock = 0;
  cyclops_top->eval();
}

static void single_cycle_1(Vcyclops_top *cyclops_top) {
  cyclops_top->clock = 1;
  cyclops_top->eval();
}

static void reset(int n, Vcyclops_top *cyclops_top) {
  cyclops_top->reset = 1;
  while (n-- > 0) {
    single_cycle_0(cyclops_top);
    single_cycle_1(cyclops_top);
  }
  cyclops_top->reset = 0;
}

int main() {
#ifdef DUMP
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
#endif // DEBUG
  Vcyclops_top cyclops_top;
#ifdef DUMP
  cyclops_top.trace(tfp, 10);
  tfp->open("dump.vcd");
#endif // DEBUG
  nvboard_bind_all_pins(&cyclops_top);
  nvboard_init();

  reset(10, &cyclops_top);

  while (1) {
    nvboard_update();
    single_cycle_0(&cyclops_top);
#ifdef DUMP
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif
    single_cycle_1(&cyclops_top);
#ifdef DUMP
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif
  }
}
