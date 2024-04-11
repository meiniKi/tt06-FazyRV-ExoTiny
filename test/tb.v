`default_nettype none `timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  initial begin
    $display("[tb.v] Simulation started");
    $timeformat(-3, 0, "ms", 12);
    while(1) begin
      #100_000_000;
      $display("(%t)", $realtime);
    end
  end

  reg clk;
  reg rst_n;

  localparam RAMSIZE = 1024*1024*16;

  // QSPI
  wire [5:0]  gpo;
  wire [6:0]  gpi;
  wire        spi_sdi;
  wire        spi_sdo;
  wire        spi_sck;

  wire [7:0]  uio_io;
  wire [7:0]  uio_out;
  wire [7:0]  uio_oe;

  tt_um_meiniKi_tt06_fazyrv_exotiny i_tt_um_meiniKi_tt06_fazyrv_exotiny (
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
    .ui_in    ( {spi_sdi, gpi}          ),
    .uo_out   ( {spi_sdo, spi_sck, gpo} ),
    .uio_in   ( uio_io                  ),
    .uio_out  ( uio_out                 ),
    .uio_oe   ( uio_oe                  ),
    .ena      ( 1'b1                    ),
    .clk      ( clk                     ),
    .rst_n    ( rst_n                   )
  );

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

  // pass / fail
  wire test_done;
  wire test_pass;

  assign test_done = gpo[5] & gpo[3];
  assign test_pass = test_done & gpo[4];

endmodule
