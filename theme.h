#ifndef THEME_H
#define THEME_H

typedef struct {
    const char *name;
    const char *if_else;
    const char *keyword;
    const char *type;
    const char *func;
    const char *var;
    const char *string;
    const char *number;
    const char *op_color;
    const char *preproc;
    const char *escape;
    const char *comment;
    const char *reset;
} Theme;

/* Theme selector function */
const Theme* select_theme(const char *name);

#endif
