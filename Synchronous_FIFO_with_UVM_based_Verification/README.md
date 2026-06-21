# Synchronous FIFO with UVM-Based Verification

## Overview

This project implements and verifies a **Synchronous FIFO (First-In-First-Out)** buffer using **SystemVerilog and UVM (Universal Verification Methodology)**.

The DUT is a **64-depth, 8-bit FIFO memory** supporting synchronous read and write operations with **FULL** and **EMPTY** status flags.

Verification is performed using a complete **UVM testbench architecture**, including:

* Sequence Items
* Sequences
* Driver
* Monitor
* Agent
* Scoreboard
* Environment
* Functional Coverage

Simulation and verification were performed using **EDA Playground**.

---

## Design Specifications

### FIFO Parameters

* **FIFO Depth:** 64 entries
* **Data Width:** 8 bits
* **Clocking:** Synchronous
* **Reset:** Active High

### Inputs

| Signal | Width | Description       |
| ------ | ----- | ----------------- |
| clk    | 1     | System clock      |
| rst    | 1     | Active-high reset |
| wr_en  | 1     | Write enable      |
| rd_en  | 1     | Read enable       |
| Din    | 8     | Input data        |

### Outputs

| Signal | Width | Description     |
| ------ | ----- | --------------- |
| Dout   | 8     | Output data     |
| empty  | 1     | FIFO empty flag |
| full   | 1     | FIFO full flag  |

---

## DUT Behavior

### Write Operation

* When `wr_en = 1` and FIFO is not full:

  * Input data is written into FIFO.
  * Pointer increments.
  * FULL and EMPTY flags update accordingly.

### Read Operation

* When `rd_en = 1` and FIFO is not empty:

  * Oldest data is read from FIFO.
  * Remaining elements shift forward.
  * Pointer decrements.
  * FULL and EMPTY flags update accordingly.

### Reset Operation

* Clears FIFO memory.
* Resets pointer to zero.
* Clears FULL and EMPTY flags.

---

# UVM Testbench Architecture

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
```

---

## UVM Components

### Transaction (Sequence Item)

Stores:

* Write Data
* Read Data
* Read Enable
* Write Enable
* FULL Flag
* EMPTY Flag

Includes constrained random generation for input data.

---

### Sequences

Two dedicated sequences are used:

#### Write Sequence (`wr_seq`)

* Generates write transactions.
* Drives random input data to FIFO.

#### Read Sequence (`rd_seq`)

* Generates read transactions.
* Triggers FIFO read operation.

---

### Driver

Responsibilities:

* Receives transactions from sequencer.
* Drives DUT inputs through virtual interface.
* Handles reset sequence.

---

### Monitor

Responsibilities:

* Samples DUT inputs and outputs.
* Captures:

  * Din
  * Dout
  * wr_en
  * rd_en
  * FULL
  * EMPTY
* Sends observed transactions to scoreboard.

---

### Scoreboard

Implements a **reference FIFO model** using a queue.

Responsibilities:

* Mimics FIFO behavior.
* Compares DUT output with expected output.
* Validates:

  * Read Data
  * FULL Flag
  * EMPTY Flag

Reports:

* PASS
* FAIL

Example checks:

* Read data verification
* Empty flag verification
* Full flag verification

---

### Environment

Integrates:

* Agent
* Scoreboard

Handles interconnections between monitor and scoreboard.

---

### Test

Verification flow:

1. Fill FIFO with write operations.
2. Empty FIFO with read operations.
3. Validate DUT behavior using scoreboard.
4. Report functional coverage.

Test pattern:

* 33 write operations
* 33 read operations

---

# Functional Coverage

Coverage includes:

### Coverpoints

* Write Enable
* Input Data Distribution

### Bins

* Zero
* Low Range
* Mid Range
* High Range

### Cross Coverage

* Write Enable × Input Data

Example:

```systemverilog
covergroup cvg;
  C1: coverpoint intf.wr_en;
  C2: coverpoint intf.Din;
  cross C1, C2;
endgroup
```

---

# Verification Features

✔ UVM-based reusable verification environment
✔ Constrained-random stimulus generation
✔ Functional coverage collection
✔ Reference-model-based scoreboard checking
✔ Full/Empty flag validation
✔ Read/Write data integrity verification

---

# Tools Used

* **Language:** Verilog + SystemVerilog + UVM
* **Simulator:** EDA Playground

---

# Learning Outcomes

This project helped in understanding:

* FIFO design fundamentals
* UVM testbench development
* Sequence-driven verification
* Functional coverage collection
* Scoreboard-based checking
* Verification of status flags and data integrity

---

* Coverage-driven randomized stress testing
* Parameterized FIFO design support
