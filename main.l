%{
#include <stdio.h>
#include <string.h>
#include "theme.h"

const Theme *current_theme = NULL;

static int is_keyword(const char *s) {
    const char *kw[] = {"if", "else", "while", "for", "do", "return", "break", "continue", "switch", "case", "default", "goto", "sizeof"};
    for (size_t i = 0; i < sizeof(kw)/sizeof(kw[0]); i++) {
        if (strcmp(s, kw[i]) == 0) return 1;
    }
    return 0;
}

static int is_type(const char *s) {
    const char *tp[] = {"int", "char", "void", "float", "double", "long", "short", "signed", "unsigned", "struct", "union", "enum", "typedef", "const", "volatile", "static", "extern"};
    for (size_t i = 0; i < sizeof(tp)/sizeof(tp[0]); i++) {
        if (strcmp(s, tp[i]) == 0) return 1;
    }
    return 0;
}

static void print_keyword(const char *s) {
    if (strcmp(s, "if") == 0 || strcmp(s, "else") == 0) {
        printf("%s%s%s", current_theme->if_else, s, current_theme->reset);
    } else {
        printf("%s%s%s", current_theme->keyword, s, current_theme->reset);
    }
}
%}

%option noyywrap
%x IN_STRING IN_INC

%%

"/*"([^*]|\*+[^*/])*\*+"/"          { printf("%s%s%s", current_theme->comment, yytext, current_theme->reset); }

^[ \t]*#[ \t]*include              { printf("%s%s%s", current_theme->preproc, yytext, current_theme->reset); BEGIN(IN_INC); }
^[ \t]*#[ \t]*[a-zA-Z_][a-zA-Z0-9_]* { printf("%s%s%s", current_theme->preproc, yytext, current_theme->reset); }

<IN_INC>\<[^>\n]+\>                { printf("%s%s%s", current_theme->string, yytext, current_theme->reset); BEGIN(INITIAL); }
<IN_INC>\"([^\\\"]|\\.)*\"         { printf("%s%s%s", current_theme->string, yytext, current_theme->reset); BEGIN(INITIAL); }
<IN_INC>\n                         { ECHO; BEGIN(INITIAL); }
<IN_INC>[ \t]+                     { ECHO; }
<IN_INC>.                          { ECHO; BEGIN(INITIAL); }

\"                                 { BEGIN(IN_STRING); printf("%s\"", current_theme->string); }
<IN_STRING>\\.|%[a-zA-Z]           { printf("%s%s%s", current_theme->escape, yytext, current_theme->string); }
<IN_STRING>\"                      { printf("\"%s", current_theme->reset); BEGIN(INITIAL); }
<IN_STRING>.                       { printf("%s", yytext); }

'([^'\\\n]|\\.)*'                  { printf("%s%s%s", current_theme->string, yytext, current_theme->reset); }

[a-zA-Z_][a-zA-Z0-9_]*[ \t]*\(    {
    char name[128];
    size_t i = 0;
    while (yytext[i] && yytext[i] != '(' && yytext[i] != ' ' && yytext[i] != '\t' && i < sizeof(name) - 1) {
        name[i] = yytext[i];
        i++;
    }
    name[i] = '\0';

    if (is_keyword(name)) {
        print_keyword(name);
    } else if (is_type(name)) {
        printf("%s%s%s", current_theme->type, name, current_theme->reset);
    } else {
        printf("%s%s%s", current_theme->func, name, current_theme->reset);
    }
    yyless(i);
}

[a-zA-Z_][a-zA-Z0-9_]*             {
    if (is_keyword(yytext)) {
        print_keyword(yytext);
    } else if (is_type(yytext)) {
        printf("%s%s%s", current_theme->type, yytext, current_theme->reset);
    } else if (strcmp(yytext, "NULL") == 0) {
        printf("%s%s%s", current_theme->number, yytext, current_theme->reset);
    } else {
        printf("%s%s%s", current_theme->var, yytext, current_theme->reset);
    }
}

"->"|"."|"+"|"-"|"*"|"/"|"%"|"++"|"--"|"=="|"!="|"<="|">="|"<"|">"|"&&"|"||"|"!"|"&"|"|"|"^"|"~"|"<<"|">>"|"="|"+="|"-="|"*="|"/="|"%="|"&="|"|="|"^="|":"|"?" {
    printf("%s%s%s", current_theme->op_color, yytext, current_theme->reset);
}

[0-9]+                             { printf("%s%s%s", current_theme->number, yytext, current_theme->reset); }

.|\n                               { ECHO; }

%%

int main(int argc, char **argv) {
    const char *theme_name = NULL;
    const char *filename = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0 || strcmp(argv[i], "--theme") == 0) {
            if (i + 1 < argc) {
                theme_name = argv[++i];
            }
        } else if (argv[i][0] != '-') {
            filename = argv[i];
        }
    }

    /* Load specified theme or default to Tokyonight */
    current_theme = select_theme(theme_name);

    if (filename) {
        yyin = fopen(filename, "r");
        if (!yyin) {
            perror("Error opening file");
            return 1;
        }
    }

    yylex();

    if (yyin && yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}
