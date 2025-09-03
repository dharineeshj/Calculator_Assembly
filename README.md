# Assembly Calculator

A simple x86-64 NASM assembly program to evaluate arithmetic expressions with `+`, `-`, `*`, `/`, and parentheses.

## Build

```bash
nasm -f elf64 calculator.asm -o calculator.o
ld calculator.o -o calculator -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc
```

## Run

```bash
./calculator
```

## Usage

Enter an expression (no spaces) and press Enter.
Example:

```
Enter the equation:(4+2)*2
12
```

