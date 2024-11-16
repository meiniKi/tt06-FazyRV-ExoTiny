
#include "types.h"

#define GPO (*((volatile uint32_t*)(0x20000000)))
#define GPI (*((volatile uint32_t*)(0x20000004)))

#define ADR_RAM ((volatile uint32_t*)(0x10000000))