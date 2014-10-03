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
/* basic/time.c ---  Encapsulation to get system time and other goodies. */

/*--------------------------------------------------------------------------*/

#include "basic.h"
#include <sys/time.h>
#include <sys/times.h>
#include <sys/param.h>

#if ! (defined (sgi) || defined (__convex__) || defined (_IBMR2))
 extern time_t time();
 extern char * ctime();
 long times();
#endif

#define STRLEN  128

/*--------------------------------------------------------------------------*/

double basic_utime ()
     /* Returns user seconds elapsed since start of process. */
{
  /* struct tms is defined in <sys/times.h> (see man times); tms values are
     in "clock ticks per second", ie, HZ, which is defined in <sys/param.h> */
  struct tms buffer;
  (void) times (&buffer);
  return (((double) buffer.tms_utime) / ((double) HZ));
}

/*--------------------------------------------------------------------------*/

char* basic_hostname ()
     /* Returns pointer to hostname. */
{
  static char hname[STRLEN];
  (void) gethostname (hname, STRLEN);
  return (hname);
}

/*--------------------------------------------------------------------------*/

char* basic_date ()
     /* Gives date and time information in ASCII. */
{
  static char datime[STRLEN];
  time_t clock;
  char * ptr;
  int i;
  clock = time ((time_t *) 0);
  ptr = ctime (&clock);
  i = 1;
  while (*ptr and (i < STRLEN))
    {
      datime[i-1] = *ptr;
      i ++;
      ptr ++;
    }
  datime[i-1] = *ptr;
  if (datime[i-2] == '\n')
    datime[i-2] = 0;
  return (datime);
}

/*--------------------------------------------------------------------------*/

void basic_daytime (sec, micros, minwest, dst)
     int *sec, *micros, *minwest, *dst;  /* all output */
     /* See %man gettimeofday  and  /usr/include/sys/time.h  for more info.
        Note that tv_sec and tv_usec are casted to int. */
{
  struct timeval tp;
  struct timezone tzp;
  (void) gettimeofday (&tp, &tzp);
  *sec = (int) tp.tv_sec;
  *micros = (int) tp.tv_usec;
  *minwest = tzp.tz_minuteswest;
  *dst = tzp.tz_dsttime;
}

/*--------------------------------------------------------------------------*/

double basic_seconds ()
     /* Returns seconds elapsed since 00:00 GMT, Jan 1, 1970. */
{
  int seconds, microseconds, w, d;
  basic_daytime (&seconds, &microseconds, &w, &d);
  return ((double) seconds + microseconds / 1000000.0);
}

/*--------------------------------------------------------------------------*/

int basic_seed ()
     /* Returns some int seed for random genertors, */
{
  int seconds, microseconds, w, d;
  basic_daytime (&seconds, &microseconds, &w, &d);
  return (seconds);
}
