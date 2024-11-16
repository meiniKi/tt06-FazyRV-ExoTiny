// Copyright (c) 2024 Meinhard Kissich
// -----------------------------------------------------------------------------
// File  :  top_emulation.sv
// Usage :  Wrapper to emulate tt06 in ULX3S
// -----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

module top_emulation (
  input logic         clk_i,
  input logic         rst_in,
  // QSPI PMOD (at tt BIDIR port)
  output logic        qspi_cs_ram_on,
  output logic        qspi_cs_rom_on,
  output logic        qspi_sck_o,
  inout  logic [3:0]  qspi_sdio_io,
  // Demo test outputs (at tt OUTPUT port)
  output logic [5:0]  out_o,
  // Demo test inputs (at tt INPUT port)
  output logic [5:0]  in_i
);

  // --- Clock Management ---
  logic clk_inter;
  logic locked;
  logic clk_sys;
  logic rst_sys_n;

  (* FREQUENCY_PIN_CLKI="25" *)
  (* FREQUENCY_PIN_CLKOP="50" *)
  (* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
  EHXPLLL #(
    .PLLRST_ENA       ( "ENABLED"   ),
    .INTFB_WAKE       ( "DISABLED"  ),
    .STDBY_ENABLE     ( "DISABLED"  ),
    .DPHASE_SOURCE    ( "DISABLED"  ),
    .OUTDIVIDER_MUXA  ( "DIVA"      ),
    .OUTDIVIDER_MUXB  ( "DIVB"      ),
    .OUTDIVIDER_MUXC  ( "DIVC"      ),
    .OUTDIVIDER_MUXD  ( "DIVD"      ),
    .CLKI_DIV         ( 6           ),
    .CLKOP_ENABLE     ( "ENABLED"   ),
    .CLKOP_DIV        ( 20          ),
    .CLKOP_CPHASE     ( 4           ),
    .CLKOP_FPHASE     ( 0           ),
    .FEEDBK_PATH      ( "CLKOP"     ),
    .CLKFB_DIV        ( 15          )
  ) pll_i (
          .RST          ( ~rst_in   ),
          .STDBY        ( 1'b0      ),
          .CLKI         ( clk_i     ),
          .CLKOP        ( clk_inter ),
          .CLKFB        ( clk_inter ),
          .CLKINTFB     (           ),
          .PHASESEL0    ( 1'b0      ),
          .PHASESEL1    ( 1'b0      ),
          .PHASEDIR     ( 1'b1      ),
          .PHASESTEP    ( 1'b1      ),
          .PHASELOADREG ( 1'b1      ),
          .PLLWAKESYNC  ( 1'b0      ),
          .ENCLKOP      ( 1'b0      ),
          .LOCK         ( locked    )
  );

  assign clk_sys = clk_inter;

  // --- Reset Logic ---
  logic [4:0] locked_dly_r = 0;

  always @(posedge clk_sys) begin
    if (~locked | ~rst_in) begin
      locked_dly_r <= 'b0;
    end else begin
      if (~&locked_dly_r) locked_dly_r <= locked_dly_r + 'b1;
    end
  end

  assign rst_sys_n = locked & rst_in & (&locked_dly_r);

  // --- QSPI Buffers ---

  logic [7:0] uio_i;
  logic [7:0] uio_o;
  logic [7:0] uio_oe;

  BB buf0 (.I(uio_o[1]), .T(~uio_oe[1]), .O(uio_i[1]), .B(qspi_sdio_io[0]));
  BB buf1 (.I(uio_o[2]), .T(~uio_oe[2]), .O(uio_i[2]), .B(qspi_sdio_io[1]));
  BB buf2 (.I(uio_o[4]), .T(~uio_oe[4]), .O(uio_i[4]), .B(qspi_sdio_io[2]));
  BB buf3 (.I(uio_o[5]), .T(~uio_oe[5]), .O(uio_i[5]), .B(qspi_sdio_io[3]));

  assign qspi_cs_rom_on = uio_o[0];
  assign qspi_cs_ram_on = uio_o[6];
  assign qspi_sck_o     = uio_o[3];

  assign uio_i[0] = 1'b0;
  assign uio_i[3] = 1'b0;
  assign uio_i[6] = 1'b0;
  assign uio_i[7] = 1'b0;

  // --- TT06 ---

  logic [7:0] uo;
  assign out_o = uo[5:0];

  tt_um_meiniKi_tt06_fazyrv_exotiny i_tt_um_meiniKi_tt06_fazyrv_exotiny (
    .ui_in    ( {1'b0, in_i}  ),
    .uo_out   ( uo            ),
    .uio_in   ( uio_i         ),
    .uio_out  ( uio_o         ),
    .uio_oe   ( uio_oe        ),
    .ena      ( 1'b1          ),
    .clk      ( clk_sys       ),
    .rst_n    ( rst_sys_n     )
  );


endmodule