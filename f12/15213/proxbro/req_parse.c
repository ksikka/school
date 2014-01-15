#include "req_parse.h"

/*
 * Returns an int as a bool
 */
int startsWith(char* str, char* prefix) {
  if (str == NULL || prefix == NULL) return 0;
  int i = 0;
  while (prefix[i] != '\0') {
    if (str[i] != prefix[i]) return 0;
    i++;
  }
  return 1;
}

/* 
 * Reads the host name into hostname, and returns the rest of the string.
 * Does not modify the string.
 */
char* readHostname(char uri[], char hostname[]) {
  if (uri == NULL) return NULL;
  int i = 0;
  char c;
  while (1) {
    c = uri[i];
    if (c == '\0' || c == ':' || c == '/') break;
    i++;
  }
  strncpy(hostname, uri, i);
  hostname[i] = '\0';
  if (c == ':') return uri + i + 1;
  if (c != '\0' && c != '/') return NULL;
  return uri + i;
}

int isNum(char c) {
  return (c >= '0' && c <= '9');
}

char* readPort(char uri[], int* portPtr) {
  if (uri == NULL || portPtr == NULL) return uri;
  *portPtr = 80;
  int i = 0;
  char c;
  int portVal = 0;
  while ((c = uri[i]) != '\0') {
    if (!isNum(c)) break;
    portVal = 10 * portVal + (c - '0');
    if (portVal > ((1<<16)-1)) {
      portVal = -1;
      break;
    }
    i++;
  }
  if (portVal != 0) *portPtr = portVal;
  return uri + i;
}

int parseURI(char uri[], char hostname[], int * portPtr, char path[]) {
  // test if line is /<filepath>
  if (uri[0] == '/') {
    strncpy(path, uri, MAXLINE);
    return 1;
  }

  // else test if line is http[s]://<hostportcombo>/<filepath>
  if (startsWith(uri, "http://")) uri += 7;
  else if (startsWith(uri, "https://")) uri += 8;
  else {
    app_error("Not a valid URI when parsing 1st req. line");
    return -1; // (not a recognized format)
  }

  /* grab the host name */
  uri = readHostname(uri, hostname);
  if (uri == NULL) return -1;
  /* grab the port (default to 80) */
  uri = readPort(uri, portPtr);
  if (uri == NULL || portPtr == NULL || *portPtr == -1) return -1;
  /* grab the path (default to /) */
  if (uri[0] == '\0') strcpy(path, "/");
  else strncpy(path, uri, MAXLINE);
  return 0;
}

/* 
 * Reads the request into the http_req struct
 */
int parseRequest(struct line_list* lines, struct http_req* req) {
  if (lines == NULL || req == NULL) {
    return -1;
  }
  /* parse first line into method/uri/header */
  char method[MAXLINE], uri[MAXLINE], version[MAXLINE];
  if (sscanf(lines->line, "%s %s %s", method, uri, version) != 3) {
    return -1;
  }
  if (strcmp(method, "GET")) {
    app_error("Recieved request was not a GET.\n");
    return -1;
  }
  /* parse the request, returning whether it was standard or weird */
  int port = 80;
  char hostname[MAXLINE], path[MAXLINE];
  int ans = parseURI(uri, hostname, &port, path);
  switch (ans) {
    /* uri is of the form http[s]://<url>:<port>/<path> */
    case 0:
      /* copy strings into given buffers */
      strncpy(req->hostname, hostname, MAXLINE);
      strncpy(req->filePath, path, MAXLINE);
      /* set the port and lines */
      req->serverPort = port;
      req->otherHeaders = lines->next;
      return 0;
    /* uri is of the form <path> */
    case 1:
      /* set the lines and path */
      req->otherHeaders = lines->next;
      strncpy(req->filePath, path, MAXLINE);

      /* look for a HOST header, and scan it for a host/port */
      struct line_list* current = lines->next;
      //char nameBuf[MAXLINE], valBuf[MAXLINE];
      while (current != NULL) {
        char* line = current -> line;
        if (startsWith(line, "Host:")) {
          line += strlen("Host:");
          char host[MAXLINE];
          switch (sscanf("%s:%d", line, host, &port)) {
            case 1:
              strncpy(req->hostname, host, MAXLINE);
              req->serverPort = 80;
              return 0;
            case 2:
              strncpy(req->hostname, host, MAXLINE);
              req->serverPort = port;
              return 0;
            default:
              return -1;
          }
        }
        current = current->next;
      }
      return -1;
    default:
      return -1;
  }
}

