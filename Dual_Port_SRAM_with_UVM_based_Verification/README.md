# Dual_Port_SRAM_with_UVM_based_Verification

## Overview

This project implements a **256×8 Dual-Port SRAM** and verifies it using a complete **UVM-based verification environment** in SystemVerilog. The SRAM supports simultaneous read and write operations with separate read and write addresses, enabling efficient memory access.

The verification environment uses standard UVM components to generate transactions, drive stimulus, monitor DUT behavior, collect functional coverage, and validate outputs against a reference memory model.

## Tools Used

* **Language:** Verilog + SystemVerilog + UVM
* **Simulation Platform:** EDA Playground

## Features

* 256 × 8 Dual-Port SRAM design
* Independent read and write address ports
* Simultaneous read/write support
* Full UVM verification architecture
* Randomized read/write transaction generation
* Functional coverage collection
* Reference model based scoreboard checking

## SRAM Specifications

### Inputs

* `clk` → Clock
* `rst` → Reset
* `wr_en` → Write Enable
* `rd_en` → Read Enable
* `wr_addr [7:0]` → Write Address
* `rd_addr [7:0]` → Read Address
* `wr_data [7:0]` → Write Data

### Output

* `rd_data [7:0]` → Read Data

## Functional Behavior

* On reset, all memory locations are initialized to zero.
* If `wr_en = 1`, data is written into SRAM at `wr_addr`.
* If `rd_en = 1`, data is read from SRAM at `rd_addr`.
* Simultaneous read and write operations are supported when read and write addresses differ.

## UVM Verification Architecture

The UVM testbench includes:

* **Interface** → Connects DUT and verification environment
* **Sequence Item** → Defines SRAM transaction packet
* **Read Sequence** → Generates read transactions
* **Write Sequence** → Generates write transactions
* **Sequencer** → Controls transaction scheduling
* **Driver** → Drives transactions to DUT
* **Monitor** → Observes DUT activity and collects coverage
* **Agent** → Encapsulates driver, monitor, and sequencer
* **Scoreboard** → Compares DUT output with reference memory model
* **Environment** → Connects agent and scoreboard
* **Test** → Runs verification scenario

## Functional Coverage

Coverage is collected for:

* Read addresses
* Write addresses
* Read data values
* Write data values
* Cross coverage between read and write address regions

This ensures verification across multiple memory access patterns.

## Verification Flow

1. Read and write sequences generate randomized transactions
2. Sequencer sends transactions to driver
3. Driver applies transactions to SRAM
4. Monitor captures inputs and outputs
5. Scoreboard updates reference model and checks correctness
6. PASS/FAIL messages are displayed
7. Functional coverage report is generated

## Sample Output

```text id="sample"
TIME = 120 | WR_DATA = 10100110 | RD_DATA = 10100110 | RD_ADDR = 00110100 | WR_ADDR = 01001010 | RD_EN = 1 | WR_EN = 0 |
| TIME = 120 | READ PASS FOR : | RD_ADDR = 00110100 | RD_DATA = 10100110 | REF_DATA = 10100110 |
----------------------------------------------------------------------------------------
FUNCTIONAL COVERAGE = 96.48 %
```

## Learning Outcomes

This project demonstrates:

* Memory verification using UVM
* Read/write transaction modeling
* UVM driver-monitor communication
* Scoreboard reference model creation
* Functional coverage analysis
* Verification of memory-intensive RTL designs

└── README.md
```
