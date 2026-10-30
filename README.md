# C89 Terminal Syntax Highlighter

A lightweight, high-performance command-line C89 syntax highlighter written in **Flex** and **C**. It reads C source code and formats it directly for standard terminals using 24-bit ANSI Truecolor escape codes, styled after modern Neovim themes (TokyoNight / Catppuccin).

---

## Features

- **Strict C89 Compliance:** Built around the standard 32 C89 keywords and ISO C89 comment styles (`/* ... */`).
- **Neovim Aesthetic:**
  - *Italics* specifically tuned for control flow keywords (`if`, `else`).
  - Mint/emerald green highlights for standard C types (`int`, `char`, `void`, `struct`, etc.).
  - Warm amber yellow for C preprocessor directives (`#include`, `#define`).
  - Native support for header includes `<header.h>` and double-quoted strings.
  - Distinct styling for function calls, variables, operators, numbers, and string escape codes (`\n`, `%s`).
- **Context-Aware Parsing:** Uses Flex lookahead and `yyless()` backtracking so keywords followed by parentheses (e.g., `if(`) are never mistaken for function calls.
- **UNIX Pipeline Compatible:** Reads from `stdin` or standard file arguments, making it easy to pipe directly into pagers like `less -R`.

---

## Prerequisites

To build and run this project, you need:

- **Flex** (Fast Lexical Analyzer Generator)
- A standard C compiler (**GCC** or **Clang**)
- A terminal emulator supporting **24-bit Truecolor** and ANSI escape codes (e.g., Kitty, Alacritty, iTerm2, WezTerm, Windows Terminal)

### Installing Flex

- **Debian / Ubuntu:**
  ```bash
  sudo apt update
  sudo apt install flex gcc
  ```
- **Arch Linux:**
  ```bash
  sudo pacman -S flex gcc
  ```
- **macOS:**
  ```bash
  brew install flex gcc
  ```

---

## Building

1. Clone or download your repository.
2. Run Flex to generate the C lexer source code:
   ```bash
   flex nvim_highlighter.l
   ```
3. Compile the generated `lex.yy.c` with GCC:
   ```bash
   gcc lex.yy.c -o c89highlight
   ```

---

## Usage

### Direct File Argument
Pass any `.c` or `.h` file directly to the utility:

```bash
./c89highlight main.c
```

### Piping via `stdin`
Process code directly through standard input or pipe into a pager:

```bash
cat main.c | ./c89highlight | less -R
```

---

## Syntax Color Reference

| Code Element | Example | Style | Color Code |
| :--- | :--- | :--- | :--- |
| **Control Flow (`if`, `else`)** | `if`, `else` | *Italic* Purple | `#BB9AF7` |
| **Keywords** | `while`, `return`, `for` | Purple | `#BB9AF7` |
| **Types** | `int`, `char`, `void`, `struct` | Mint Green | `#41C591` |
| **Preprocessor** | `#include`, `#define` | Amber Yellow | `#E5C07B` |
| **Strings & Headers** | `"hello"`, `<stdio.h>` | Soft Lime Green | `#9ECE6A` |
| **Functions** | `printf()`, `main()` | Blue | `#7AA2F7` |
| **Operators** | `=`, `+`, `->`, `==` | Light Cyan | `#89DDFF` |
| **Escape Sequences** | `\n`, `%d`, `%s` | **Bold** Orange | `#FF9E64` |
| **Comments** | `/* comment */` | *Italic* Gray | `#565F89` |

