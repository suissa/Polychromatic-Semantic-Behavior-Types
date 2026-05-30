#ifndef FORGER_H
#define FORGER_H

#include <stdbool.h>

typedef enum {
    TYPE_NULL,
    TYPE_INT,
    TYPE_DOUBLE,
    TYPE_BOOL,
    TYPE_STRING,
    TYPE_OBJECT
} ForgerType;

typedef struct {
    ForgerType type;
    union {
        long long int_val;
        double double_val;
        bool bool_val;
        char* string_val;
        void* object_val;
    } data;
} ForgerValue;

ForgerValue getPrimitiveType(ForgerValue v);
bool validate(const char* name, ForgerValue v);
ForgerValue convertToPrimitive(ForgerValue v);
ForgerValue forge(const char* name, ForgerValue v);
ForgerValue proccessValue(ForgerValue v);

#endif
