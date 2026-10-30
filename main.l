%{
#include <stdio.h>
#include <string.h>

/* Neovim Custom Palette */
#define C_IF_ELSE  "\033[3m\033[38;2;187;154;247m"  /* Italic Purple (if / else) */
#define C_KEYWORD  "\033[38;2;187;154;247m"        /* Purple (No Italics) */
#define C_TYPE     "\033[38;2;65;197;145m"         /* Emerald / Mint Green */
#define C_FUNC     "\033[38;2;122;162;247m"        /* Blue */
#define C_VAR      "\033[38;2;192;202;245m"        /* Off-white */
#define C_STRING   "\033[38;2;158;206;106m"        /* Soft Lime Green */
#define C_NUMBER   "\033[38;2;255;158;100m"        /* Orange */
#define C_OPERATOR "\033[38;2;137;221;255m"        /* Cyan */
#define C_PREPROC  "\033[38;2;229;192;123m"        /* Warm Yellow / Amber */
#define C_ESCAPE   "\033[1m\033[38;2;255;158;100m" /* Bold Orange */
#define C_COMMENT  "\033[3m\033[38;2;86;95;137m"   /* Italic Gray */
#define C_RESET    "\033[0m"

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
        printf("%s%s%s", C_IF_ELSE, s, C_RESET);
    } else {
        printf("%s%s%s", C_KEYWORD, s, C_RESET);
    }
}
%}

%option noyywrap
%x IN_STRING IN_INC

%%

"/*"([^*]|\*+[^*/])*\*+"/"          { printf("%s%s%s", C_COMMENT, yytext, C_RESET); }
"//".*                            { printf("%s%s%s", C_COMMENT, yytext, C_RESET); }

^[ \t]*#[ \t]*include              { printf("%s%s%s", C_PREPROC, yytext, C_RESET); BEGIN(IN_INC); }
^[ \t]*#[ \t]*[a-zA-Z_][a-zA-Z0-9_]* { printf("%s%s%s", C_PREPROC, yytext, C_RESET); }

<IN_INC>\<[^>\n]+\>                { printf("%s%s%s", C_STRING, yytext, C_RESET); BEGIN(INITIAL); }
<IN_INC>\"([^\\\"]|\\.)*\"         { printf("%s%s%s", C_STRING, yytext, C_RESET); BEGIN(INITIAL); }
<IN_INC>\n                         { ECHO; BEGIN(INITIAL); }
<IN_INC>[ \t]+                     { ECHO; }
<IN_INC>.                          { ECHO; BEGIN(INITIAL); }

\"                                 { BEGIN(IN_STRING); printf("%s\"", C_STRING); }
<IN_STRING>\\.|%[a-zA-Z]           { printf("%s%s%s", C_ESCAPE, yytext, C_STRING); }
<IN_STRING>\"                      { printf("\"%s", C_RESET); BEGIN(INITIAL); }
<IN_STRING>.                       { printf("%s", yytext); }

'([^'\\\n]|\\.)*'                  { printf("%s%s%s", C_STRING, yytext, C_RESET); }

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
        printf("%s%s%s", C_TYPE, name, C_RESET);
    } else {
        printf("%s%s%s", C_FUNC, name, C_RESET);
    }
    yyless(i);
}

[a-zA-Z_][a-zA-Z0-9_]*             {
    if (is_keyword(yytext)) {
        print_keyword(yytext);
    } else if (is_type(yytext)) {
        printf("%s%s%s", C_TYPE, yytext, C_RESET);
    } else if (strcmp(yytext, "NULL") == 0) {
        printf("%s%s%s", C_NUMBER, yytext, C_RESET);
    } else {
        printf("%s%s%s", C_VAR, yytext, C_RESET);
    }
}

"->"|"."|"+"|"-"|"*"|"/"|"%"|"++"|"--"|"=="|"!="|"<="|">="|"<"|">"|"&&"|"||"|"!"|"&"|"|"|"^"|"~"|"<<"|">>"|"="|"+="|"-="|"*="|"/="|"%="|"&="|"|="|"^="|":"|"?" {
    printf("%s%s%s", C_OPERATOR, yytext, C_RESET);
}

[0-9]+                             { printf("%s%s%s", C_NUMBER, yytext, C_RESET); }

.|\n                               { ECHO; }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) return 1;
    }
    yylex();
    return 0;
}