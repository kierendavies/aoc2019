#include "stdio.h"
#include "stdlib.h"

int main() {
    int fuel = 0;
    char line[100];
    while (fgets(line, 100, stdin)) {
        int mass = atoi(line);
        mass = mass / 3 - 2;
        while (mass > 0) {
            fuel += mass;
            mass = mass / 3 - 2;
        }
    }
    printf("%d\n", fuel);
    return 0;
}
