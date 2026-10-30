# C89 Terminal Syntax Highlighter

A lightweight, fast lexical syntax highlighter for C89 code written using **Flex** and C. It parses C source files or standard input streams and outputs syntax-highlighted code directly to the terminal using ANSI 24-bit Truecolor escape sequences.

## Features

* **C89 Compliant Tokenization:** Correctly highlights standard C89 keywords, types, strings, character constants, preprocessor directives, numbers, and operators.
* **Context-Aware Parsing:** Accurately separates identifiers from function calls and handles header paths (`#include <stdio.h>`) without misclassifying operators.
* **Modular Theme Engine:** Color themes are decoupled from lexing logic and defined in dedicated C source files (`theme.h` / `theme.c`).
* **Runtime Theme Switcher:** Easily toggle themes on the fly using command-line flags (`-t` / `--theme`).
* **Standard Stream Support:** Reads directly from files or works via UNIX pipes (`stdin`).

## Project Structure

```
.
├── highlighter.l   # Flex lexer rules and main application entry point
├── theme.h         # Theme structure definitions and API interfaces
├── theme.c         # Color palette implementations (TokyoNight, VS Code)
└── README.md       # Project documentation
```

## Prerequisites

Ensure you have a C compiler and Flex installed:

* **Flex** (Fast Lexical Analyzer Generator)
* **GCC** or **Clang**

### Installing Dependencies

* **Debian / Ubuntu:**
  ```bash
  sudo apt update
  sudo apt install flex gcc
  ```

* **Arch Linux:**
  ```bash
  sudo pacman -S flex gcc
  ```

* **macOS:**
  ```bash
  brew install flex gcc
  ```

## Compilation

Generate the C lexer source code from `highlighter.l` and compile both `lex.yy.c` and `theme.c` together:

```bash
flex highlighter.l
gcc lex.yy.c theme.c -o c_highlighter
```

## Usage

### Basic Execution

By default, the program uses the **TokyoNight** theme:

```bash
./c_highlighter sample.c
```

### Specifying a Theme

Use the `-t` or `--theme` flag to select a specific theme:

```bash
./c_highlighter -t vscode sample.c
./c_highlighter --theme tokyonight sample.c
```

### Piping from Standard Input

Pipe source code directly into the utility:

```bash
cat sample.c | ./c_highlighter -t vscode | less -R
```

## Available Themes

| Theme Name | Style Description | Default |
| :--- | :--- | :--- |
| `tokyonight` | Dark Neovim theme with italic `if`/`else` control statements, emerald types, and cyan operators. | **Yes** |
| `vscode` | Classic VS Code Dark+ palette featuring pink keywords, teal types, and yellow function calls. | No |

## Adding a Custom Theme

To add a custom theme:

1. Open `theme.c` and define a new `Theme` struct:

   ```c
   static const Theme theme_custom = {
       .name     = "custom",
       .if_else  = "\033[3m\033[38;2;...",
       .keyword  = "\033[38;2;...",
       .type     = "\033[38;2;...",
       .func     = "\033[38;2;...",
       .var      = "\033[38;2;...",
       .string   = "\033[38;2;...",
       .number   = "\033[38;2;...",
       .operator = "\033[38;2;...",
       .preproc  = "\033[38;2;...",
       .escape   = "\033[1m\033[38;2;...",
       .comment  = "\033[3m\033[38;2;...",
       .reset    = "\033[0m"
   };
   ```

2. Register the theme name inside `select_theme()` in `theme.c`:

   ```c
   const Theme* select_theme(const char *name) {
       if (name != NULL) {
           if (strcmp(name, "custom") == 0) return &theme_custom;
           if (strcmp(name, "vscode") == 0) return &theme_vscode;
           if (strcmp(name, "tokyonight") == 0) return &theme_tokyonight;
       }
       return &theme_tokyonight;
   }
   ```

3. Recompile:
   ```bash
   gcc lex.yy.c theme.c -o c_highlighter
   ```
