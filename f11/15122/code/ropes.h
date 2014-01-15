/******************************************************************************
 *                    15-122 Principles of Imperative Computation, Fall 2011
 ******************************************************************************
 *   The interface for the rope data structure
 *
 ******************************************************************************/
/*****************************************************************************
		   Do not submit this file.
*****************************************************************************/

#ifndef ROPES_H_
#define ROPES_H_

#include <stdlib.h> /* for size_t */
#include <stdbool.h>  /* for bool */

typedef struct rope_node* rope;

struct rope_node
{
	size_t size;          /* size of the string in this rope */
	size_t position;      /* length of the left rope */
	rope left;    /* pointer to left child, NULL for leaves */
	rope right;   /* pointer to right child, NULL for leaves */
	char *data;           /* string data, NULL for interior nodes */
	size_t ref_count;     /* number of references to this rope */
};

/* Tests whether the rope satisfies the rope invariants. */
bool is_rope(rope str);

/* Creates a rope from a '\0'-terminated array of characters. */
rope rope_new(char* str);

/* Creates a new rope representing the concatenation of str1 and str2. */
rope rope_join(rope str1, rope str2);

/* Decrements reference counts for all nodes in the rope. If the count
becomes zero, frees the memory associated with that node. */
void rope_free(rope str);

/* Returns the character at the given index. */
char rope_charat(rope str, size_t idx);


/* Converts the rope to a '\0'-terminated char array. */
char* rope_to_chararray(rope str);


/* Returns 1 if str1 ">" str2.
    Returns 0 if str1 "=" str2.
    Returns -1 if str1 "<" str2.
*/
int rope_compare(rope str1, rope str2);

/* Returns a rope representing the substring between
the first index (inclusive) and the second index (exclusive). */
rope rope_sub(rope str, int i, int j);

#endif
