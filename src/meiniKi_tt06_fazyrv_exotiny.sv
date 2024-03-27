/*
 * Copyright (c) 2024 Meinhard Kissich
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module meiniKi_tt06_fazyrv_exotiny (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // will go high when the design is enabled
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  localparam CHUNKSIZE  = 2;
  localparam CONF       = "MIN";
  localparam RFTYPE     = "BRAM";

  logic        cs_rom_n;
  logic        cs_ram_n;
  logic        gpi;
  logic        sck;
  logic [4:0]  sdi;
  logic [4:0]  sdo;
  logic [4:0]  sdoen;

  // TODO: final usage of IOs once rest is working
  assign uo_out  = 0;

  assign uio_out[0] = cs_rom_n;
  assign uio_out[1] = sdo[0];
  assign uio_out[2] = sdo[1];
  assign uio_out[3] = sck;
  assign uio_out[4] = sdo[2];
  assign uio_out[5] = sdo[3];
  assign uio_out[6] = cs_ram_n;
  assign uio_out[7] = gpo;

  assign uio_oe[0] = 1'b1;
  assign uio_oe[1] = sdoen[0];
  assign uio_oe[2] = sdoen[1];
  assign uio_oe[3] = 1'b1;
  assign uio_oe[4] = sdoen[2];
  assign uio_oe[5] = sdoen[3];
  assign uio_oe[6] = 1'b1;
  assign uio_oe[7] = 1'b1;

  assign sdi = {uio_in[5], uio_in[4], uio_in[2], uio_in[1]};

  exotiny #( 
    .CHUNKSIZE  ( CHUNKSIZE ),
    .CONF       ( CONF      ),
    .RFTYPE     ( RFTYPE    ),
    .GPOCNT     ( 'd1       )
  ) i_exotiny (
    .clk_i          ( clk     ),
    .rst_in         ( rst_n   ),
    .gpi_i          ( gpi_i   ),
    .gpo_o          ( gpo_o   ),

    .mem_cs_ram_on  ( cs_ram_n  ),
    .mem_cs_rom_on  ( cs_rom_n  ),
    .mem_sck_o      ( sck       ),
    .mem_sd_i       ( sdi       ),
    .mem_sd_o       ( sdo       ),
    .mem_sd_oen_o   ( sdoen     )
  );

endmodule
