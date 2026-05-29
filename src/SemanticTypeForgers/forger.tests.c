#include "forger.h"
#include <stdio.h>
#include <assert.h>

int main() {
    ForgerValue v1;
    v1.type = TYPE_INT;
    v1.data.int_val = 5;

    ForgerValue r1 = getPrimitiveType(v1);
    assert(r1.type == TYPE_INT && r1.data.int_val == 5);

    ForgerValue v2;
    v2.type = TYPE_STRING;
    v2.data.string_val = " 123 ";

    ForgerValue r2 = convertToPrimitive(v2);
    assert(r2.type == TYPE_INT && r2.data.int_val == 123);

    ForgerValue v3;
    v3.type = TYPE_STRING;
    v3.data.string_val = "true";

    ForgerValue r3 = convertToPrimitive(v3);
    assert(r3.type == TYPE_BOOL && r3.data.bool_val == true);

    ForgerValue v4;
    v4.type = TYPE_STRING;
    v4.data.string_val = "{}";

    ForgerValue r4 = convertToPrimitive(v4);
    assert(r4.type == TYPE_INT && r4.data.int_val == 0);

    printf("C tests passed\n");
    return 0;
}
