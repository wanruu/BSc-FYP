#include<stdio.h>
int main(int argc, char const *argv[])
{
	FILE *fp;
	/* building name list */
	fp = fopen("building.txt" , "r");
    /* error */
	if(fp == NULL) {
		perror("Can't open the file.");
		return(-1);
	}
    /* output */
	/*printf("[\n");
	char* str = malloc(sizeof(char)*100);
	while(fgets(str, 100, fp) != NULL) {
        printf("{\n");
        printf("\t\"type\": \"Point\", \n");
        printf("\t\"coordinates\": [0, 0], \n");
        printf("\t\"name\": \"");
		for(int i = 0; i < strlen(str) - 1; i++) {
			printf("%c", str[i]);
		}
		printf("\"\n}, \n");
	}
	printf("\n");*/
    
    printf("[");
    char* str = malloc(sizeof(char)*100);
    while(fgets(str, 100, fp) != NULL) {
        printf("Building(name: \"");
        for(int i = 0; i < strlen(str) - 1; i++) {
            printf("%c", str[i]);
        }
        printf("\"), \n");
    }
    printf("\n");
	return 0;
}
