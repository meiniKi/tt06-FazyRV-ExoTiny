
#include "soc.h"

// This is a _very_ hacked-together first bring-up demo for the FazyRV-Exotiny in TinyTape06.

void busy_wait(uint32_t cycles)
{
  for (uint32_t i = 0; i < cycles; i++);
}


void overlay()
{
  for (uint32_t i = 0; i < 50; i++)
  {
    for (uint32_t s = 0; s < 40; s++)
    {
      GPO = 0x0000003F;
      for (uint32_t j = 0; j < i; j++)
        __asm__ volatile ("nop");
      GPO = 0x00000000;
      for (uint32_t j = i; j < 64; j++)
        __asm__ volatile ("nop");
    }
  }
  for (uint32_t i = 50; i != 0; i--)
  {
    for (uint32_t s = 0; s < 40; s++)
    {
      GPO = 0x0000003F;
      for (uint32_t j = 0; j < i; j++)
        __asm__ volatile ("nop");
      GPO = 0x00000000;
      for (uint32_t j = i; j < 64; j++)
        __asm__ volatile ("nop");
    }
  }
}


void seq1(uint32_t duration, uint32_t dly_cycles)
{
  uint32_t frm = duration;
  GPO = 0x00000001;
  while (frm != 0)
  {
    GPO = ( GPO<<1 | ((GPO>>5)&0x01));
    busy_wait(dly_cycles);
    frm--;
  }
}

void seq2(uint32_t duration, uint32_t dly_cycles)
{
  uint32_t frm = duration;
  GPO = 0x00000015;
  while (frm != 0)
  {
    GPO ^= 0x0000003F;
    busy_wait(dly_cycles);
    frm--;
  }
}

void seq3(uint32_t duration, uint32_t dly_cycles)
{
  uint32_t frm = duration;
  int direction = 1;
  GPO = 0x00000001;

  while (frm != 0)
  {
    if (GPO & (1 << 5))
      direction = -1;
    else if (GPO == 0x00000001)
      direction = 1;

    GPO = direction > 0 ? (GPO << 1) : (GPO >> 1);
    busy_wait(dly_cycles);
    frm--;
  }
}

void seq4(uint32_t duration, uint32_t dly_cycles)
{
  uint32_t frm = duration;
  GPO = 0x00000003;

  while (frm != 0)
  {
    GPO <<= 1;
    if (GPO & (1 << 5))
    {
      busy_wait(dly_cycles);
      GPO = 0x00000018;
    }
    else if (GPO == 0x00000018)
    {
      busy_wait(dly_cycles);
      GPO = 0x00000003;
    }
    busy_wait(dly_cycles);
    frm--;
  }
}

void seq5(uint32_t duration, uint32_t dly_cycles)
{
  uint32_t frm = duration;
  GPO = 0x00000001;
  uint32_t mask = 0x00000001;

  while (frm != 0)
  {
    GPO = mask;
    mask = (mask << 1) | 0x00000001;
    if (mask > 0x0000003F)
      mask = 0x00000001;

    busy_wait(dly_cycles);
    frm--;
  }
}


void main(void)
{
  while (1)
  {
    overlay();
    overlay();
    seq1(15, 40000);
    overlay();
    overlay();
    seq2(20, 40000);
    overlay();
    overlay();
    seq3(20, 40000);
    overlay();
    overlay();
    seq4(20, 40000);
    overlay();
    overlay();
    seq5(20, 40000);
  }
}
