# RISCV-Internship
##  Basic Details
**Name:** Rishabh Agarwal<br>
**College:** The LNM Institute of Information Technology <br>
**Email ID:** 24uec246@lnmiit.ac.in <br>
**GitHub Profile:** [Rishabh-ece](https://github.com/Rishabh-ece?tab=repositories)  <br>
**LinkedIN Profile:** [Rishabh Agarwal](https://www.linkedin.com/in/rishabh-agarwal-ece/) <br>

## Task 1: Compilation of C Program using GCC and RISC-V GCC Compiler

This task demonstrates how to compile a simple C program using both the native GCC compiler and the RISC-V GCC compiler. The objective is to understand the compilation flow and observe the generated RISC-V assembly instructions.

---

# C Language Compilation using GCC

Follow the steps below to compile and execute a C program in the github cloud environment.

## Step 1: Create the C File

Open the terminal and navigate to your working directory. Create a new C source file using:

```bash
gedit sum_1ton.c
```

This command opens the text editor where the C program can be written.

---

## Step 2: Write the Program

Write a program to calculate the sum of numbers from 1 to n.

![C program](Task1/c_code.png)

Save the file using:

```text
Ctrl + S
```

---

## Step 3: Compile and Execute using GCC

Run the following commands:

```bash
gcc sum_1ton.c
./a.out
```

The program output will be displayed on the terminal.

![GCC Compilation Output](Task1/result_sum.png)

---

# RISC-V GCC Compilation

In this section, the same C program is compiled using the RISC-V cross compiler.

---

## Step 1: Display the C Program

Use the following command to display the program contents:

```bash
cat sum_1ton.c
```

![C Program using cat command](images/cat_sum1ton.png)

---

## Step 2: Compile using RISC-V GCC Compiler

Execute the following command:

```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o sum_1ton.o sum_1ton.c
```

This generates a RISC-V object file.

---

## Step 3: Generate Assembly Dump

Run the following command to disassemble the object file:

```bash
riscv64-unknown-elf-objdump -d sum_1ton.o
```

![RISC-V Objdump Output](images/assembly_riscv.png)

The generated assembly instructions for the C program will now appear on the terminal.

To directly jump to the `main` function section, type:

```bash
/main
```

---

# Explanation of Important Compiler Options

## `-mabi=lp64`

Specifies the ABI (Application Binary Interface) for a 64-bit RISC-V system where:

* `long` = 64 bits
* pointers = 64 bits
* integers = 32 bits

---

## `-march=rv64i`

Defines the target RISC-V architecture.

* `rv64` → 64-bit RISC-V architecture
* `i` → Base integer instruction set

---

## `riscv64-unknown-elf-objdump`

Used to disassemble RISC-V binaries and inspect generated assembly instructions.

---

## `-O1`

Enables basic optimization techniques that improve execution speed and reduce code size without significantly increasing compilation time.

---

## `-Ofast`

Applies aggressive optimizations focused on maximum execution performance.

Example:

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum_1ton.o sum_1ton.c
```

This optimization level may slightly relax strict standard compliance in favor of speed.

---

# Common GCC Optimization Levels

| Optimization Flag | Description                        |
| ----------------- | ---------------------------------- |
| `-O0`             | No optimization                    |
| `-O1`             | Basic optimization                 |
| `-O2`             | Moderate optimization              |
| `-O3`             | High-level aggressive optimization |
| `-Os`             | Optimize for smaller binary size   |
| `-Ofast`          | Maximum speed optimization         |

---

# Conclusion

Through this task, the compilation flow of a C program was explored using both the native GCC compiler and the RISC-V cross compiler. The generated RISC-V assembly instructions were analyzed using `objdump`, providing insight into how high-level C code is translated into machine-level instructions for RISC-V architecture.
