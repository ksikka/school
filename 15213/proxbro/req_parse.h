#ifndef __REQ_PARSE_H__
#define __REQ_PARSE_H__
#include "proxy.h"
int startsWith(char* str, char* prefix);
char* readHostname(char uri[], char hostname[]);
int isNum(char c);
char* readPort(char uri[], int* portPtr);
int parseURI(char uri[], char hostname[], int * portPtr, char path[]);
int parseRequest(struct line_list* lines, struct http_req* req);
#endif
