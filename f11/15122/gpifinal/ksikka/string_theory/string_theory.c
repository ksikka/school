#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void rot13(char *str) {
  int i;
	int len;
	
  len = strlen(str);
  for (i = 0; i < len; i++) {
		if ('a' <= str[i] && str[i] <= 'z') {
			str[i] = (str[i] - 'a' + 13) % 26 + 'a';
		}
		else if ('A' <= str[i] && str[i] <= 'Z') {
			str[i] = (str[i] - 'A' + 13) % 26 + 'A';
		}
	}
}

/* Takes the command line arguments and ROT13s them. */
int main(int argc, char *argv[])
{
	int i;
	int length = 0;
	char *buf;

  if(argc == 1) return 0;

	for (i = 1; i < argc; i++) {
		length += strlen(argv[i]);
	}

	//buf = malloc((length+argc-1) * sizeof(char) + 1);
	buf = malloc(1 * 1000 * 1000* 32);
  assert(buf);


	strcpy(buf, argv[1]);
	for (i = 2; i < argc; i++) {
		strcat(buf, " ");
		strcat(buf, argv[i]);
	}
  
  rot13(buf);

	printf("%s\n", buf);
  free(buf);
	return 0;
}
