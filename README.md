# RISC-V-Internship
## Basic Details
**Name:** Rishabh Agarwal<br>
**College:** The LNM Institute of Information Technology<br>
**Email ID:** 24uec246@lnmiit.ac.in<br>
**GitHub Profile:** [Rishabh-Github](https://github.com/Rishabh-ece?tab=repositories)<br>
**LinkedIn Profile:** [Rishabh-LinkedIn](https://www.linkedin.com/in/rishabh-agarwal-ece/)<br>

---

<details>
<summary><b>Task 1:</b> Compilation of C Program using GCC and RISC-V GCC Compiler</summary>
<br>

This task demonstrates how to compile a simple C program using both the native GCC compiler and the RISC-V GCC compiler. The objective is to understand the compilation flow and observe the generated RISC-V assembly instructions.

---

# C Language Compilation using GCC

## Step 1: Navigate to Working Directory

```bash
cd /workspaces/vsd-riscv2/
cd samples
```

## Step 2: Create the C File

Open the terminal and navigate to your working directory. Create a new C source file using:

```bash
gedit sum_1ton.c
```

## Step 2: Write the Program

Write a program to calculate the sum of numbers from 1 to n.

![C program](Task1/c_code.png)

Save the file using `Ctrl + S`.

## Step 3: Compile and Execute using GCC

```bash
gcc sum_1ton.c
./a.out
```

![GCC Compilation Output](Task1/result_sum.png)

---

# RISC-V GCC Compilation

## Step 1: Display the C Program

```bash
cat sum_1ton.c
```

![C Program using cat command](Task1/cat_sum1ton.png)

## Step 2: Compile using RISC-V GCC Compiler

```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o sum_1ton.o sum_1ton.c
```

This cross-compiles the C source for the 64-bit RISC-V architecture using `-O1` optimization, generating an ELF object file with RISC-V machine instructions.

## Step 3: Generate Assembly Dump

```bash
riscv64-unknown-elf-objdump -d sum_1ton.o
```

`objdump -d` reverse-translates the binary into human-readable RISC-V assembly.

![RISC-V Assembly Dump](Task1/assembly_riscv.png)

## Step 4: View Assembly in `less` and Search for `main`

```bash
riscv64-unknown-elf-objdump -d sum_1ton.o | less
```

Inside `less`, type `/main` to jump directly to the `main` function.

### `-O1` Optimization — 15 Instructions in `main`

With `-O1`, the compiler applies basic optimizations. The `main` function contains **15 instructions**.

![RISC-V Objdump Main Output - O1](Task1/main-O1.png)

### `-Ofast` Optimization — 12 Instructions in `main`

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum_1ton.o sum_1ton.c
```

With `-Ofast`, the compiler applies aggressive optimizations, reducing `main` to just **12 instructions**.

![RISC-V Objdump Main Output - Ofast](Task1/main-ofast.png)

---

# `-O1` vs `-Ofast` — Key Differences

| Feature | `-O1` | `-Ofast` |
|---|---|---|
| **Optimization Level** | Basic | Aggressive / Maximum |
| **Instructions in `main`** | 15 | 12 |
| **Code Size** | Slightly reduced | Further reduced |
| **Standard Compliance** | Fully compliant | May relax IEEE/C standard |
| **Risk** | Very low | Edge-case math may differ |
| **Best Used For** | Development & debugging | Performance-critical builds |

---

# Conclusion

This task provided a hands-on understanding of the complete compilation pipeline — from writing a C program to analyzing its RISC-V assembly. By compiling with both GCC (native) and the RISC-V cross-compiler, we observed how high-level C code translates into architecture-specific instructions.

The comparison between `-O1` and `-Ofast` clearly illustrated the impact of compiler optimizations: `-O1` produced **15 instructions** in `main`, while `-Ofast` reduced this to **12 instructions**. This highlights a key trade-off in embedded systems — **correctness vs. performance** — and understanding it is essential for anyone working with RISC-V or low-level development.

</details>

---

<details>
<summary><b>Task 2:</b> SPIKE Simulation and Debugging using RISC-V GCC</summary>
<br>

This task demonstrates execution and debugging of a RISC-V compiled C program using the **SPIKE** simulator. Both `-O1` and `-Ofast` optimization levels are explored and compared.

---

## Step 1: Navigate to Working Directory

```bash
cd /workspaces/vsd-riscv2/
cd samples
```

---

## Step 2: Compile and Run using GCC (Native)

```bash
gcc sum1ton.c
./a.out
```

Then compile using RISC-V GCC and simulate with SPIKE:

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
spike pk sum1ton.o
```

Both produce the same output, confirming correctness of the RISC-V binary.

![SPIKE Program Output](Task2/result_spike.png)

---

## Step 3: Assembly of `<main>` — `-Ofast` vs `-O1`

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

![Assembly - O1](Task2/main-O1.png)

`-Ofast` reduces `main` from **15 → 12 instructions** by aggressively eliminating redundant operations.

---

## Step 4: Debugging with SPIKE (`-d` flag)

Open the interactive SPIKE debugger:

```bash
spike -d pk sum1ton.o
```

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

![SPIKE Debug - O1](Task2/debug-O1.png)

---

## Key Observations

- **`lui` (Load Upper Immediate):** Loads a value into the upper 20 bits of a register — used in `-Ofast` to build addresses/constants efficiently.
- **`li` (Load Immediate):** Loads a full immediate value directly into a register — more common in `-O1`.
- **`addi sp, sp, -16`:** Allocates 16 bytes of stack space at function entry — identical in both builds.
- Stack pointer changes identically in both: `0x7f7e9b50` → `0x7f7e9b40`.

---

## Conclusion

This task provided hands-on experience with RISC-V simulation and instruction-level debugging using SPIKE. By comparing `-O1` and `-Ofast`, it was observed that aggressive optimization reduces `main` from 15 to 12 instructions using more compact sequences (e.g., `lui` instead of `li`). Register tracing confirmed how values are loaded and how the stack pointer is managed at function entry — key concepts in understanding RISC-V calling conventions and processor execution flow.

</details>

---
