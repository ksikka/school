/*
 * Karan Sikka
 * @ksikka
 *
 * */

#include "cachelab.h"
#include <getopt.h>
#include <unistd.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <string.h>

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *            Structs and Typedefs
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* The following are typedef terms:
 *
 * cache_event
 * cache_params
 * cache_stats
 * cache_line
 * cache_set
 * instruction
 */

// A cache result is either hit, coldmiss, or evictmiss
enum cache_event { hit, coldmiss, evictmiss };

// cache_params
typedef struct {
  int m;                 // bits in word
  int s;                 // set index bits
  int b;                 // block offset bits
  int t;                 // tag bits
  long long int E;                 // blocks per line
  long long int S;                 // number of sets
} cache_params;

// cache_stats
typedef struct {
  int hits;
  int misses;
  int evicts;
} cache_stats;

// cache_line ( as a node in a singly linked list )
struct cache_line {
  long long unsigned tag_bits;
  struct cache_line * next;
}; typedef struct cache_line cache_line;

// cache_set is an queue of cache_lines, so we make it a ptr to the first line
typedef cache_line * cache_set;

// instruction may be M/L/S, and it has a mem address
typedef struct {
  char acc_t;
  long long unsigned int mem_addr;
  char line[80];
} instruction;



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *            Function Prototypes
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* In: s, E, b, empty cache_params
 * Out: void (but fills in the cache_params) */
void init_cache_params(int s, int E, int b, cache_params * params);


/* In: A cache, cache params, and a mem address which is accessed.
 * Out: hit/coldmiss/evictmiss, and the cache gets updated.*/
enum cache_event apply_to_cache(cache_set * cache, cache_params params,
    long long unsigned int mem_acc_addr);

/* In: Array of instructions, its length, cache_stats initialized to 0.
 * Out: nothing. the cache_stats struct is mutated */
void simulate_cache(instruction * instr_arr, int length,
    cache_stats * c_stats, cache_params params, char verbose);

/* In: cache_event, ptr to cache_stats
 * Out: void, but it changes cache_stats */
void update_cache_stats(enum cache_event cache_result, cache_stats * c_stats);

/* In: ptr
 * Out: void. aborts program if ptr is null. */
void null_check(void * ptr);

/* In: cache_event, string dest
 * Out: nada, but filled dest. assumes correct input. */
void cache_event_to_string(enum cache_event cache_result, char * dest);

/* In: ptr to the root of a linked list
 * Out: nada. but it frees the list. */
void free_list(cache_line * curr);
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *            Main
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int main(int argc, char **argv)
{
  int s = -1, E = -1, b = -1;

  char verbose = 0;

  /** Note: usage string was taken from lab writeup */
  char * usage = "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>\n\
Options:\n\
  -h         Print this help message.\n\
  -v         Optional verbose flag.\n\
  -s <num>   Number of set index bits.\n\
  -E <num>   Number of lines per set.\n\
  -b <num>   Number of block offset bits.\n\
  -t <file>  Trace file.\n\
\n\
Examples:\n\
  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n\
  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace";
  /** end citation */

  char tracefile[80] = "";
  char c;
  int i = 0;

  while ((c = getopt(argc, argv, "s:E:b:t:h::v::")) != -1 )
  {
    switch(c)
    {
      case 's':
        s = atoi(optarg); break;
      case 'E':
        E = atoi(optarg); break;
      case 'b':
        b = atoi(optarg); break;
      case 't':
        strncpy(tracefile, optarg, 80); break;
      case 'h':
        i --;
        printf("\n\n%s\n\n",usage); exit(0);
      case 'v':
        i --;
        verbose = 1; break;
      default:
        i --;
        printf("\n\nError: %c is not a legal option.",optopt);
        printf("\nUse with -h for usage info.\n\n"); exit(1);
    }
    i++;
  }

  if (s < 0 || E < 0 || b < 0 || strlen(tracefile) == 0)
  {
    printf("Missing required command line argument\n");
    printf("%s\n\n",usage);
    exit(1);
  }

  int line_count = 0;
  char line[80];

  FILE *fr; 
  fr = fopen (tracefile, "rt");
  if(fr == NULL)
  {
    printf("Invalid filename!\n");
    exit(1);
  }

  // count lines
  i = 0;
  while(fgets(line, 80, fr) != NULL)
  {
    if(line[0] == 'I') continue;
    else line_count++;
  }
  rewind(fr);

  // allocate memory for program input
  instruction * instr_arr = calloc(line_count, sizeof(instruction));
  null_check(instr_arr);

  // read the file and get the important parts
  line_count = 0;
  while(fgets(line, 80, fr) != NULL)
  {
    if(line[0] == 'I') continue;

    // end string at newline
    char * nlptr = strstr(line, "\n");
    if (nlptr != NULL) strncpy(nlptr, "",1);

    strncpy(instr_arr[line_count].line, line, 80);
    sscanf (line, " %c %llx, %*d ", & (instr_arr[line_count].acc_t)
                                  , & (instr_arr[line_count].mem_addr));
    line_count++;
  }
  fclose(fr);

  cache_stats stats = {0, 0, 0};
  cache_params params;
  init_cache_params(s, E, b, & params);
  simulate_cache (instr_arr, line_count, & stats, params, verbose);
  printSummary(stats.hits, stats.misses, stats.evicts);
  free(instr_arr);
  return 0;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *            Function Implementations
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* In: s, E, b, empty cache_params
 * Out: void (but fills in the cache_params) */
void init_cache_params(int s, int E, int b, cache_params * params)
{
  int S, m, t;
  S = 1 << s;
  m = 64; // Assume 64-bit words
  t = m - s - b;

  params -> m = m;
  params -> s = s;
  params -> S = S;
  params -> t = t;
  params -> E = E;
  params -> b = b;
  return;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

enum cache_event apply_to_cache(cache_set * cache, cache_params params,
    long long unsigned int mem_acc_addr)
{
  unsigned int tag_bits = mem_acc_addr >> (params.s + params.b);
  unsigned int set_index = (mem_acc_addr >> (params.b))
                              - (tag_bits << (params.s));
  cache_line * curr_line, * prev_line, * prev_prev_line;
  int i;

  // check for hit by traversing the list
  i = 0;
  curr_line = cache[set_index];
  prev_line = NULL; // used for hit case
  prev_prev_line = NULL; //used for evict miss
  while (curr_line != NULL)
  {
    if (tag_bits == (curr_line -> tag_bits))
    {
      // cache hit!
      if (i == 0)
        return hit;
      prev_line -> next = curr_line -> next;
      curr_line -> next = cache[set_index];
      cache[set_index] = curr_line;
      return hit;
    }
    else
    {
      // not the right line, check the next one.
      prev_prev_line = prev_line;
      prev_line = curr_line;
      curr_line = curr_line -> next;
      i++;
    }
  }

  // there were no hits. does the cache have more room?
  if (i < params.E)
  {
    // cold miss, so create cache_line
    cache_line * newl = calloc(1,sizeof(cache_line));
    null_check(newl);
    newl -> tag_bits = tag_bits;
    newl -> next = cache[set_index];
    cache[set_index] = newl;
    return coldmiss;
  }
  else
  {
    // evict miss, LRU policy
    // invariant: the length of the list does not grow in this case.
    cache_line * newl = prev_line; // here, prev_line is last line in the set.
    newl -> tag_bits = tag_bits;
    if(params.E == 1) // this has to be a direct mapped cache
      newl -> next = NULL;
    else
    { 
      newl -> next = cache[set_index];
      prev_prev_line -> next = NULL;
    }
    cache[set_index] = newl;
    return evictmiss;
  }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void simulate_cache (instruction * instr_arr, int length,
    cache_stats * c_stats, cache_params params, char verbose)
{
  int i;

  cache_set cache[params.S];
  // initialize the cache
  for (i = 0; i < params.S; i++) {
    cache[i] = NULL;
  }

  for (i = 0; i < length; i++)
  {
    long long unsigned int mem_acc_addr = instr_arr[i].mem_addr;
    char acc_t = instr_arr[i].acc_t;
    enum cache_event cache_result;
    char verbose_buf[14];

    switch (acc_t) {
      case 'M':
        // Load ...
        cache_result = apply_to_cache(cache, params, mem_acc_addr);
        update_cache_stats(cache_result, c_stats);
        // and Store will be a hit.
        update_cache_stats(hit, c_stats);
        cache_event_to_string(cache_result, verbose_buf);
        if(verbose)
            printf("%s %s hit\n", & instr_arr[i].line[1]
                ,verbose_buf);
        break;

      case 'L':
      case 'S':
        // Load or Store
        cache_result = apply_to_cache(cache, params, mem_acc_addr);
        update_cache_stats(cache_result, c_stats);
        cache_event_to_string(cache_result, verbose_buf);
        if(verbose)
            printf("%s %s\n", & instr_arr[i].line[1]
                , verbose_buf);
        break;

      default:
        printf("Invalid memory access type \"%c\". Bad input file.", acc_t);
        exit(1);
    }
  }

  for(i = 0; i < params.S; i++)
  {
    if(cache[i] != NULL) free_list(cache[i]);
  }
  return;
}

void update_cache_stats(enum cache_event cache_result, cache_stats * c_stats)
{
  // Increment the hit/miss/evicts appropriately
  switch (cache_result)
  {
    case hit:
      c_stats -> hits += 1;   break;
    case coldmiss:
      c_stats -> misses += 1; break;
    case evictmiss:
      c_stats -> misses += 1;
      c_stats -> evicts += 1; break;
    default: printf("Error in apply_to_cache function"); exit(1);
  }
}

void null_check(void * ptr)
{
  if (ptr == NULL)
  {
    printf("Not enough memory. Aborting.");
    exit(1);
  }
  else return;
}

void cache_event_to_string(enum cache_event cache_result, char * dest)
{
  char * dummy;
  switch(cache_result)
  {
    case hit:
      dummy = "hit"; break;
    case coldmiss:
      dummy = "miss"; break;
    case evictmiss:
      dummy = "miss eviction"; break;
  }
  strncpy(dest, dummy, 14);
  return;
}

void free_list(cache_line * curr)
{
  while(curr != NULL)
  {
    cache_line * next = curr -> next;
    free(curr);
    curr = next;
  }
  return;
}
