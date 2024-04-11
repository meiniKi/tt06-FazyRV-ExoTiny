// Copyright (c) 2024 Meinhard Kissich
// -----------------------------------------------------------------------------
// File  :  tt06_fazyrv_exotiny_valid.sv
// Usage :  Simulation wrapper for TT06 FazyRV ExoTiny.
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module tt06_fazyrv_exotiny_valid (
  input  logic        clk_i,
  input  logic        rst_i,
  // QSPI
  inout  logic        cs_ram_on,  // inout to be consistent with tt06
  inout  logic        cs_rom_on,  // inout to be consistent with tt06
  inout  logic        sck_o,      // inout to be consistent with tt06
  inout  logic [3:0]  sdio_io,
  //
  output logic        led_rst_n,
  output logic        led_r_n,
  output logic        led_g_n,
  //
  output logic        spi_sck_o,
  output logic        spi_sdo_o,
  input  logic        spi_sdi_i,
  //
  output logic [7:0]  dbg_o
);

// QSPI
logic [5:0] gpo;
logic [6:0] gpi;
logic       spi_sdi;
logic       spi_sdo;
logic       spi_sck;

logic [7:0] uio_in;
logic [7:0] uio_out;
logic [7:0] uio_oe;

logic rst_n;
logic locked;
logic clk_sys;

// Divide further for testing
logic clk_inter;
logic [3:0] clk_cnt;

always_ff @(posedge clk_inter) clk_cnt <= clk_cnt + 'b1;
assign clk_sys = clk_cnt[3];

// Clocking
SB_PLL40_PAD #(
		.FEEDBACK_PATH  ( "SIMPLE"    ),
		.DIVR           ( 4'b0011     ),  // DIVR =  3
		.DIVF           ( 7'b0101000  ),	// DIVF = 40
		.DIVQ           ( 3'b110      ),	// DIVQ =  6
		.FILTER_RANGE   ( 3'b010      )   // FILTER_RANGE = 2
) i_SB_PLL40_PAD (   
  .PACKAGEPIN    ( clk_i    ),
  .PLLOUTGLOBAL  ( clk_inter  ),
  .RESETB        ( ~rst_i   ),
  .BYPASS        ( 1'b0     ),
  .LOCK          ( locked   )
);

// Reset logic
logic [7:0] locked_dly_r;

always @(posedge clk_sys) begin
  if (~locked | rst_i) begin
    locked_dly_r <= 'b0;
  end else begin
    if (~&locked_dly_r) locked_dly_r <= locked_dly_r + 'b1;
  end
end

assign rst_n      = locked & ~rst_i & (&locked_dly_r);
assign led_rst_n  = rst_n; 

// SDIO high-z

SB_IO #(
  .PIN_TYPE       ( 6'b1010_01 ),
  .PULLUP         ( 1'b0       )
) io_sda[6:0] (
  .PACKAGE_PIN    ( {cs_ram_on, sdio_io[3:2], sck_o, sdio_io[1:0], cs_rom_on} ),
  .OUTPUT_ENABLE  ( uio_oe[6:0]  ),
  .D_OUT_0        ( uio_out[6:0] ),
  .D_IN_0         ( uio_in[6:0]  )
);

assign uio_in[7] = 1'b0;

tt_um_meiniKi_tt06_fazyrv_exotiny i_tt_um_meiniKi_tt06_fazyrv_exotiny (
  .ui_in    ( {spi_sdi, gpi}          ),
  .uo_out   ( {spi_sdo, spi_sck, gpo} ),
  .uio_in   ( uio_in                  ),
  .uio_out  ( uio_out                 ),
  .uio_oe   ( uio_oe                  ),
  .ena      ( 1'b1                    ),
  .clk      ( clk_sys                 ),
  .rst_n    ( rst_n                   )
);

// Indicators
assign led_r_n = gpo[0];
assign led_g_n = gpo[0];

assign dbg_o[0] = rst_n;
assign dbg_o[1] = clk_sys;
assign dbg_o[2] = uio_out[6];
assign dbg_o[3] = uio_out[0];
assign dbg_o[4] = uio_out[3];
assign dbg_o[5] = 'b0;
assign dbg_o[6] = gpo[0];;

// SPI
assign spi_sck_o = spi_sck;
assign spi_sdo_o = spi_sdo;

// conditional loopback for testing
assign spi_sdi =  gpo[1] ? 1'b1 : 
                  gpo[0] ? 1'b0 : spi_sdo;

assign gpi =  gpo[1] ? 6'h15 : 
              gpo[0] ? 6'h2A : 'h0;

endmodule
