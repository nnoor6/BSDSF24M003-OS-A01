#include "../include/mystfunctions.h"

int mystrlen(const char* s) {
    int len = 0;
    while (s[len] != '\0') len++;
    return len;
}

int mystrcpy(char* dest, const char* src) {
    int i = 0;
    while (src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';
    return i;
}

int mystrncpy(char* dest, const char* src, int n) {
    int i = 0;
    while (i < n && src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    while (i < n) {
        dest[i] = '\0';
        i++;
    }
    return i;
}

int mystrcat(char* dest, const char* src) {
    int dlen = mystrlen(dest);
    int i = 0;
    while (src[i] != '\0') {
        dest[dlen + i] = src[i];
        i++;
    }
    dest[dlen + i] = '\0';
    return dlen + i;
}
