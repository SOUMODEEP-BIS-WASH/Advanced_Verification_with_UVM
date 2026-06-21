# Advanced_Verification_with_UVM

## Overview

This repository contains a collection of **UVM-based verification projects** implemented using **SystemVerilog and Universal Verification Methodology (UVM)**.

The goal of this repository is to build strong practical understanding of:

* UVM testbench architecture
* Constrained-random verification
* Functional coverage
* Scoreboard-based checking
* Reference model validation
* Reusable verification environments

Each project includes:

* RTL Design (DUT)
* UVM Testbench
* Constrained Random Stimulus
* Functional Coverage
* Scoreboard Validation

All projects were designed and simulated using **EDA Playground**.

---

# Repository Objectives

This repository focuses on building practical expertise in:

* UVM Components
* Transaction-level verification
* Sequencer-Driver communication
* Monitor-based transaction collection
* Scoreboard checking
* Coverage-driven verification

---

# UVM Architecture Used

All projects follow a standard UVM verification flow:

```text
          +-------------------+
          |       TEST        |
          +---------+---------+
                    |
          +---------v---------+
          |   ENVIRONMENT     |
          +----+---------+----+
               |         |
         +-----v--+   +--v------+
         | AGENT  |   |SCOREBOARD|
         +---+----+   +----------+
             |
   +---------+---------+
   |                   |
+--v----+         +----v--+
|DRIVER |         |MONITOR|
+-------+         +-------+
             |
         +---v---+
         | DUT   |
         +-------+
```

---

# Projects Included

---

## Project 1: RCA with UVM-Based Verification

### Design

4-bit Ripple Carry Adder

### Features

* Verifies arithmetic addition logic
* Randomized inputs for operands and carry-in
* Output validation using scoreboard

### Verification Highlights

* UVM sequence-driven testing
* Functional checking for SUM and COUT
* PASS/FAIL result logging

---

## Project 2: ALU with UVM-Based Verification

### Design

4-bit Arithmetic Logic Unit

### Supported Operations

* Addition
* Subtraction
* Multiplication
* Division
* AND
* OR
* NAND
* NOR

### Verification Highlights

* Constrained-random stimulus generation
* Functional coverage for opcode and input combinations
* Scoreboard-based reference model

---

## Project 3: Dual Port SRAM with UVM-Based Verification

### Design

256 × 8-bit Dual-Port SRAM

### Features

* Independent Read/Write operations
* Reset support
* Concurrent memory access

### Verification Highlights

* Read/Write sequence generation
* Memory reference model
* Functional coverage on addresses and data
* Read data validation

---

## Project 4: Synchronous FIFO with UVM-Based Verification

### Design

64 × 8-bit Synchronous FIFO

### Features

* FIFO write/read operations
* FULL and EMPTY flag generation
* Reset handling

### Verification Highlights

* FIFO reference model using queue
* Read data verification
* FULL/EMPTY flag validation
* Coverage-driven verification

---

# Key Verification Concepts Covered

* UVM Testbench Architecture
* Sequence Item Creation
* Sequence Generation
* Driver Implementation
* Monitor Sampling
* Scoreboard Design
* Functional Coverage
* Coverage Collection
* Reference Model Development

---

# Tools & Technologies

| Category     | Tool           |
| ------------ | -------------- |
| HDL          | Verilog        |
| Verification | SystemVerilog  |
| Methodology  | UVM            |
| Simulator    | EDA Playground |

---

# Repository Structure

```bash
UVM_Verification_Projects/
│
├── RCA_with_UVM_based_Verification/
├── ALU_with_UVM_based_Verification/
├── Dual_Port_SRAM_with_UVM_based_Verification/
├── Synchronous_FIFO_with_UVM_based_Verification/
│
└── README.md
```

---

# Skills Demonstrated

This repository demonstrates hands-on experience in:

* RTL Verification
* UVM Methodology
* Verification Planning
* Functional Coverage Analysis
* Constrained Random Testing
* Scoreboard Validation
* Debugging Verification Environments

---

---

# Learning Outcome

Through these projects, I gained practical experience in developing reusable and scalable verification environments using UVM.

This repository reflects my hands-on journey in digital verification and advanced verification methodologies.
