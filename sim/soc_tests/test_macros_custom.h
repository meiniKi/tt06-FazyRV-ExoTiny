
#define TEST_ST_RD( testnum, load_inst, store_inst, write_data, result, offset, base ) \
    TEST_CASE( testnum, x3, result, \
      la  x1, base; \
      li  x2, write_data; \
      store_inst x2, offset(x1); \
      load_inst x3, offset(x1); \
    )

#define TEST_ST_WT_RD( testnum, load_inst, store_inst, write_data, result, offset, base, wait_addr, wait_value ) \
    TEST_CASE( testnum, x3, result, \
      la  x1, base; \
      li  x2, write_data; \
      store_inst x2, offset(x1); \
    1: \
      li  x4, wait_addr; \
      li  x5, wait_value; \
      lw  x6, 0(x4); \
      bne x5, x6, 1b; \
      load_inst x3, offset(x1); \
    )