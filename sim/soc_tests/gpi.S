
#*****************************************************************************
# gpi.S
#-----------------------------------------------------------------------------
#
# Test gpi register
#

#include "../tests/riscv_test.h"
#include "../tests/test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # GPI
  #-------------------------------------------------------------

  li x1, 0x00;
  li x2, 0x20000000;
  sb x1, 0(x2);

  TEST_LD_OP( 2, lb, 0x0, 0, 0x20000004 );

  li x1, 0x01;
  li x2, 0x20000000;
  sb x1, 0(x2);

  TEST_LD_OP( 3, lb, 0x2A, 0, 0x20000004 );

  li x1, 0x02;
  li x2, 0x20000000;
  sb x1, 0(x2);

  TEST_LD_OP( 4, lb, 0x15, 0, 0x20000004 );

  li x1, 0x00;
  li x2, 0x20000000;
  sb x1, 0(x2);

  TEST_LD_OP( 5, lb, 0x00, 0, 0x20000004 );


  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
