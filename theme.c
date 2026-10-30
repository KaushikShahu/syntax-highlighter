#include "theme.h"
#include <string.h>

#define C_RESET "\033[0m"

/* Default: Neovim / TokyoNight Style */
static const Theme theme_tokyonight = {
    .name     = "tokyonight",
    .if_else  = "\033[3m\033[38;2;187;154;247m",  /* Italic Purple */
    .keyword  = "\033[38;2;187;154;247m",        /* Purple */
    .type     = "\033[38;2;65;197;145m",         /* Emerald Green */
    .func     = "\033[38;2;122;162;247m",        /* Blue */
    .var      = "\033[38;2;192;202;245m",        /* Off-white */
    .string   = "\033[38;2;158;206;106m",        /* Lime Green */
    .number   = "\033[38;2;255;158;100m",        /* Orange */
    .op_color = "\033[38;2;137;221;255m",        /* Cyan */
    .preproc  = "\033[38;2;229;192;123m",        /* Warm Amber */
    .escape   = "\033[1m\033[38;2;255;158;100m", /* Bold Orange */
    .comment  = "\033[3m\033[38;2;86;95;137m",   /* Italic Gray */
    .reset    = C_RESET
};

/* Alternative: VS Code Dark+ Style */
static const Theme theme_vscode = {
    .name     = "vscode",
    .if_else  = "\033[38;2;197;134;192m",        /* Pink */
    .keyword  = "\033[38;2;197;134;192m",        /* Pink */
    .type     = "\033[38;2;78;201;176m",         /* Teal */
    .func     = "\033[38;2;220;220;170m",        /* Yellow */
    .var      = "\033[38;2;156;220;254m",        /* Light Blue */
    .string   = "\033[38;2;206;145;120m",        /* Orange/Brown */
    .number   = "\033[38;2;181;206;168m",        /* Light Green */
    .op_color = "\033[38;2;212;212;212m",        /* Off-white */
    .preproc  = "\033[38;2;197;134;192m",        /* Pink */
    .escape   = "\033[38;2;215;186;125m",        /* Yellow-Orange */
    .comment  = "\033[38;2;106;153;85m",         /* Green */
    .reset    = C_RESET
};

const Theme* select_theme(const char *name) {
    if (name != NULL) {
        if (strcmp(name, "vscode") == 0) return &theme_vscode;
        if (strcmp(name, "tokyonight") == 0) return &theme_tokyonight;
    }
    /* Fallback default theme */
    return &theme_tokyonight;
}
