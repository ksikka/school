#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "mm.h"

/* MACROS */
#define MAX(a,b) ((a) > (b) ? (a) : (b))

#define HDR(b_ptr) (*(((int *)(b_ptr)) - 1))

#define SIZE(b_ptr) ((*(((int *)(b_ptr)) - 1)) & (~ 0x7))
#define ALLOC(b_ptr) ((*(((int *)(b_ptr)) - 1)) & (0x1))

// extracts size and dereferences memory at ptr + size
#define FTR(b_ptr) (*(((char *)(b_ptr)) + ((*(((int *)(b_ptr)) - 1)) & (~ 0x7))))

// return int*
#define PREV(p) (*((int**)p))
#define NEXT(p) (*(((int**)p)+1))



/* make a pretend block and do tests on it */
int main(int argc, char* argv) {
  char[] some_bytes[1000];
  some_bytes = ALIGN(some_bytes);
  assert( ((long) some_bytes) % 8 == 0);

  some_bytes[0] = 0xef;
  some_bytes[1] = 0xbe;
  some_bytes[2] = 0xad;
  some_bytes[3] = 0xde;
  some_bytes += 4;
  assert(HDR(some_bytes) == 0xdeadbeef);

  HDR(some_bytes) = 16 | 1;
  assert(SIZE(some_bytes) == 16);
  assert(ALLOC(some_bytes) == 1);

  char* footer = some_bytes + 16;
  * footer = 16 | 1;
  assert(FTR(some_bytes) == 16);

  return 0;
}
