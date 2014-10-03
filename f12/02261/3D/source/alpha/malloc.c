/*
 * Copyright (C) 2006 Murphy Lab,Carnegie Mellon University
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 * 
 * For additional information visit http://murphylab.web.cmu.edu or
 * send email to murphy@cmu.edu
 */
/* basic/malloc.c --- My very own routines to encapsulate malloc. */

/*---------------------------------------------------------------------------*/

#include "basic.h"
#include <sys/types.h>
#if ! (defined (NeXT) || defined (__convex__))
# include <malloc.h>
# define USE_mallinfo   /* Uncomment this when you don't have mallinfo(). */
#endif

/*---------------------------------------------------------------------------*/

#define REPORT_THRESHOLD  1000000

#define Proto  if (debug_level > 2) print /* Usage: Proto (printf_arguments) */

static int debug_level = 0;
static int total = 0;

typedef struct malist_record
{
  char *address;
  int bytes; 
  char *f;
  int l;
  long mark;
  struct malist_record *next;
} Malist;

static Malist *ml = NULL;  /* ml keeps track of allocated memory */
static int ml_len = 0;

static void malist_push(), malist_delete();  /* routines to manage ml */

/*---------------------------------------------------------------------------*/

char* basic_malloc (n, f, l)
     int n;    /* number of bytes, n > 0 */
     char *f;  /* for __FILE__ macro */
     int l;    /* for __LINE__ macro */
     /* This is the encapsulated malloc function. It calls malloc()
        (see man pages) and issues a basic_errro() when allocation fails.
        NOTE: This should only be used in connection with MALLOC marco in
        basic.h. */
{
  char *memory;
  Proto (">>> basic_malloc (n=%d, f=\"%s\", l=%d)\n", n, f, l);
  memory = malloc ((unsigned) n);
  if ((n < 1) or (not memory))
    basic_error ("basic_malloc: failed, n=%d, f=\"%s\", l=%d", n, f, l);
  Proto (">>> basic_malloc() returns 0x%x ... 0x%x\n", memory, &(memory[n]));
  total += n;
  if (debug_level > 0)
    malist_push (memory, n, f, l);
  return (memory);
}

/*---------------------------------------------------------------------------*/

char* basic_realloc (ptr, n, f, l)
     char *ptr;  /* pointer to memory to be re-allocated */
     int n;      /* number of bytes, n > 0 */
     char *f;    /* for __FILE__ macro */
     int l;      /* for __LINE__ macro */
     /* This is the encapsulated realloc function. It calls realloc()
        (see man pages) and issues a basic_errro() when allocation fails.
        NOTE: This should only be used in connection with REALLOC marco in
        basic.h. */
{
  char *memory;
  Proto (">>> basic_realloc (ptr=0x%x, n=%d, f=\"%s\", l=%d)\n", ptr, n, f, l);
  if (not ptr)
    basic_error ("basic_realloc: ptr=0");
  memory = realloc (ptr, (unsigned) n);
  if ((n < 1) or (not memory))
    basic_error ("basic_realloc: failed, ptr=0x%xn=%d, f=\"%s\", l=%d",
                 ptr, n, f, l);
  Proto (">>> basic_realloc() returns 0x%x ... 0x%x\n", memory, &(memory[n]));
  total += n;
  if (debug_level > 0)
    {
      malist_delete (ptr);
      malist_push (memory, n, f, l);
    }
  return (memory);
}

/*---------------------------------------------------------------------------*/

void basic_free (ptr, f, l)
     char *ptr;  /* pointer to memory to free */
     char *f;    /* for __FILE__ macro */
     int l;      /* for __LINE__ macro */
     /* This is the encapsulated free function. It calls free()
        (see man pages) and should only be used in FREE macro
        of basic.h, since FREE (ptr) sets ptr to NULL, too */
{
  Proto (">>> basic_free (ptr=0x%x, f=\"%s\", l=%d)\n", ptr, f, l);
  free (ptr);
  if (debug_level > 0)
    malist_delete (ptr);
}

/*---------------------------------------------------------------------------*/

char* basic_strdup (s1, f, l)
     char *s1;  /* string to be duplicated */
     char *f;   /* for __FILE__ macro */
     int l;     /* for __LINE__ macro */
     /* This function returns a pointer to a duplicate of string s1.
        The memory therefore is obtained by basic_malloc().  One should
        always call this function via the STRDUP macro of basic.h.  The
        resulting sring should be deallocated using FREE (ie, basic_free).
        NOTE: It "hides" the allocated string via basic_mark (..., -2).
        Cf, standard strdup(). */
{
  if (s1)
    {
      char *r = basic_malloc ((int) (sizeof (char) * (strlen (s1) + 1)), f, l);
      sprint (r, "%s", s1);
      basic_malloc_mark (r, -2);
      return (r);
    }
  else
    return (NULL);
}

/*---------------------------------------------------------------------------*/

void basic_malloc_debug (level)
     int level;
     /* To set the basic_malloc debugging level.
        Level i includes all levels l with l < i.
        The different levels have the following meaning:
        0 ... minimal or no debugging (default);
        1 ... keep track of allocated meomory;
        2 ... report size of malloc heap every REPORT_THRESHOLD bytes;
        3 ... protocol mode (see #define Proto);
        4 ... mallopt (M_DEBUG, 1); works on SGI's only! */
{
  debug_level = level;
#ifdef __sgi  
  mallopt (M_DEBUG, If ((level > 3), 1, 0));
#endif  
}

/*---------------------------------------------------------------------------*/

void basic_malloc_mark (ptr, mark)
     char *ptr;
     int mark;
     /* Marks memory object specified by ptr, provided it was allocated
        by this module, and the debugging level is larger than 0.
        The integer marks have different meaning according to their sign:
        == 0 ... unmarked;
        <  0 ... hidden (-1 ... via HIDE(), -2 ... via STRDUP());
        >= 0 ... in use */
{
  if (ml)
    { /* Note: ml is managed by malist_push(), etc. */
      Malist *p = ml;
      while (p->address)
        {
          if (p->address == ptr)
            {
              p->mark = mark;
              return;
            }
          p = p->next;
        }
    }
}

/*---------------------------------------------------------------------------*/

int basic_malloc_marked_bytes (a, b)
     int a, b;
     /* Returns total size of memory objects marked with m, st, a <= m <= b */
{
  int r = 0;
  if (ml)
    {
      Malist *p = ml;
      while (p->address)
        {
          if ((a <= p->mark) and (p->mark <= b))
            r += p->bytes;
          p = p->next;
        }
    }
  return (r);
}

/*---------------------------------------------------------------------------*/

void basic_malloc_list_print (file)
     FILE *file; /* output file; if NULL, call is ignored */
     /* Prints the internal list that keeps track of allocated memory
        objects to given file. */
{
  if (file and (debug_level > 0) and ml)
    {
      Malist *p = ml;
      fprint (file, "(basic_malloc list: %s", If (ml_len, "", "empty"));
      while (p->address)
        {
          fprint (file, "\n 0x%x-> %8d bytes, f=%12s, l=%3d",
                  p->address, p->bytes, p->f, p->l);
          if (p->mark < 0L)
            fprint (file, ", mark=%ld (hidden%s%s)",
                    p->mark,
                    If ((p->mark == -1), ":HIDE", ""),
                    If ((p->mark == -2), ":STRDUP", ""));
          else if (p->mark > 0L)
            fprint (file, ", mark=%ld", p->mark);
          p = p->next;
        }
      fprint (file, ")\n");
    }
}

/*---------------------------------------------------------------------------*/

void basic_malloc_info_print (file)
     FILE *file;  /* output file; if NULL, call is ignored */
     /* Prints some information about the malloc heap to given file. */
{
  if (file)
    {
      Basic_malloc_info *di = basic_malloc_info ();
      if (di->arena > 0)
        fprint (file,
                "(malloc arena: %dk, in use: %dk, sml: %dk, ord: %dk)\n",
                basic_kbytes (di->arena), basic_kbytes (di->used),
                basic_kbytes (di->used_sml), basic_kbytes (di->used_ord));
      if (debug_level > 0)
        {
          fprint (file, "(basic_malloc total: %dk", basic_kbytes (di->total));
          if (di->in_use >= 0)
            fprint (file, ", in use: %dk", basic_kbytes (di->in_use));
          if (di->hidden > 0)
            fprint (file, ", hidden: %dk", basic_kbytes (di->hidden));
          fprint (file, ")\n");
          if (di->in_use > 0) 
            basic_malloc_list_print (file);
        }
    }
}

/*---------------------------------------------------------------------------*/

Basic_malloc_info* basic_malloc_info ()
     /* Returns some malloc info. */
     /* NOTE: The returned address, which points to the info structure,
              is a constant.  Do not FREE() it and consider the fields
              of the structure as read-only. */
{
  static Basic_malloc_info info;
  info.total = total;
  info.in_use = basic_malloc_marked_bytes (0, MAXINT);
  info.hidden = basic_malloc_marked_bytes (-MAXINT, -1);
#ifdef USE_mallinfo
  {
    static struct mallinfo mi;
    mi = mallinfo ();
    info.arena = mi.arena;
    info.used_sml = mi.usmblks;
    info.used_ord = mi.uordblks;
    info.used = info.used_sml + info.used_ord;
  }
#else
  info.arena = info.used = info.used_sml = info.used_ord = -1;  /* undefined */
#endif
  return (&(info));
}

/*---------------------------------------------------------------------------*/

static void malist_push (address, bytes, f, l)
     char *address;
     int bytes;
     char *f;
     int l;
     /* Pushes malloc info on internal list ml to keep track of allocated
        memory. */
{
  Malist *new;
  Assert (address and (bytes > 0));
  if (ml == NULL)
    { /* initialize  with stopper! */
      ml = (Malist *) malloc (sizeof (Malist));
      bzero ((char *) ml, sizeof (Malist));
    }
  new = (Malist *) malloc (sizeof (Malist));
  ml_len ++;
  new->address = address;
  new->bytes = bytes;
  new->f = f;
  new->l = l;
  new->mark = 0L;
  new->next = ml;
  ml = new;
  if (debug_level > 1)
    { 
      static int last_report = 0;
      if (total - last_report > REPORT_THRESHOLD)
        {
#ifdef USE_mallinfo
          struct mallinfo mi;
          mi = mallinfo ();
          print ("(malloc arena: %dk, basic_malloc total: %dk)\n",
                 basic_kbytes (mi.arena), basic_kbytes (total));
#else
          print ("(basic_malloc total: %dk)\n", basic_kbytes (total));
#endif
          last_report = total;
        }
    }
}

/*---------------------------------------------------------------------------*/

static void malist_delete (address)
     char *address;
     /* Deletes given address from ml, if it finds it there. */
{
  if (address and ml)
    {
      Malist *p = ml;
      while (p->address)
        {
          if (p->address == address)
            { /* delete entry by copying the p->next record to p (stopper!) */
              Malist *succ = p->next;
              ml_len --;
              bcopy ((char *) succ, (char *) p, sizeof (Malist));
              free (succ);
              return;
            }
          p = p->next;
        }
    }
}
