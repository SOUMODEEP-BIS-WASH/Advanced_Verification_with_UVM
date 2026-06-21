# RCA with UVM-based Verification

## Overview
This project implements a **4-bit Ripple Carry Adder (RCA)** in Verilog and verifies it using a complete **UVM (Universal Verification Methodology) testbench**.

The verification environment follows standard UVM architecture with reusable components such as sequence item, sequencer, driver, monitor, agent, scoreboard, environment, and test. Randomized stimulus is generated and applied to validate adder functionality.

This project was developed and simulated using **EDA Playground**.

---

## Features
- 4-bit Ripple Carry Adder design
- Verilog RTL implementation
- UVM-based verification environment
- Randomized transaction generation
- Automated DUT checking using scoreboard
- Reusable verification components
- Functional correctness validation for sum and carry

---

## DUT Specifications

| Parameter | Value |
|-----------|-------|
| Adder Type | Ripple Carry Adder |
| Input Width | 4 bits |
| Inputs | A, B, Cin |
| Outputs | Sum, Cout |

---

## Inputs and Outputs

### Inputs
- `a[3:0]` → Operand A
- `b[3:0]` → Operand B
- `cin` → Carry input

### Outputs
- `sum[3:0]` → Sum output
- `cout` → Carry output

---

## Design Architecture
The 4-bit RCA is built using four cascaded Full Adders.

```text
FA0 → FA1 → FA2 → FA3
```

Each full adder computes:
- Sum bit
- Carry-out to next stage

---

# UVM Testbench Architecture

The verification environment follows standard UVM hierarchy:

```text
Test
 └── Environment
      ├── Agent
      │    ├── Sequencer
      │    ├── Driver
      │    └── Monitor
      └── Scoreboard
```

---

## UVM Components

### Interface
Connects DUT with UVM testbench.

Signals included:
- Inputs: a, b, cin
- Outputs: sum, cout

---

### Sequence Item (Transaction)
Defines transaction packet containing:
- Random inputs
- DUT outputs

```systemverilog
a, b, cin
sum, cout
```

---

### Sequence
Generates randomized transactions.

Responsibilities:
- Create transaction objects
- Randomize inputs
- Send transactions to sequencer

---

### Sequencer
Passes transactions from sequence to driver.

---

### Driver
Applies randomized inputs to DUT through virtual interface.

Responsibilities:
- Receive transactions
- Drive DUT inputs at clock edge

---

### Monitor
Observes DUT activity and collects:
- Inputs
- Outputs

Transfers observed transactions to scoreboard using analysis port.

---

### Agent
Contains:
- Sequencer
- Driver
- Monitor

Handles transaction flow.

---

### Scoreboard
Implements reference model for RCA.

Expected result:
```text
Expected = A + B + Cin
```

Compares:
- DUT output
- Expected output

Reports:
- PASS
- FAIL

---

### Environment
Top-level verification container connecting:
- Agent
- Scoreboard

---

### Test
Controls execution of UVM verification.

Responsibilities:
- Create environment
- Start sequences
- Raise/drop objections

---

## Verification Flow

1. Sequence generates random transaction
2. Sequencer forwards transaction
3. Driver applies stimulus to DUT
4. Monitor captures DUT response
5. Scoreboard computes expected result
6. Output comparison performed
7. PASS/FAIL reported

---

## Sample Output

```text
PASS FOR:
A = 0101
B = 0011
Cin = 1
SUM = 1001
Cout = 0
```

---

## Tools Used
- **EDA Playground**
- Verilog HDL
- SystemVerilog
- UVM

---

## Learning Outcomes
This project demonstrates:
- UVM testbench creation
- UVM component hierarchy
- Sequence-driven stimulus generation
- Driver-monitor communication
- Analysis port usage
- Scoreboard-based verification
- Functional verification of arithmetic circuits
