/*
 * Copyright (c) 2024 Meinhard Kissich
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_meiniKi_tt06_fazyrv_exotiny (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // will go high when the design is enabled
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  logic       cs_rom_n;
  logic       cs_ram_n;

  logic [5:0] gpo;
  logic [6:0] gpi;

  logic       spi_sck;
  logic       spi_sdo;
  logic       spi_sdi;

  logic       sck;
  logic [3:0] sdi;
  logic [3:0] sdo;
  logic [3:0] sdoen;

  // Reset sync
  // The one additional flop seems to stop detailed routing from converging.
  //logic       rst_sync_n;
  //always_ff @(posedge clk) rst_sync_n <= rst_n;

  // QSPI ROM / RAM interface
  // on purpose additional tristate IOs are avoided
  assign uio_out[0] = cs_rom_n;
  assign uio_out[1] = sdo[0];
  assign uio_out[2] = sdo[1];
  assign uio_out[3] = sck;
  assign uio_out[4] = sdo[2];
  assign uio_out[5] = sdo[3];
  assign uio_out[6] = cs_ram_n;
  assign uio_out[7] = 1'b0;

  // drive cs and sck in reset but
  // disable with enable --> might cause startup issues otherwise
  //
  assign uio_oe[0] = ena;
  assign uio_oe[1] = sdoen[0];
  assign uio_oe[2] = sdoen[1];
  assign uio_oe[3] = ena;
  assign uio_oe[4] = sdoen[2];
  assign uio_oe[5] = sdoen[3];
  assign uio_oe[6] = ena;
  assign uio_oe[7] = 1'b0;

  assign sdi = {uio_in[5], uio_in[4], uio_in[2], uio_in[1]};

  // GPOs, SPI outputs 
  assign uo_out[5:0]  = gpo;
  assign uo_out[6]    = spi_sck;
  assign uo_out[7]    = spi_sdo;

  // GPIs, SPI inputs 
  assign gpi[6:0]     = ui_in[6:0];
  assign spi_sdi      = ui_in[7];

  exotiny i_exotiny (
    .clk_i          ( clk       ),
    .rst_in         ( rst_n     ),

    .gpi_i          ( gpi       ),
    .gpo_o          ( gpo       ),

    .mem_cs_ram_on  ( cs_ram_n  ),
    .mem_cs_rom_on  ( cs_rom_n  ),
    .mem_sck_o      ( sck       ),
    .mem_sd_i       ( sdi       ),
    .mem_sd_o       ( sdo       ),
    .mem_sd_oen_o   ( sdoen     ),

    .spi_sck_o      ( spi_sck   ),
    .spi_sdo_o      ( spi_sdo   ),
    .spi_sdi_i      ( spi_sdi   )
);

endmodule
