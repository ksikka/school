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
/* basic/basic.c --- Basic C Library, core routines and version information. */

/*---------------------------------------------------------------------------*/

#ifndef lint
  static char version[] = "@(#) Basic C Library 1.2";
  static char author[] = "Ernst Mucke, et al";
# include "copyright.h"
#endif

/*---------------------------------------------------------------------------*/

#include "basic.h"
#include <varargs.h>   /* Hey, we're using varargs! */

/*---------------------------------------------------------------------------*/

char basic_charbit_mask__[8] = {  128,  64,  32,  16,  8,  4,  2,  1 };
char basic_charbit_mask_n[8] = { ~128, ~64, ~32, ~16, ~8, ~4, ~2, ~1 };

/* NOTE: The masks must be global.  I don't see any reasonable way around it,
   except, giving up the macros. */

/* The headerfile basic.h defines the following macros:

   * macro basic_charbit_on(I,C) returns TRUE iff bit I in char C is set to 1;
   * macro basic_charbit_s1(I,C) sets bit I in char C to 1;
   * macro basic_charbit_s0(I,C) sets bit I in char C to 0;
     usage eg.:  c = basic_charbit_s1 (2,c);
   */

/*---------------------------------------------------------------------------*/

static void (* hook) () = NULL;

/* Global constants used in definitions in basic.h  --- don't tell anybody! */
char basic__assert_format[] = "Assertion failed in file \"%s\", at line %d.";
void (* basic__null_hook) () = NULL;
     
/*--------------------------------------------------------------------------*/

/*VARARGS0*/
/*ARGSUSED*/ 
void basic_relax (va_alist)
     va_dcl
       /* Just a dummy function, with a variable number of arguments. */
{ 
}

/*--------------------------------------------------------------------------*/

/*VARARGS0*/
/*ARGSUSED*/ 
int basic_relaxf (va_alist)
     va_dcl
       /* Dummy function, with a variable number of arguments, returning 0. */
{
  return (0);
}

/*--------------------------------------------------------------------------*/

/*VARARGS0*/ 
void basic_error (va_alist)
     va_dcl
       /* Procedure basic_error (format [, arg] ...) has a variable number
          of arguments.  It produces an message just like fprint or vfprint.
          Then it either aborts execution or calls a given error hook. */
{ /* See also headerfile <varargs.h> and % man varargs. */
  va_list args;
  char *fmt, *msg;
  va_start (args);
  fmt = va_arg (args, char *);
  basic_cb_push_buffer ();
  (void) basic_cb_vprintf (fmt, args);
  msg = STRDUP (basic_cb_str ());
  basic_cb_pop_buffer ();
  va_end (args);
  if (hook)
    { /* call hook */
      hook (msg);
    }
  else
    { /* print error message and abort execution (with coredump) */
      fprint (stderr, "%s\n", msg);
#ifdef __sgi
      (void) abort ();
#else
      abort ();
#endif      
    }
  FREE (msg);
}  

/*--------------------------------------------------------------------------*/

void basic_error_hook (user_error)
     void (* user_error) ();
     /* To specify an error hook call basic_error_hook (my_error) assuming
        my_error is a pointer to a function:
        .
        .             void my_error (error_message)
        .                char error_message[];
        .            { ... }
        .
        With this, basic_error() will generate the error_message and pass it
        to my_error().  This function might then do some cleanup and/or cause
        segmentation fault for dbx.  Use basic_error_hook (NULL_HOOK) to get
        default behaviour back. */
{
  hook = user_error;
}

/*---------------------------------------------------------------------------*/

int basic_kbytes (bytes)
     int bytes;
     /* Converts bytes to kilobytes (going to next higher integer). */
{
  return (If ((bytes > 0), bytes / 1024 + 1, bytes));
}

/*--------------------------------------------------------------------------*/

double basic_mbytes (bytes)
     int bytes;
     /* Converts bytes to megabytes. */
{
  return ((double) bytes / 1024.0 / 1024.0);
}

/*--------------------------------------------------------------------------*/

char* basic_strip (s)
     char *s;
     /* Returns a pointer to the first character in s that is not
        a special character, or NULL if no such character exists.
        Cf, man strpbrk(). */
{
  return ((char*) strpbrk 
          (s,
           "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"));
}

/*--------------------------------------------------------------------------*/

/*VARARGS0*/ 
void basic_system (va_alist)
     va_dcl
{ /* See also headerfile <varargs.h> and % man varargs. */
  va_list args;
  char *fmt, *cmd;
  int result;
  va_start (args);
  fmt = va_arg (args, char *);
  basic_cb_push_buffer ();
  (void) basic_cb_vprintf (fmt, args);
  cmd = STRDUP (basic_cb_str ());
  basic_cb_pop_buffer ();
  va_end (args);
  result = system (cmd);
  if (result != 0)
    print ("WARNING: basic_system(\"%s\") status=%d\n", cmd, result);
  FREE (cmd);
}  
