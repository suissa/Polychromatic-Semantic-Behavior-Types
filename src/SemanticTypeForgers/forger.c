#include "forger.h"
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <regex.h>

static char* trim(const char* str) {
    if (!str) return NULL;
    while(isspace((unsigned char)*str)) str++;
    if(*str == 0) return strdup(str);
    const char* end = str + strlen(str) - 1;
    while(end > str && isspace((unsigned char)*end)) end--;
    end++;
    char* res = malloc(end - str + 1);
    memcpy(res, str, end - str);
    res[end - str] = 0;
    return res;
}

static char* to_lower(const char* str) {
    if (!str) return NULL;
    char* res = strdup(str);
    for(char* p = res; *p; p++) *p = tolower((unsigned char)*p);
    return res;
}

static ForgerValue primitiveStringToValue(const char* str) {
    char* trimmed = trim(str);
    char* lower = to_lower(trimmed);
    ForgerValue res;

    if (strlen(trimmed) == 0) {
        res.type = TYPE_STRING;
        res.data.string_val = trimmed;
        free(lower);
        return res;
    }

    if (strcmp(trimmed, "{}") == 0 || strcmp(trimmed, "[]") == 0) {
        res.type = TYPE_INT;
        res.data.int_val = 0;
        free(trimmed);
        free(lower);
        return res;
    }

    if (strcmp(lower, "true") == 0) {
        res.type = TYPE_BOOL;
        res.data.bool_val = true;
        free(trimmed);
        free(lower);
        return res;
    }
    if (strcmp(lower, "false") == 0) {
        res.type = TYPE_BOOL;
        res.data.bool_val = false;
        free(trimmed);
        free(lower);
        return res;
    }
    if (strcmp(lower, "null") == 0 || strcmp(lower, "undefined") == 0) {
        res.type = TYPE_NULL;
        free(trimmed);
        free(lower);
        return res;
    }

    regex_t regex;
    regcomp(&regex, "^[+-]?([0-9]+\\.?[0-9]*|\\.[0-9]+)(e[+-]?[0-9]+)?$", REG_EXTENDED | REG_ICASE);
    if (regexec(&regex, trimmed, 0, NULL, 0) == 0) {
        if (strchr(trimmed, '.') || strchr(lower, 'e')) {
            res.type = TYPE_DOUBLE;
            res.data.double_val = atof(trimmed);
        } else {
            res.type = TYPE_INT;
            res.data.int_val = atoll(trimmed);
        }
        regfree(&regex);
        free(trimmed);
        free(lower);
        return res;
    }

    regfree(&regex);
    res.type = TYPE_STRING;
    res.data.string_val = trimmed;
    free(lower);
    return res;
}

ForgerValue getPrimitiveType(ForgerValue v) {
    return v;
}

bool validate(const char* name, ForgerValue v) {
    if (name && strcmp(name, "PersonEmail") == 0) {
        ForgerValue prim = convertToPrimitive(v);
        if (prim.type == TYPE_STRING) {
            regex_t regex;
            int ret = regcomp(&regex, "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9.-]+$", REG_EXTENDED);
            if (ret == 0) {
                int match = regexec(&regex, prim.data.string_val, 0, NULL, 0);
                regfree(&regex);
                return match == 0;
            }
        }
        return false;
    }
    return false;
}

ForgerValue convertToPrimitive(ForgerValue v) {
    if (v.type == TYPE_STRING) {
        return primitiveStringToValue(v.data.string_val);
    }
    return v;
}

ForgerValue forge(const char* name, ForgerValue v) {
    if (name && strcmp(name, "PersonEmail") == 0 && !validate(name, v)) {
        printf("Validation failed for SemanticType: %s\n", name);
        exit(1);
    }
    return v;
}

ForgerValue proccessValue(ForgerValue v) {
    if (validate("test", v)) return v;

    // In C, processing a complex Object dynamically without an interpreter is non-trivial.
    // We will just return the converted primitive for now as an approximation.
    ForgerValue primitiveVal = convertToPrimitive(v);
    return forge("test", primitiveVal);
}
