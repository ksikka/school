CC = gcc
CFLAGS = -g -Wall
LDFLAGS = -pthread

all: proxy

csapp.o: csapp.c csapp.h
	$(CC) $(CFLAGS) $(LDFLAGS) -c csapp.c

req_parse.o: req_parse.c proxy.h
	$(CC) $(CFLAGS) $(LDFLAGS) -c req_parse.c

proxy.o: proxy.c csapp.h cache.h
	$(CC) $(CFLAGS) $(LDFLAGS) -c proxy.c

cache.o: cache.c cache.h csapp.h
	$(CC) $(CFLAGS) $(LDFLAGS) -c cache.c

proxy: proxy.o req_parse.o cache.o csapp.o

submit:
	(make clean; cd ..; tar cvf proxylab.tar proxbro)

clean:
	rm -f *~ *.o proxy core

