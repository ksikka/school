#ifndef __PROXY_H__
#define __PROXY_H__

#define MAXLINE 8192
#define MAX_CACHE_SIZE 1049000
#define MAX_OBJECT_SIZE 102400
#define CHUNK_SIZE 8192

struct line_list {
  char line[MAXLINE];
  struct line_list* next;
};

struct http_req {
  char hostname[MAXLINE];
  char filePath[MAXLINE];
  int serverPort;
  struct line_list* otherHeaders;
};

#include "csapp.h"
#include <stdio.h>
#include "req_parse.h"
#include <pthread.h>
#include "cache.h"
#include <string.h>

/* If you want debugging output, use "#define DEBUG" */
#ifdef DEBUG
# define dbg_printf(...) printf(__VA_ARGS__)
# define dbg_decrement_thread_cnt(...) decrement_thread_cnt(__VA_ARGS__)
#else
# define dbg_printf(...)
# define dbg_decrement_thread_cnt(...)
#endif


void handle_proxy_request (void * attr); //actually of type (prox_params *)
int forwardRequest(rio_t* clientRio, struct http_req* parsed_req, int* errPtr);
int forwardResponse(int clientfd, struct http_req* parsed_req, int serverfd);
int forwardCachedResponse(int clientfd, void* response, int responseLen);
int sendRequestLine(int serverfd, char* filePath);
int sendRequiredHeaders(int serverfd);
int sendRemainingHeaders(struct line_list* list, int serverfd);
int sendHostHeader(int serverfd, char* hostname);
void block_sigpipe(void);
void decrement_thread_cnt(void);
#endif
