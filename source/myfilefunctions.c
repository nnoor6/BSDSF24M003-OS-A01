#include "../include/myfilefunctions.h"
#include <stdlib.h>
#include <string.h>

int wordCount(FILE* file, int* lines, int* words, int* chars) {
    if (!file || !lines || !words || !chars) return -1;

    *lines = 0;
    *words = 0;
    *chars = 0;

    int ch, in_word = 0;

    while ((ch = fgetc(file)) != EOF) {
        (*chars)++;
        if (ch == '\n') (*lines)++;

        if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            (*words)++;
        }
    }
    return 0;
}

int mygrep(FILE* fp, const char* search_str, char** matches) {
    if (!fp || !search_str || !matches) return -1;

    char buffer[1024];
    int count = 0;

    while (fgets(buffer, sizeof(buffer), fp) != NULL) {
        if (strstr(buffer, search_str) != NULL) {
            matches[count] = (char*)malloc(strlen(buffer) + 1);
            if (!matches[count]) return -1;
            strcpy(matches[count], buffer);
            count++;
        }
    }
    return count;
}
