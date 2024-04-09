
#*****************************************************************************
# spic.S
#-----------------------------------------------------------------------------
#
# Test gpo register
#

#include "../tests/riscv_test.h"
#include "../tests/test_macros.h"
#include "test_macros_custom.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # SPI control registers
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lw, sw, 0x00000000, 0, 0x20000008 );

  # Prescaler isolated
  #
  TEST_ST_OP( 3, lw, sw, 0x0000000A, 0, 0x20000008 );
  TEST_ST_OP( 4, lw, sw, 0x00000005, 0, 0x20000008 );
  TEST_ST_OP( 5, lw, sw, 0x00000001, 0, 0x20000008 );
  TEST_ST_OP( 6, lw, sw, 0x00000000, 0, 0x20000008 );

  # auto, spol isolated
  #
  TEST_ST_OP( 7, lw, sw, 0x00000000, 0, 0x20000008 );
  TEST_ST_OP( 8, lw, sw, 0x00000200, 0, 0x20000008 );
  TEST_ST_OP(10, lw, sw, 0x00000400, 0, 0x20000008 );
  TEST_ST_OP(12, lw, sw, 0x00000600, 0, 0x20000008 );

  # spi size isolated
  #
  TEST_ST_OP(14, lw, sw, 0x00010000, 0, 0x20000008 );
  TEST_ST_OP(15, lw, sw, 0x00020000, 0, 0x20000008 );
  TEST_ST_OP(16, lw, sw, 0x00030000, 0, 0x20000008 );

  # combined
  TEST_ST_OP(17, lw, sw, 0x0001020A, 0, 0x20000008 );
  TEST_ST_OP(18, lw, sw, 0x00000605, 0, 0x20000008 );

  # don't care bits
  #
  TEST_ST_RD(19, lw, sw, 0xFFFFFFFF, 0x0003060F, 0, 0x20000008 );

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
