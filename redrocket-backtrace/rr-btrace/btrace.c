#include "btrace.h"
#include <backtrace.h>
#include <stdio.h>

#define BACKTRACE_SIZE 25

void print_backtrace(void) {
    printf("\nabout to trace\n");
    backtrace_t bt[BACKTRACE_SIZE];
    int count = backtrace_unwind(bt, BACKTRACE_SIZE);

    for (int i = 0; i < count; ++i) {
        printf("%p - %s@%p\n", bt[i].address, bt[i].name, bt[i].function);
    }
    printf("done trace\n");
}
