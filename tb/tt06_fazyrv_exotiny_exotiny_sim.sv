// Copyright (c) 2024 Meinhard Kissich
// -----------------------------------------------------------------------------
// File  :  tt06_fazyrv_exotiny_sim.sv
// Usage :  Simulation wrapper for TT06 FazyRV ExoTiny.
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module tt06_fazyrv_exotiny_sim (
  input  logic clk_i,
  input  logic rst_in
);

localparam RAMSIZE = 1024*1024*16;

// QSPI
logic [5:0] gpo;
logic [6:0] gpi;
logic       spi_sdi;
logic       spi_sdo;
logic       spi_sck;

wire [7:0] uio_io;
logic [7:0] uio_out;
logic [7:0] uio_oe;


tt_um_meiniKi_tt06_fazyrv_exotiny i_tt_um_meiniKi_tt06_fazyrv_exotiny (
  .ui_in    ( {spi_sdi, gpi}          ),
  .uo_out   ( {spi_sdo, spi_sck, gpo} ),
  .uio_in   ( uio_io                  ),
  .uio_out  ( uio_out                 ),
  .uio_oe   ( uio_oe                  ),
  .ena      ( 1'b1                    ),
  .clk      ( clk_i                   ),
  .rst_n    ( rst_in                  )
);

//generate
//  genvar i;
//  for (i=0; i<8; i++) begin
//    assign uio_io[i] = uio_oe[i] ? uio_out[i] : 1'bz;
//  end
//endgenerate

assign uio_io[0] = uio_oe[0] ? uio_out[0] : 1'bz;
assign uio_io[1] = uio_oe[1] ? uio_out[1] : 1'bz;
assign uio_io[2] = uio_oe[2] ? uio_out[2] : 1'bz;
assign uio_io[3] = uio_oe[3] ? uio_out[3] : 1'bz;
assign uio_io[4] = uio_oe[4] ? uio_out[4] : 1'bz;
assign uio_io[5] = uio_oe[5] ? uio_out[5] : 1'bz;
assign uio_io[6] = uio_oe[6] ? uio_out[6] : 1'bz;
assign uio_io[7] = uio_oe[7] ? uio_out[7] : 1'bz;


spiflash i_spiflash (
  .csb ( uio_io[0] ),
  .clk ( uio_io[3] ),
  .io0 ( uio_io[1] ),
  .io1 ( uio_io[2] ),
  .io2 ( uio_io[4] ),
  .io3 ( uio_io[5] )
);

qspi_psram #( .DEPTH(RAMSIZE) ) i_qspi_psram (
  .sck_i    ( uio_io[3] ),
  .cs_in    ( uio_io[6] ),
  .io0_io   ( uio_io[1] ),
  .io1_io   ( uio_io[2] ),
  .io2_io   ( uio_io[4] ),
  .io3_io   ( uio_io[5] )
);

// conditional loopback for testing
assign spi_sdi =  gpo[1] ? 1'b1 : 
                  gpo[0] ? 1'b0 : spi_sdo;

assign gpi =  gpo[1] ? 6'h15 : 
              gpo[0] ? 6'h2A : 'h0;

endmodule
