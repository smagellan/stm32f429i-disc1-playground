#include "cpptestexterns.h"
#include <string>

int do_cpp_test(void) {
    std::string str("test");
    return str.length();
}