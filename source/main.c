#include <stdio.h>
#include <stdlib.h>
#include "../include/mystfunctions.h"
#include "../include/myfilefunctions.h"

int main(void) {
    printf("--- Testing String Functions ---\n");

    const char* src = "Hello";
    char dest[50];

    printf("mystrlen(\"%s\") = %d\n", src, mystrlen(src));

    mystrcpy(dest, src);
    printf("mystrcpy -> \"%s\"\n", dest);

    char dest2[50];
    mystrncpy(dest2, "WorldXYZ", 5);
    dest2[5] = '\0';
    printf("mystrncpy(5) -> \"%s\"\n", dest2);

    char catbuf[50] = "Foo";
    mystrcat(catbuf, "Bar");
    printf("mystrcat -> \"%s\"\n", catbuf);

    printf("\n--- Testing File Functions ---\n");

    FILE* fp = fopen("include/mystfunctions.h", "r");
    if (!fp) {
        printf("Could not open test file.\n");
        return 1;
    }

    int lines, words, chars;
    if (wordCount(fp, &lines, &words, &chars) == 0) {
        printf("wordCount: lines=%d words=%d chars=%d\n", lines, words, chars);
    }
    fclose(fp);

    fp = fopen("include/mystfunctions.h", "r");
    char* matches[100];
    int n = mygrep(fp, "int", matches);
    printf("mygrep(\"int\") found %d matches\n", n);
    for (int i = 0; i < n; i++) {
        printf("  Match %d: %s", i + 1, matches[i]);
        free(matches[i]);
    }
    fclose(fp);

    return 0;
}
