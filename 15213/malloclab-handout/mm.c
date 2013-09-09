/*
 * mm.c
 *
 * Seg-list malloc
 * 
 * ksikka
 * @ksikka
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mm.h"
#include "memlib.h"

void *extend_heap (size_t size);
static int in_heap(const void *p);
static int aligned(const void *p);

/* If you want debugging output, use the following macro.  When you hand
 * in, remove the #define DEBUG line. */
#define DEBUG
#ifdef DEBUG
# define dbg_printf(...) printf(__VA_ARGS__)
#else
# define dbg_printf(...)
#endif


/* do not change the following! */
#ifdef DRIVER
/* create aliases for driver tests */
#define malloc mm_malloc
#define free mm_free
#define realloc mm_realloc
#define calloc mm_calloc
#endif /* def DRIVER */

/* single word (4) or double word (8) alignment */
#define ALIGNMENT 8

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(p) (((size_t)(p) + (ALIGNMENT-1)) & ~0x7)

/* A node in the list will consist of a Header and a Payload.
 * Header is 32 bits, lower bit encodes allocated or not. */



/* MACROS */
#define MAX(a,b) ((a) > (b) ? (a) : (b))

// contents of header block
  #define HDR(b_ptr) (*(((int *)(b_ptr)) - 1))

// returns size of block
  #define SIZE(b_ptr) ((*(((int *)(b_ptr)) - 1)) & (~ 0x7))

// returns 1 if block is allocated, 0 if free
  #define ALLOC(b_ptr) ((*(((int *)(b_ptr)) - 1)) & (0x1))

// contents of footer block
  #define FTR(b_ptr) (*((int*)(((char *)(b_ptr)) + ((*(((int *)(b_ptr)) - 1)) & (~ 0x7)))))

// return PREV and NEXT pointers in a free block
  #define PREV(p) (*((int**)p))
  #define NEXT(p) (*(((int**)p)+1))

// returns the ptr to the footer of the block to the left
// XXX

#define HEAP_XTEND 514
#define LOOK_AHEAD 5

#define MIN_SPACE_FOR_BLOCK 24
#define MIN_BLOCK_SIZE 16

// seg list boundaries
#define SEG1 512
#define SEG2 1024
#define SEG3 4096


/* GLOBAL VARIABLES */
// 4 seg lists
int * free_list[4]; // 4 free lists

// size of each seg-list, the following are used mm_checkheap
size_t free_list_size[4]; // ith entry is length of ith free list
int * heap_start;

/*
 * Initialize: return -1 on error, 0 on success.
 */
int mm_init(void) {
    free_list[0] = NULL;
    free_list[1] = NULL;
    free_list[2] = NULL;
    free_list[3] = NULL;

    free_list_size[0] = 0;
    free_list_size[1] = 0;
    free_list_size[2] = 0;
    free_list_size[3] = 0;

    // get space for 3 ints on the heap
    int * p;
    p = (int *) mem_sbrk(3 * 4);
    if ((long)p < 0) return -1;
    
    // 4 bytes of 0, padding
    * p = 0;
    
    // prologue header and footer
    p += 2;
    HDR(p) = 8 | 1;    
    FTR(p) = 8 | 1;    

    // add a block to the free list
    if (extend_heap(500) == NULL) return -1;
    heap_start = p += 2;

    return 0;
}

// returns index of the correct seg list
int get_free_list_idx(int size) {
  if (size < SEG1)
    return 0;
  if (size < SEG2)
    return 1; 
  if (size < SEG3)
    return 2;
  else 
    return 3;
}

void tack_onto_free_list(int * block) {
    int idx = get_free_list_idx(SIZE(block));
    PREV(block) = NULL;
    NEXT(block) = free_list[idx];
    if (free_list[idx] != NULL)
      PREV(free_list[idx]) = block;
    free_list[idx] = block;

    free_list_size[idx] ++;
}

// create another free block
void *extend_heap (size_t size) {
    size = ALIGN(MAX(MIN_BLOCK_SIZE,size));

    int * p;
    if ((p = (int *) mem_sbrk(size + 8)) == (int*) -1) return NULL;
    p++;

    HDR(p) = size;
    FTR(p) = size;
 
    tack_onto_free_list(p);

    // TODO epilogue

    return p;
}

void remove_from_free_list(int * curr) {
  int idx = get_free_list_idx(SIZE(curr));
  if (PREV(curr) == NULL) free_list[idx] = NEXT(curr);
  else NEXT(PREV(curr)) = NEXT(curr);

  if (NEXT(curr) != NULL)
    PREV(NEXT(curr)) = PREV(curr);
  free_list_size[idx] --;
}

void coalesce (int * ptr) {
  if (ptr == NULL || !in_heap(ptr) || ALLOC(ptr)) return;

  // get the ptr of block to right of this
  int * right_block = ((int *) (((char *)ptr) + SIZE(ptr))) + 2;

  // get the ptr of block to left of this
  int * left_block_footer = ((int *)(ptr)) - 2;
  size_t size = (*left_block_footer) & (~((long)7));
  int * left_block = (int *) (((char *)left_block_footer) - size);

  // if block on left is free, coalesce
  if(!ALLOC(left_block)) {
    remove_from_free_list(ptr);

    // adjust the size
    size_t new_size = SIZE(left_block) + SIZE(ptr) + 8; // 8 for bndry tags
    remove_from_free_list(left_block);
    HDR(left_block) = new_size;
    FTR(left_block) = new_size;
    tack_onto_free_list(left_block);

    ptr = left_block;
  }

  // if block on right is free, coalesce
  if(in_heap(right_block) && !ALLOC(right_block)) {
    remove_from_free_list(right_block);
    size_t new_size = SIZE(ptr) + SIZE(right_block) + 8; // 8 for bndry tags
    remove_from_free_list(ptr);
    HDR(ptr) = new_size;
    FTR(ptr) = new_size;
    tack_onto_free_list(ptr);
  }
}

// returns the smallest free block N blocks down the list
void *find_smallest(int size, void *curr, int N) {
  int i = 0;
  void *min_block = curr;
  int min_size = SIZE(curr);
  while (curr != NULL && i < N) {
    if (SIZE(curr) < min_size && SIZE(curr) >= size) {
      min_size = SIZE(curr);
      min_block = curr;
    }
    curr = NEXT(curr);
    i++;
  }
  return min_block;
}

// reduces size of first block and returns
// ptr to new block
void *split_block (void * block, size_t size) {
  int block_size = SIZE(block);
  HDR(block) = size;
  FTR(block) = size;

  size_t new_size = block_size - size - 8; //needs header and footer
  int * new_block = (int*) (((char *)block) + size + 8);
  HDR(new_block) = (int)new_size;
  FTR(new_block) = (int)new_size;
  return new_block;
}

/*
 * malloc
 */
void *malloc (size_t size) {
  if (size == 0) return NULL;
  // make the size aligned and bigger than min_size
  size = ALIGN(MAX(size, (size_t)MIN_BLOCK_SIZE));

  // go through free lists in ascending size order
  int idx = get_free_list_idx(size);
  while (idx < 4){
    int * curr = free_list[idx];

    // linked list traversal, first fit
    while (curr != NULL) {
      size_t block_size = SIZE(curr);
      if (block_size >= size) {
        // look ahead a few blocks in case there is a better fit
        curr = find_smallest(size,curr,LOOK_AHEAD);
        block_size = SIZE(curr);
        // split block if remainder would be larger than min block size
        if (((int)block_size) - ((int)size) >= MIN_SPACE_FOR_BLOCK) {
          remove_from_free_list(curr);
          int * new_block = split_block(curr,size);
          HDR(curr) += 1; FTR(curr) += 1; // set current block as allocated
          tack_onto_free_list(new_block);
        }
        else {
          HDR(curr) = block_size | 1;
          FTR(curr) = block_size | 1;
          remove_from_free_list(curr);
        }
        return curr;
      }
      curr = NEXT(curr);
    }
    idx ++;
  }
  // if program is here, no free blocks were large enough
  if (extend_heap(size + HEAP_XTEND) == NULL) return NULL;
  return malloc(size);
}

/*
 * free
 */
void free (void *ptr) {
    if(ptr == NULL || !ALLOC(ptr)) return;
    HDR(ptr) -= 1; //get rid of alloc 1 bit
    FTR(ptr) -= 1;

    tack_onto_free_list(ptr);

    coalesce(ptr);
}

/*
 * realloc - you may want to look at mm-naive.c
 * DISCLAIMER: MOSTLY COPIED FROM MM-NAIVE
 */
void *realloc(void *oldptr, size_t size) {
  size_t oldsize;
  void *newptr;

  /* If size == 0 then this is just free, and we return NULL. */
  if(size == 0) {
    free(oldptr);
    return 0;
  }

  /* If oldptr is NULL, then this is just malloc. */
  if(oldptr == NULL) {
    return malloc(size);
  }

  newptr = malloc(size);

  /* If realloc() fails the original block is left untouched  */
  if(!newptr) {
    return 0;
  }

  /* Copy the old data. */
  oldsize = SIZE(oldptr);
  if(size < oldsize) oldsize = size;
  memcpy(newptr, oldptr, oldsize);

  /* Free the old block. */
  free(oldptr);

  return newptr;
}

/*
 * calloc - you may want to look at mm-naive.c
 * This function is not tested by mdriver, but it is
 * needed to run the traces.
 * DISCLAIMER: COPIED FROM MM-NAIVE
 */
void *calloc (size_t nmemb, size_t size) {
  size_t bytes = nmemb * size;
  void *newptr;

  newptr = malloc(bytes);
  memset(newptr, 0, bytes);

  return newptr;
}


/*
 * Return whether the pointer is in the heap.
 * May be useful for debugging.
 */
static int in_heap(const void *p) {
    return p <= mem_heap_hi() && p >= mem_heap_lo();
}

/*
 * Return whether the pointer is aligned.
 * May be useful for debugging.
 */
static int aligned(const void *p) {
    return (size_t)ALIGN(p) == (size_t)p;
}

void print_block(int * p) {
    size_t size = SIZE(p);
    int alloc = ALLOC(p);
    printf("In block 0x%p.\nAllocated\t%d\nSize\t%zu\n",p,alloc,size);
    if (!alloc) {
      printf("Prev ptr: \t%p\nNext ptr:\t%p\n",PREV(p),NEXT(p));
    };
}

/*
 * mm_checkheap
 */
void mm_checkheap(int verbose) {
    unsigned int i = 0;
    int * curr;

    for (int idx = 0; idx < 4; idx ++) {
      curr = free_list[idx];
      int * prev = NULL;
      i = 0;
      if (verbose) printf("Traversing free list %d\n",idx+1);
      while(curr != NULL) {
        if (verbose) print_block(curr);
        // cycle detection
        assert(i < free_list_size[idx]);
        // check correct prev pointers
        assert(prev == PREV(curr));
        // check alignment of block
        assert(aligned(curr));
        // check if block, header, and footer are in the heap
        assert(in_heap(curr));
        assert(in_heap(((char *)curr) - 4));
        assert(in_heap(((char *)curr) + SIZE(curr)));
        // if free block, check if PREV and NEXT are in heap
        if (!ALLOC(curr)) {
          assert(NEXT(curr) == NULL || in_heap(NEXT(curr)));
          assert(PREV(curr) == NULL || in_heap(PREV(curr)));
        }

        prev = curr;
        curr = NEXT(curr);
        i++;
      }
      // at the end of the loop, i should equal the number of free blocks
      assert(i == free_list_size[idx]);
    }

    unsigned int total_free_list_size = free_list_size[0] + free_list_size[1] +
                                        free_list_size[2] + free_list_size[3];
    if (verbose) printf("Done.\n\nExploring the heap in order:");
    curr = heap_start;
    i = 0;
    while((unsigned long) curr < (unsigned long) mem_sbrk(0))
    {
      if (verbose) print_block(curr);
      // check alignment of block
      assert(aligned(curr));
      // check if block, header, and footer are in the heap
      assert(in_heap(curr));
      assert(in_heap(((char *)curr) - 4));
      assert(in_heap(((char *)curr) + SIZE(curr)));
      //hdr and ftr should be the same
      assert(HDR(curr) == FTR(curr));
      // counting free blocks
      if(!ALLOC(curr)) i++;
      curr = (int*) (((char*)curr) + SIZE(curr) + 4 + 4); //pass boundary tags
    }
    // at the end of the loop, i should equal the number of free blocks
    assert(i == total_free_list_size);
    if (verbose) printf("Done.\n\n\n");
}
