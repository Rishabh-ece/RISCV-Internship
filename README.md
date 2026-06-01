# RISC-V-Internship
##  Basic Details
**Name:** Rishabh Agarwal<br>
**College:** The LNM Institute of Information Technology <br>
**Email ID:** 24uec246@lnmiit.ac.in <br>
**GitHub Profile:** [Rishabh-ece](https://github.com/Rishabh-ece?tab=repositories)  <br>
**LinkedIN Profile:** [Rishabh Agarwal](https://www.linkedin.com/in/rishabh-agarwal-ece/) <br>


--------------------------------------------------------------------------------------------------

<details>
<summary><b>Task 1:</b> Compilation of C Program using GCC and RISC-V GCC Compiler</summary>
 <br>
 
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
 
![C Program using cat command](Task1/cat_sum1ton.png)
 
---
 
## Step 2: Compile using RISC-V GCC Compiler
 
Execute the following command:
 
```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o sum_1ton.o sum_1ton.c
```
 
This command cross-compiles the C source file for the 64-bit RISC-V architecture using basic `-O1` optimization, generating an ELF object file (`sum_1ton.o`) that contains RISC-V machine instructions instead of native x86 instructions.
 
---
 
## Step 3: Generate Assembly Dump
 
Run the following command to disassemble the object file and inspect all sections:
 
```bash
riscv64-unknown-elf-objdump -d sum_1ton.o
```
 
`objdump -d` reverse-translates the compiled binary back into human-readable RISC-V assembly, allowing you to examine exactly which instructions the compiler generated for each function in your program.
 
The generated assembly output for the compiled program is shown below:
 
![RISC-V Assembly Dump](Task1/assembly_riscv.png)
 
---
 
## Step 4: View Assembly in `less` and Search for `main`
 
To navigate the disassembly output more conveniently, pipe it into `less`:
 
```bash
riscv64-unknown-elf-objdump -d sum_1ton.o | less
```
 
Inside `less`, search for the `main` function by typing:
 
```text
/main
```
 
This jumps directly to the `main` section of the assembly.
 
### `-O1` Optimization — 15 Instructions in `main`
 
With `-O1` optimization, the compiler applies basic optimizations while keeping the code relatively readable. The `main` function contains **15 instructions**.
 
![RISC-V Objdump Main Output - O1](Task1/main-O1.png)
 
---
 
### `-Ofast` Optimization — 12 Instructions in `main`
 
Recompile using `-Ofast` for aggressive optimization:
 
```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum_1ton.o sum_1ton.c
```
 
With `-Ofast`, the compiler applies maximum speed optimizations, reducing the instruction count in `main` to just **12 instructions** — fewer operations mean faster execution.
 
![RISC-V Objdump Main Output - Ofast](Task1/assembly-Ofast.png)
 
---
 
 
# Conclusion
 
Through this task, the compilation flow of a C program was explored using both the native GCC compiler and the RISC-V cross compiler. The generated RISC-V assembly instructions were analyzed using `objdump`, providing insight into how high-level C code is translated into machine-level instructions for RISC-V architecture. A clear difference was observed between `-O1` (15 instructions in `main`) and `-Ofast` (12 instructions in `main`), demonstrating how compiler optimizations directly impact the generated instruction count.
</details> 
------------------------------------------------------------------------------------------------------------------
