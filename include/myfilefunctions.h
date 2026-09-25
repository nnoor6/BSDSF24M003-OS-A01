#ifndef MYFILEFUNCTIONS_H
#define MYFILEFUNCTIONS_H

#include <stdio.h>

/* Count lines, words, chars in a file stream.
   Return 0 on success, -1 on failure. */
int wordCount(FILE* file, int* lines, int* words, int* chars);

/* Search lines containing search_str and fill matches.
   Return count of matches, -1 on failure. */
int mygrep(FILE* fp, const char* search_str, char** matches);

#endif
