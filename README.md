# APB-INTERFACED-SPI-MASTER-IP-CORE-DESIGN-AND-VERIFICATION
UVM based verification environment for an APB interfaced SPI MASTER IP Core, ensuring functional correctness and protocol compiliance.

---

## 📌 Project Overview

This repository features a comprehensive functional verification environment for an **SPI (Serial Peripheral Interface)** protocol driven by an **APB (Advanced Peripheral Bus)** interface. The testbench is architected using **SystemVerilog** and the **Universal Verification Methodology (UVM)** to rigorously validate data transfers, protocol compliance, and operational modes.

**Verification Highlights:**
* **Robust Testbench Architecture:** Integrates standard UVM components alongside **SystemVerilog Assertions (SVA)** to monitor real-time protocol behavior and catch signal timing violations.
* **Metric-Driven Signoff:** Employs detailed functional coverage models to measure verification completeness and ensure high-quality design validation.
* **Exhaustive Scenario Testing:** Systematically verifies **10 distinct test cases** covering critical operational states and protocol configurations:
  * **8 Configuration Scenarios:** Exhaustive permutations of SPI configuration parameters (**CPOL**, **CPHA**, and **MSBFE**).
  * **System Reset Scenario:** Validates core initialization and protocol behavior during and after asynchronous resets.
  * **Low Power Scenario:** Verifies data integrity and system stability during low-power state transitions.
---
 
## 🎯 Verification Goals & Objectives
* **End-to-End Verification:** Verify seamless data transfers and protocol translation between the APB host interface and the SPI serial domain.
* **Exhaustive Scenario Validation:** Verify 10 distinct operational scenarios, including all 8 permutations of SPI configurations (CPOL, CPHA, MSBFE), along with System Reset and Low Power states.
* **UVM Architecture:** Develop highly reusable Verification IP (VIP) components—including sequencers, drivers, and monitors—for robust stimulus generation and checking.
* **Data Integrity Checking:** Guarantee zero data corruption across protocol boundaries by dynamically comparing expected and observed transactions using a UVM scoreboard.
*  **PWDATA to MOSI Comparison:** Verifying that data written via the APB host interface (`PWDATA`) is correctly serialized and transmitted onto the SPI serial line (`MOSI`).
*  **MISO to PRDATA Comparison:** Verifying that data received serially via the SPI peripheral (`MISO`) is correctly packed and read back accurately through the APB read data bus (`PRDATA`).
* **Protocol Compliance:** Deploy SystemVerilog Assertions (SVA) to continuously monitor control signals and strictly validate APB/SPI protocol timing.
* **Metric-Driven Signoff:** Implement comprehensive functional coverage models to quantify the completeness of configuration, transition, and scenario testing.
---

## 🧩 RTL Design Architecture

The RTL is systematically organized into the following functional blocks to ensure a modular design and efficient synthesis:

### 1. APB Interface
Acts as the communication bridge with the host processor.
* Handles APB setup and access phases.
* Manages register read/write operations and address decoding.
* Provides direct access to internal Control and Status registers.

### 2. SPI Control FSM (Finite State Machine)
The core controller for all SPI operations.
* Initiates and manages the start and completion of SPI transactions.
* Controls Chip-Select (`SS_n`) and SPI Clock generation.
* Orchestrates the precise timing for serial data transmission and reception.

### 3. Shift Register
Responsible for data conversion between parallel and serial domains.
* Executes **parallel-to-serial** conversion for the `MOSI` output.
* Executes **serial-to-parallel** conversion for the `MISO` input.
* Dynamically supports **MSB-first** or **LSB-first** bit-shifting operations based on configuration.

### 4. Clock / Baud Generator
* Divides the main system clock to generate the required SPI Serial Clock (`SCLK`) based on the programmed divider value.
---

## 🧩 RTL Block Diagram

A compact hierarchical architecture of our APB-SPI Master with external input-output signals:

<img width="2400" height="1792" alt="Gemini_Generated_Image_ac27ibac27ibac27 (1)" src="https://github.com/user-attachments/assets/6d1a5e34-4dc1-4eaa-90cb-2566534acef6" />
---

# 🔌 Interfaces
---
## APB Interface

The APB interface is used to configure and control the SPI Master.

| Signal    | Description         |
| --------- | ------------------- |
| `PCLK`    | APB clock           |
| `PRESETn` | Active-low reset    |
| `PADDR`   | APB address         |
| `PSEL`    | Peripheral select   |
| `PENABLE` | APB enable          |
| `PWRITE`  | Read/write control  |
| `PWDATA`  | APB write data      |
| `PRDATA`  | APB read data       |
| `PREADY`  | Transfer completion |
| `PSLVERR` | APB error enable    |

---

## SPI Interface

| Signal | Description            |
| ------ | ---------------------- |
| `SCLK` | SPI clock              |
| `MOSI` | Master Out Slave In    |
| `MISO` | Master In Slave Out    |
| `CS_N` | Active-low chip select |

---

# ⚙️ SPI Features

The SPI Master supports:

* Full-duplex communication
* Configurable CPOL
* Configurable CPHA
* MSB-first / LSB-first data transfer
* Programmable SPI clock generation
* APB-controlled configuration
* Register-based data transfer
* Reset functionality
* Low-power functionality
---

# 🔄 SPI Configuration

The three main SPI configuration bits used for verification are:

| Parameter | Description      |
| --------- | ---------------- |
| `CPOL`    | Clock Polarity   |
| `CPHA`    | Clock Phase      |
| `LSBFE`   | LSB First Enable |

Each parameter has two possible values.

Therefore:

```text
CPOL × CPHA × LSBFE

2 × 2 × 2 = 8 combinations
```
The verification environment covers all **8 combinations**.
---

# 📊 SPI Configuration Modes

| CPOL | CPHA | LSBFE | Configuration     |
| ---: | ---: | ----: | ----------------- |
|    0 |    0 |     0 | Mode 0, MSB-first |
|    0 |    0 |     1 | Mode 0, LSB-first |
|    0 |    1 |     0 | Mode 1, MSB-first |
|    0 |    1 |     1 | Mode 1, LSB-first |
|    1 |    0 |     0 | Mode 2, MSB-first |
|    1 |    0 |     1 | Mode 2, LSB-first |
|    1 |    1 |     0 | Mode 3, MSB-first |
|    1 |    1 |     1 | Mode 3, LSB-first |

---


## 🏗️ UVM Testbench Architecture
---

```text
                         +----------------+
                         |    uvm_test    |
                         +-------+--------+
                                 |
                         +-------v--------+
                         |     uvm_env    |
                         +-------+--------+
                                 |
          +---------------------------------------------+
          |                                             |
          v                                             v
    +-----------+                                 +-----------+
    | APB Agent |                                 | SPI Agent |
    +-----------+                                 +-----------+
          |                      |                      |
     +----+----+                                   +----+----+
     |    |    |                                   |    |    |
   Seqr  Drv  Mon                                Seqr  Drv  Mon
     |    |    |                                   |    |    |
     +----+----+---------------+-------------------+----+----+
                                |
                         +------v-------+
                         |  Scoreboard  |
                         +------+-------+
                                |
                    +-----------+-----------+
                    |                       |
                    v                       v
             Functional Coverage       Assertions
```
---

# 🧩 UVM Components

## 1. APB Agent

The APB agent handles APB transactions between the testbench and DUT.

```text
APB Agent
│
├── APB Sequencer
├── APB Driver
└── APB Monitor
```
### APB Sequencer

Generates APB sequence items for:

* Register writes
* Register reads
* Configuration transactions
* Data transactions

### APB Driver

Converts APB sequence items into pin-level APB transactions.

### APB Monitor

Observes APB bus activity and publishes transactions through an analysis port.

---

# 2. SPI Agent

The SPI agent handles SPI-side transactions.

```text
SPI Agent
│
├── SPI Sequencer
├── SPI Driver
└── SPI Monitor
```

The SPI monitor observes:

* `SCLK`
* `MOSI`
* `MISO`
* `CS_N`

---

# 🔍 Scoreboard

The scoreboard receives transactions from the APB and SPI monitors.

```text
              APB Monitor
                   |
             analysis_port
                   |
                   v
             +-----------+
             |           |
             | Scoreboard|
             |           |
             +-----------+
                   ^
             analysis_port
                   |
              SPI Monitor
```

The scoreboard checks:

* Expected vs actual APB transactions
* Expected vs actual SPI data
* Transmitted data
* Received data
* Register-related behavior
* Transaction consistency

---

# 📈 Functional Coverage

Functional coverage is implemented using SystemVerilog covergroups.

Coverage points include:

* `CPOL`
* `CPHA`
* `LSBFE`
* SPI data
* APB read/write
* Reset
* Low-power mode
* SPI configuration combinations

### Cross Coverage

The important configuration cross is:

```text
CPOL × CPHA × LSBFE
```

This produces:

```text
2 × 2 × 2 = 8 combinations
```

All 8 combinations are targeted during verification.

---

# ✅ SystemVerilog Assertions

SystemVerilog Assertions are used to verify protocol and design-level behavior.

Assertions are used for checking:

* Reset behavior
* APB protocol behavior
* SPI clock behavior
* Chip-select behavior
* Data transfer sequencing
* Sampling conditions
* Transfer completion
* Low-power behavior
* Configuration-related conditions

Assertions provide an independent mechanism for detecting protocol and timing-related violations.

---

# 🧪 Verification Test Cases

The main verification tests are derived from the three configuration bits:

```text
CPOL
CPHA
LSBFE
```

Since each bit has two possible values:

```text
2 × 2 × 2 = 8 SPI configurations
```

In addition, **Reset** and **Low-Power** are separately verified.

Therefore, there are **10 major verification scenarios**.

---

## Test Case 1 — CPOL=1, CPHA=1, LSBFE=0

**Configuration:**

```text
CPOL  = 1
CPHA  = 1
LSBFE = 0
```

**Purpose:**

Verify SPI data transmission and reception with:

* SPI Mode 3
* MSB-first data transfer
* Normal SPI operation

---

## Test Case 2 — CPOL=1, CPHA=0, LSBFE=0

**Configuration:**

```text
CPOL  = 1
CPHA  = 0
LSBFE = 0
```

**Purpose:**

Verify:

* SPI Mode 2
* LSB-first data transfer
* Correct serial data ordering

---

## Test Case 3 — CPOL=0, CPHA=1, LSBFE=0

**Configuration:**

```text
CPOL  = 0
CPHA  = 1
LSBFE = 0
```

**Purpose:**

Verify:

* SPI Mode 0
* MSB-first transfer
* Correct clock phase and data sampling

---

## Test Case 4 — CPOL=0, CPHA=0, LSBFE=0

**Configuration:**

```text
CPOL  = 0
CPHA  = 0
LSBFE = 0
```

**Purpose:**

Verify:

* SPI Mode 0
* LSB-first transfer
* Correct clock phase
* Correct bit ordering

---

## Test Case 5 — CPOL=1, CPHA=1, LSBFE=1

**Configuration:**

```text
CPOL  = 1
CPHA  = 1
LSBFE = 1
```

**Purpose:**

Verify:

* SPI Mode 3
* MSB-first transfer
* Clock polarity behavior
* Correct data sampling

---

## Test Case 6 — CPOL=1, CPHA=0, LSBFE=1

**Configuration:**

```text
CPOL  = 1
CPHA  = 0
LSBFE = 1
```

**Purpose:**

Verify:

* SPI Mode 2
* LSB-first transfer
* Clock polarity
* Data ordering

---

## Test Case 7 — CPOL=0, CPHA=1, LSBFE=1

**Configuration:**

```text
CPOL  = 0
CPHA  = 1
LSBFE = 1
```

**Purpose:**

Verify:

* SPI Mode 1
* MSB-first transfer
* Clock phase
* Clock polarity

---

## Test Case 8 — CPOL=0, CPHA=0, LSBFE=1

**Configuration:**

```text
CPOL  = 0
CPHA  = 0
LSBFE = 1
```

**Purpose:**

Verify:

* SPI Mode 0
* LSB-first transfer
* Correct clock polarity
* Correct clock phase
* Correct serial bit ordering

---

# 🔄 Test Case 9 — Reset Test

The reset test verifies the behavior of the DUT when reset is asserted and released.

### Checks

* DUT enters the expected reset state
* Control registers are reset correctly
* Status registers return to reset values
* SPI outputs reach the expected reset state
* No invalid SPI transaction occurs during reset
* Normal operation resumes after reset release

---

# ⚡ Test Case 10 — Low-Power Test

The low-power test verifies the SPI peripheral's behavior during low-power operation.

### Checks

* DUT enters the expected low-power state
* SPI activity is appropriately controlled
* Outputs remain in the expected state
* Configuration/state is maintained or restored as specified
* Normal operation resumes after exiting low-power mode
---
# 📁 Repository Structure
```text
apb_spi_verification/
│
├── rtl/
│   ├── spi_top.v                    // Top level DUT
│   ├── apb_slave_interface.v
│   ├── spi_slave_control_select.v
│   ├── shift_register.v
│   ├── baud_rate_generator.v
│   ├── apb_interface.sv             // APB Interface
│   └── spi_intrface.sv              // SPI Interface
│
├── tb/
│   ├── top.sv                       // Top module
│   ├── env_config.sv                // Environment Configuration
│   ├── env.sv                       // UVM Environment
│   ├── scoreboard.sv                // UVM Scoreboard (Includes Functional Coverage)
│   │
│   ├── apb_agent_top/
│   │   ├── apb_agt_config.sv        // APB Agent Configuration
│   │   ├── apb_agent.sv             // APB Agent
│   │   ├── apb_xtn.sv
│   │   ├── apb_sequencer.sv
│   │   ├── apb_driver.sv
│   │   ├── apb_monitor.sv
│   │   └── apb_sequences.sv
│   │
│   ├── spi_agent/
│   │   ├── spi_agt_config.sv        // SPI Agent Configuration
│   │   ├── spi_agent.sv             // SPI Agent
│   │   ├── spi_xtn.sv
│   │   ├── spi_sequencer.sv
│   │   ├── spi_driver.sv
│   │   ├── spi_monitor.sv
│   │   └── spi_sequences.sv
│   │
│   ├── assertions/
│   │   └── spi_assertions.sv        // SVA (SystemVerilog Assertions)
│   │
│   ├── tests/
│   │   ├── test_pkg.sv              // Test Package (includes all cases)
│   │   └── test.sv                  // Base/Top UVM Test
│
├── docs/
│   └── apb_spi_uvm_architecture.png
│
├── sim/
│   └── Makefile                     // Contains 'run_test' and 'regression' commands
│
└── README.md
```
---

# 🛠️ Tools & Technologies

| Category              | Technology/Tools         |
| --------------------- | ------------------------ |
| RTL Design            | Verilog / SystemVerilog  |
| Verification          | SystemVerilog / UVM      |
| Bus Protocol(APB)     | AMBA APB                 |
| Serial Protocol       | SPI                      |
| Assertions            | SystemVerilog Assertions |
| Coverage              | Functional Coverage      |
| Simulation            | QuestaSim / VCS          |
| Waveform Debug        | QuestaSim / Verdi        |
| Version Control       | Git / GitHub             |

---

## ▶️ Simulation & Execution

The project features a robust `Makefile` in the `sim/` directory that fully automates compilation, execution, waveform dumping, and coverage reporting for both **QuestaSim** and **Synopsys VCS**.

### ⚙️ Selecting the Simulator
By default, the Makefile is configured for QuestaSim. To switch to VCS, either edit the `Makefile` (`SIMULATOR = VCS`) or pass it as an argument:
```bash
make <target> SIMULATOR=VCS/QuestaSim

cd sim

# Run individual test cases:
make run_test      # Executes base test (msb_cpol1_cpha1_test)
make run_test1     # Executes msb_cpol1_cpha0_test
make run_test2     # Executes msb_cpol0_cpha1_test
make run_test8     # Executes apb_reset_test
make run_test9     # Executes low_power_test

# Run full regression suite:
make regress       # Cleans, compiles, and runs all 10 tests in batch mode
```
---

# 🛠️ Technical Skills & Expertise

Gained hands-on proficiency and practical implementation experience across the following domains during this verification project:

### 📐 Design & Protocols
* **Protocol Standards:** AMBA APB Protocol, SPI Protocol (Modes 0–3, CPOL/CPHA configurations)
* **Digital Design Concepts:** FSM-Based Control Logic, Register-Based Peripheral Design, RTL Subsystem Integration

### 🧪 Verification Methodology & UVM
* **Core UVM Components:** Modular Agents (APB & SPI), Sequencers, Drivers, Monitors, Scoreboard, Test Environments
* **Stimulus & Checking:** Constrained-Random Verification, Dynamic Scoreboarding, End-to-End Data Integrity Checks

### 📊 Coverage & Quality Closure
* **Functional Coverage:** Scenario-based coverage models, Cross-Coverage mapping for configuration matrices
* **Assertions & Robustness:** SystemVerilog Assertions (SVA) for protocol timing checks, Asynchronous Reset Verification, Low-Power State Verification

### ⚙️ EDA Tools & Workflow
* **Simulation & Debugging:** QuestaSim, Synopsys VCS, Waveform Analysis (.wlf / .fsdb via Verdi/Questa GUI)
* **Automation & Version Control:** GNU Make (Unified Regression Automation), Git & GitHub Portfolio Deployment
---

# 👩‍💻 Author

## Mo. Aslam Chaudhary

**B.Tech – Electronics and Communication Engineering**  
**Focus:** VLSI Design & Design Verification  

### 🛠️ Technical Expertise

`Verilog` · `SystemVerilog` · `UVM` · `UVM RAL` · `APB Protocol` · `SPI Protocol` · `SystemVerilog Assertions (SVA)` · `Functional Coverage` . `Code Coverage` · `Constrained Randomization` · `UVM Scoreboard` · `RTL Verification` · `QuestaSim / VCS` · `Makefile Automation`

---

## 📝 Project Summary

This project delivers a complete, industry-standard UVM (Universal Verification Methodology) verification environment designed for an **APB-to-SPI Bridge**. The primary objective is to verify seamless protocol translation and full-duplex data transfer between an  APB interface and a serial SPI peripheral. 

The verification environment is architected using modular, reusable Verification IP (VIP) components—including custom APB and SPI Agents, Sequencers, Drivers, Monitors, and a self-checking UVM Scoreboard equipped with dynamic transaction comparison. To ensure exhaustive functional closure, the testbench validates **10 major operational scenarios**, covering all 8 standard SPI configuration modes (derived from permutations of `CPOL`, `CPHA`, and `LSBFE`), alongside rigorous Asynchronous Reset and Low-Power verification. 

Additionally, the environment integrates **SystemVerilog Assertions (SVA)** for real-time protocol compliance monitoring, and scenario-based functional cross-coverage models. Automation is achieved via a robust GNU Make-based regression suite supporting both **QuestaSim** and **Synopsys VCS**, culminating in metric-driven verification signoff.

---






