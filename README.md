# RISC-V-Internship
## Basic Details
**Name:** Rishabh Agarwal<br>
**College:** The LNM Institute of Information Technology<br>
**Email ID:** 24uec246@lnmiit.ac.in<br>
**GitHub Profile:** [Rishabh-Github](https://github.com/Rishabh-ece?tab=repositories)<br>
**LinkedIn Profile:** [Rishabh-LinkedIn](https://www.linkedin.com/in/rishabh-agarwal-ece/)<br>

---

<details>
<summary><b>Task 1 :</b> Compilation of C Program using GCC and RISC-V GCC Compiler</summary>
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
<summary><b>Task 2.1 :</b> SPIKE Simulation and Debugging using RISC-V GCC</summary>
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
<details>
  <summary><b>Task 2.2 :</b> Traffic Light Controller Simulation — RISC-V GCC & SPIKE</summary>
  <br>

> **VSD RISC-V Internship | Revision Task 2**
> Compiled with `-O1` and `-Ofast` | Simulated on SPIKE | Objdump Analysis Included

---

## 📋 About the Project

This project simulates a **2-road Traffic Light Controller** using a **Finite State Machine (FSM)** in C. It cycles through 4 states representing real-world traffic light logic.

| State | Road A | Road B |
|-------|--------|--------|
| 0 | 🟢 Green | 🔴 Red |
| 1 | 🟡 Yellow | 🔴 Red |
| 2 | 🔴 Red | 🟢 Green |
| 3 | 🔴 Red | 🟡 Yellow |

---

## 🛠️ Step-by-Step Workflow

### Step 1 — Navigate to Working Directory

```bash
cd /workspaces/vsd-riscv2/
cd samples
```

---

### Step 2 — Write the C Program

The source code was written using **gedit** text editor inside the codespace environment.

```bash
gedit traffic_light.c
```

![C Code in Gedit](screenshots/gedit_code.png)

---

### Step 3 — Compile and Run with Native GCC

```bash
gcc traffic_light.c
./a.out
```

![GCC Output](screenshots/result_gcc.png)

---

### Step 4 — Compile with RISC-V GCC (Create Object File)

The C code is cross-compiled for RISC-V architecture using the following command:

```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o traffic_light.o traffic_light.c
ls -ltr traffic_light.o
```

![Object File Created](screenshots/obj_file.png)

> The `ls -ltr` confirms the object file `traffic_light.o` was successfully created (168136 bytes).

---

### Step 5 — Run on SPIKE Simulator

```bash
spike pk traffic_light.o
```

![RISC-V SPIKE Output](screenshots/result_riscv.png)

> Output is **identical** to native GCC — confirming the RISC-V binary works correctly on SPIKE.

---

### Step 6 — Objdump Analysis

Disassemble the binary to see the RISC-V assembly instructions:

```bash
riscv64-unknown-elf-objdump -d traffic_light.o | less
```

Search for main inside `less`:
```
/main
```

---

#### 🔷 Objdump with `-O1`

![Objdump O1 - Start Address](screenshots/main_O1_1.png)

From the screenshot above, `main` starts at address **`0x10184`**.

![Objdump O1 - End Address & Count](screenshots/main_O1_2.png)

`main` ends at **`0x102C8`**. Using the calculator shown:

```
Number of Instructions = (End Address − Start Address) / 4
                       = (0x102C8 − 0x10184) / 4
                       = 0x144 / 4
                       = 324 / 4
                       = 81 instructions
```

> Each RISC-V instruction = **4 bytes**, so we divide the byte difference by 4.

---

#### 🔶 Objdump with `-Ofast`

![Objdump Ofast - Start Address](screenshots/main_ofast_1.png)

`main` starts at address **`0x100B0`**.

![Objdump Ofast - End Address & Count](screenshots/main_ofast_2.png)

`main` ends at **`0x10214``. Using the calculator:

```
Number of Instructions = (0x10214 − 0x100B0) / 4
                       = 0x164 / 4
                       = 356 / 4
                       = 89 instructions
```

---

#### 📊 Comparison Table

| Flag | Start Address | End Address | Instructions |
|------|--------------|-------------|--------------|
| `-O1` | `0x10184` | `0x102C8` | **81** |
| `-Ofast` | `0x100B0` | `0x10214` | **89** |

---

#### ⚖️ Why does `-Ofast` have MORE instructions than `-O1`?

| Property | `-O1` | `-Ofast` |
|----------|-------|----------|
| Code size | Smaller (81 instr.) | Larger (89 instr.) |
| Execution speed | Moderate | Faster |
| Loop handling | Keeps original loop | May unroll loops |
| Stack allocated | 96 bytes | 112 bytes |

**Reason:** `-Ofast` applies aggressive techniques like **loop unrolling** (writes loop iterations explicitly instead of branching) and **function inlining** (prepares arguments inline instead of calling). This adds more instructions but eliminates branch penalties — so it runs faster even with more code.

> Analogy: `-O1` packs your bag normally. `-Ofast` unpacks and reorganizes everything for fastest access — uses more space but you grab things quicker.

---

### Step 7 — SPIKE Debug Mode

SPIKE's `-d` flag lets you step through every RISC-V instruction one by one — like watching your C code run at the hardware level.

```bash
spike -d pk traffic_light.o
```

---

#### 🔷 Debug with `-O1`

```bash
(spike) until pc 0 10184     # jump to start of main
(spike) reg 0 sp             # check stack pointer value
(spike)                      # press Enter to step instruction by instruction
```

![SPIKE Debug O1](screenshots/debug_O1.png)

**Key instructions visible in `-O1` debug:**

| Instruction | What it does |
|-------------|-------------|
| `addi sp, sp, -96` | Allocates 96 bytes on stack for local variables |
| `sd ra, 88(sp)` | Saves return address — so main knows where to go back |
| `sd s0, 80(sp)` | Saves registers that will be used inside the function |
| `jal ra, <puts>` | Calls `puts`/`printf` to print the traffic light state |
| `addiw s0, s0, 1` | Increments loop counter (`state++`) |
| `j <main+0xb0>` | Jumps back to top of loop |

---

#### 🔶 Debug with `-Ofast`

```bash
(spike) until pc 0 100b0     # jump to start of main (-Ofast address)
(spike) reg 0 sp
(spike)
```

![SPIKE Debug Ofast](screenshots/debug_ofast.png)

**Key differences in `-Ofast` debug:**

| Instruction | What it does |
|-------------|-------------|
| `lui a0, 0x21` | Loads string address **before** stack setup (aggressive reordering) |
| `addi sp, sp, -112` | Stack is **larger (112 bytes)** — more variables due to inlining |
| `addi a0, a0, 912` | Combines address calculation in fewer steps |
| `sd ra, 104(sp)` | Return address saved at higher offset (bigger stack frame) |

> Notice `-Ofast` starts by loading the string address (`lui`) even **before** allocating the stack — this is the compiler reordering instructions to keep the CPU pipeline busy.

---

#### 🔄 Side-by-Side Debug Difference

| | `-O1` | `-Ofast` |
|-|-------|----------|
| Main start address | `0x10184` | `0x100B0` |
| First instruction | `addi sp, sp, -96` | `lui a0, 0x21` |
| Stack size | 96 bytes | 112 bytes |
| Style | Conservative, readable | Aggressive, reordered |

---

## 🧰 Tools Used

| Tool | Purpose |
|------|---------|
| `gedit` | Writing C source code |
| `gcc` | Native x86 compilation and testing |
| `riscv64-unknown-elf-gcc` | Cross-compilation for RISC-V |
| `spike` | RISC-V ISA simulator |
| `pk` | Proxy kernel — minimal OS for SPIKE |
| `objdump` | Disassemble binary to RISC-V assembly |
| GitHub Codespaces | Cloud development environment |

---

## 📌 Key Learnings

1. Same C code → **different assembly** depending on the optimization flag.
2. `-Ofast` produces **more instructions** than `-O1` but runs **faster** due to loop unrolling and inlining.
3. Every RISC-V instruction = **4 bytes** → instruction count = address difference / 4.
4. The **function prologue** (`addi sp`, `sd ra`) and **epilogue** (`ld ra`, `ret`) are clearly visible in both objdump and debug.
5. `spike -d` is a powerful way to trace how C code maps to real hardware instructions.

---

## 👤 Author

**VSD RISC-V Internship**
*Revision Task 2 — SPIKE Simulation with -O1 and -Ofast*

---

*Environment: GitHub Codespaces | Toolchain: riscv64-unknown-elf-gcc | Simulator: SPIKE*
</details>

----
