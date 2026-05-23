# Compiler

Compiler sessional work for a small C-like language. The assignments build the compiler in stages: symbol-table management, lexical analysis, parsing with semantic checks, and intermediate assembly generation with simple optimization.

## Structure

- `Offline 1/` implements a scoped symbol table in C++. It supports nested scopes, insert/lookup/delete operations, and formatted scope printing from a command-driven input file.
- `Offline 2/` contains the Flex scanner. It recognizes keywords, identifiers, numbers, strings, character constants, comments, operators, and indentation warnings, while inserting identifiers into the symbol table.
- `Offline 3/` adds a Bison parser and semantic analysis. It builds a parse tree, tracks scopes, checks declarations and definitions, validates argument lists, and reports type-related errors.
- `Offline 4/` Intermidate Code Generation

## Build and Run

For the symbol-table assignment:

```bash
cd "Offline 1"
g++ driver.cpp -o driver
./driver
```

For the Flex scanner:

```bash
cd "Offline 2"
bash shell.sh
```

For the parser:

```bash
cd "Offline 3"
bash shell.sh
```

The scripts use `flex`, `bison`, `g++`, and `libfl`. Outputs such as logs, parse trees, generated C files, object files, and parser binaries are build artifacts.

## Notes

The code follows the assignment progression rather than a single polished compiler tree. I kept the intermediate versions separate because each stage was evaluated independently and because the later parser/code-generator work reuses and extends the same models.
