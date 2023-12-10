#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
	if (argc != 3) {
		printf("Usage: %s <filename> <string>\n", argv[0]);
		return 1;
	}
	char *filename = argv[1];
	char *string = argv[2];
	FILE *file = fopen(filename, "r");
	if (file == NULL) {
		perror("Error");
		return 1;
	}
	char line[1000];
	int line_number = 1;
	while (fgets(line, sizeof(line), file)) {
		if (strstr(line, string) != NULL) {
			printf("%d: %s", line_number, line);
		}
		line_number++;
	}
	fclose(file);
	return 0;
}
