# RISC-V Pipelined Processor with Forwarding and 2-Bit Branch Prediction

## Overview
This project extends a single-cycle RISC-V processor into a **5-stage pipelined architecture** with performance optimizations.

Multiple processor models were implemented progressively to study pipeline hazards and performance improvement techniques, culminating in a **two-bit dynamic branch predictor**.

---

## Pipeline Architecture
Five-stage pipeline:
- IF – Instruction Fetch
- ID – Instruction Decode
- EX – Execute
- MEM – Memory Access
- WB – Write Back

Pipeline registers enable concurrent execution of multiple instructions.

---

## Implemented Models

### Non-Forwarding Pipeline
- Hazard Detection Unit
- Stall and flush control
- RAW hazard handling using pipeline stalls

### Forwarding Pipeline
- Data forwarding (bypassing) network
- Reduced stalls
- Improved execution efficiency

### Two-Bit Dynamic Branch Prediction
- Saturating counter predictor
- FSM-based prediction logic
- Control hazard reduction
- Misprediction detection and pipeline flushing

---

## Key Features
- Hazard detection logic
- Forwarding unit
- Branch prediction FSM
- Pipeline control (stall / flush)
- Memory redesign for pipeline timing
- ISA functional verification

---

## Verification Environment
The processor was integrated as a **Device Under Test (DUT)** into an instructor-provided ISA verification framework.

Verification includes:
- Automated ISA tests
- Scoreboard-based checking
- Instruction flow validation
- Waveform debugging using SimVision

---

## Simulation Environment
Simulation was performed using **Cadence Xcelium** on a Linux server environment.

Simulation execution:
- `make` — run simulation
- `make gui` — open SimVision waveform viewer

---

## Tools & Technologies
- Verilog / SystemVerilog
- Cadence Xcelium
- Linux server environment
- RISC-V RV32I ISA

---

## Learning Outcomes
- Pipeline microarchitecture design
- Data and control hazard handling
- Forwarding network implementation
- Dynamic branch prediction
- Performance-oriented CPU design

---

## Status
✅ Non-forwarding, forwarding, and branch prediction models completed  
✅ ISA tests successfully executed  
📄 Reports and results includedupdate later...
