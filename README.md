# NCDC RISC-V Microarchitecture — Lab 24: SoC Integration with UART

## Course
**NCDC Cohort 02/2025 — Design Verification (DV)**
NUST Chip Design Centre (NCDC), NUST

## Module
**RISC-V Microarchitecture Module** — Lab 24

---

## Overview

This lab integrates a **RISC-V single-cycle processor** with a **UART peripheral** to form a minimal **System-on-Chip (SoC)**. The RISC-V core communicates with the UART transmitter through **memory-mapped I/O (MMIO)**, where a specific address range in the data memory space maps to UART control and data registers. A program running on the processor can write bytes to the UART by storing values to these special addresses, which then get serialised and transmitted over the TX line.

---

## SoC Architecture

```
RISC-V SoC (soc_top.sv)
│
├── RISC-V Single-Cycle Core
│   ├── progCounter.sv       ← Program Counter (PC)
│   ├── instrMem.sv          ← Instruction Memory (ROM)
│   ├── regFile.sv           ← 32-entry Register File
│   ├── alu.sv               ← Arithmetic Logic Unit
│   ├── aluControl.sv        ← ALU Control decoder
│   ├── controlUnit.sv       ← Main Control Unit (opcode decoder)
│   ├── immGen.sv            ← Immediate value sign-extender
│   └── dataMem.sv           ← Data Memory (RAM + MMIO decode)
│
└── UART Peripheral
    ├── uart_mm.sv           ← Memory-mapped UART wrapper (address decoder)
    └── uart_tx.sv           ← UART TX serialiser
```

---

## Memory Map

| Address Range | Peripheral | Register |
|--------------|-----------|---------|
| `0x0000–0x0FFF` | Data Memory (RAM) | General purpose read/write |
| `0x1000` | UART | TX Data Register — write byte to transmit |
| `0x1004` | UART | Status Register — bit 0 = TX busy flag |

When the processor executes `sw t0, 0x1000(zero)`, the value in `t0` is captured by `uart_mm.sv` and forwarded to the UART transmitter instead of being stored in RAM.

---

## Module Descriptions

### soc_top.sv
Top-level SoC integration. Wires the RISC-V core to the UART memory-mapped peripheral and instruction/data memories.

### uart_mm.sv
Memory-mapped UART wrapper. Decodes the processor's address bus and activates the UART TX when the address falls in the UART range. Provides a TX-busy status register so software can poll before sending the next byte.

### uart_tx.sv
UART transmitter. Accepts parallel byte input and outputs a UART-framed serial bitstream (start + 8 data + stop) at the configured baud rate.

### RISC-V Core modules
Standard single-cycle RV32I datapath: PC, instruction memory, control unit, register file, ALU, immediate generator, and data memory — all connected to implement the RISC-V base integer ISA.

---

## Repository Structure

```
├── soc_top.sv          # Top-level SoC integration
├── uart_mm.sv          # Memory-mapped UART interface
├── uart_tx.sv          # UART transmitter
├── progCounter.sv      # Program counter
├── instrMem.sv         # Instruction memory (ROM)
├── regFile.sv          # 32-entry register file
├── alu.sv              # Arithmetic Logic Unit
├── aluControl.sv       # ALU control signal decoder
├── controlUnit.sv      # Main control unit
├── immGen.sv           # Immediate sign extension
├── dataMem.sv          # Data memory with MMIO decode
├── toplevel.sv         # Alternative top-level wrapper
└── NCDC_Lab_Report_24.pdf   # Full lab report
```

---

## Concepts Demonstrated
- SoC design: integrating a processor core with a peripheral
- Memory-mapped I/O (MMIO) — peripherals accessed via load/store instructions
- RISC-V single-cycle datapath (RV32I) implementation in SystemVerilog
- UART TX peripheral design and baud rate configuration
- Address decoding logic for peripheral selection
- Software–hardware co-design: writing assembly to drive the UART
