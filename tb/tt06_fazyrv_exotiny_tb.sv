// Copyright (c) 2024 Meinhard Kissich
// -----------------------------------------------------------------------------
// File  :  tt06_fazyrv_exotiny_tb.sv
// Usage :  Testbench to execute some tests.
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module tt06_fazyrv_exotiny_tb;

logic clk   = 1'b0;
logic rst_n = 1'b0;

always #10 clk = ~clk;

initial begin
  rst_n <= 1'b0;
  repeat (100) @(posedge clk);
  rst_n <= 1;
end

initial begin
  $dumpfile("tb.vcd");
  $dumpvars(0, tt06_fazyrv_exotiny_tb);
end

// Hack when solution when not traps are implemented.
reg [31:0] shift_reg = 32'd0;
reg prev_cpu_dmem_stb;

always @(posedge clk) begin
  prev_cpu_dmem_stb <= i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_cpu_dmem_stb;
  if ((i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_regs_adr[4:0] == 'hC ) & i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_regs_cyc & ~prev_cpu_dmem_stb & i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_cpu_dmem_stb) begin
    $write("%c", i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_mem_wdat);
    $fflush();
  end
end

always_ff @(posedge clk) begin
  if ((i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_regs_adr[4:0] == 'hC ) & i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_regs_cyc & ~prev_cpu_dmem_stb & i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_cpu_dmem_stb) begin
    shift_reg <= {shift_reg[23:0], i_tt06_fazyrv_exotiny_sim.i_tt_um_meiniKi_tt06_fazyrv_exotiny.i_exotiny.wb_cpu_dmem_wdat[7:0]};  // shift in new data
  end
end

`ifndef SIGNATURE
always_ff @(posedge clk) begin
  if (shift_reg == {"D", "O", "N", "E"}) begin
    $finish;
  end
  if (shift_reg[23:0] == {"E", "R", "R"}) begin
    $fatal;
  end
end
`endif

tt06_fazyrv_exotiny_sim i_tt06_fazyrv_exotiny_sim (
  .clk_i      ( clk   ),
  .rst_in     ( rst_n )
);


endmodule
