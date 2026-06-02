# RISC-V-Internship
##  Basic Details
**Name:** Rishabh Agarwal<br>
**College:** The LNM Institute of Information Technology <br>
**Email ID:** 24uec246@lnmiit.ac.in <br>
**GitHub Profile:** [Rishabh-ece](https://github.com/Rishabh-ece?tab=repositories)  <br>
**LinkedIN Profile:** [Rishabh Agarwal](https://www.linkedin.com/in/rishabh-agarwal-ece/) <br>


---

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

---
<details>
<summary> <b>Task 2:</b> SPIKE Simulation and Debugging using RISC-V GCC</summary>
<br>

This task demonstrates execution and debugging of a RISC-V compiled C program using the **SPIKE** simulator. Both `-O1` and `-Ofast` optimization levels are explored and compared.

---

## Step 1: Compile and Run using GCC (Native)

```bash
gcc sum1ton.c
./a.out
```

Then compile using RISC-V GCC with `-Ofast` and simulate:

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
spike pk sum1ton.o
```

Both produce the same output, confirming correctness of the RISC-V binary.

![SPIKE Program Output](Task2/result_spike.png)

---

## Step 2: Assembly of `<main>` — `-Ofast` vs `-O1`

### `-Ofast` — 12 Instructions

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
riscv64-unknown-elf-objdump -d sum1ton.o | less
```
Search `/main` to jump to the `<main>` function.

![Assembly - Ofast](Task2/main-ofast.png)

### `-O1` — 15 Instructions

```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
riscv64-unknown-elf-objdump -d sum1ton.o | less
```

![Assembly - O1](Task2/main_-O1.png)

`-Ofast` reduces `main` from **15 → 12 instructions** by aggressively eliminating redundant operations.

---

## Step 3: Debugging with SPIKE (`-d` flag)

Open the interactive SPIKE debugger:

```bash
spike -d pk sum1ton.o
```

---

### Debugging `-Ofast` build

Navigate to `<main>` at address `100b0`:

```bash
until pc 0 100b0
```

| Command | Instruction | Register | Before | After |
|---|---|---|---|---|
| `reg 0 a2` | `lui a2, 0x1` | `a2` | `0x0000000000000000` | `0x0000000000001000` |
| `reg 0 a0` | `lui a0, 0x21` | `a0` | — | `0x0000000000021000` |
| `reg 0 sp` | `addi sp, sp, -16` | `sp` | `0x000000007f7e9b50` | `0x000000007f7e9b40` |

![SPIKE Debug - Ofast](Task2/debugger.png)

---

### Debugging `-O1` build

Navigate to `<main>` at address `10184`:

```bash
until pc 0 10184
```

| Command | Instruction | Register | Before | After |
|---|---|---|---|---|
| `reg 0 sp` | `addi sp, sp, -16` | `sp` | `0x000000007f7e9b50` | `0x000000007f7e9b40` |
| `reg 0 a2` | `li a2, 45` | `a2` | — | `0x000000000000002d` |
| `reg 0 a1` | `li a1, 9` | `a1` | — | `0x0000000000000009` |

![SPIKE Debug - O1](Task2/debug_-O1.png)

---

## Key Observations

- **`lui` (Load Upper Immediate):** Loads a value into the upper 20 bits of a register. Used in `-Ofast` to build addresses/constants efficiently.
- **`li` (Load Immediate):** Loads a full immediate value directly into a register. More common in `-O1`.
- **`addi sp, sp, -16`:** Allocates 16 bytes of stack space by decrementing the stack pointer — seen in both builds.
- The stack pointer changes identically in both builds: `0x7f7e9b50` → `0x7f7e9b40`.

---

## Conclusion

This task provided hands-on experience with RISC-V simulation and instruction-level debugging using SPIKE. By comparing `-O1` and `-Ofast`, it was observed that aggressive optimization reduces the `main` function from 15 to 12 instructions by using more compact instruction sequences (e.g., `lui` instead of `li`). Register tracing confirmed how values are loaded and how the stack pointer is managed at the function entry — key concepts in understanding RISC-V calling conventions and processor execution flow.

</details>

----
