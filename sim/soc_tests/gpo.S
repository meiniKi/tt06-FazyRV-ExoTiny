
#*****************************************************************************
# gpo.S
#-----------------------------------------------------------------------------
#
# Test gpo register
#

#include "../tests/riscv_test.h"
#include "../tests/test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # GPO write and readback
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lb, sb, 0b00000001, 0, 0x20000000 );
  TEST_ST_OP( 3, lb, sb, 0b00000010, 0, 0x20000000 );
  TEST_ST_OP( 4, lb, sb, 0b00000100, 0, 0x20000000 );
  TEST_ST_OP( 5, lb, sb, 0b00001000, 0, 0x20000000 );
  TEST_ST_OP( 6, lb, sb, 0b00010000, 0, 0x20000000 );
  TEST_ST_OP( 7, lb, sb, 0b00100000, 0, 0x20000000 );
  TEST_ST_OP( 8, lb, sb, 0b00000000, 0, 0x20000000 );

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
