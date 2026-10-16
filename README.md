# UART-Transmitter-and-Receiver

A simple UART (8N1) transmitter and receiver written in Verilog, verified with a self-checking loopback testbench. Built as a hands-on digital design project to practice FSM-based RTL and simulation-based verification.

## Features
- 8 data bits, no parity, 1 stop bit (8N1), LSB first
- Configurable baud rate through the `CLKS_PER_BIT` parameter
- FSM-based TX and RX (IDLE → START → DATA → STOP)
- RX uses a 2-flop input synchronizer and samples at the middle of each bit
- Self-checking testbench: TX is looped into RX and every byte is compared automatically

## Project structure
```
uart-verilog/
├── src/
│   ├── uart_tx.v      # transmitter
│   └── uart_rx.v      # receiver
├── tb/
│   └── tb_uart.v      # self-checking loopback testbench
├── docs/
│   ├── waveform.png           # TX/RX simulation waveform
│   └── waveform_internal.png  # internal FSM signals
├── .gitignore
└── README.md
```

## How it works
- `CLKS_PER_BIT = clock frequency / baud rate`. Example: 50 MHz / 115200 is about 434 (the default). The testbench overrides it with a small value so simulation is fast.
- **TX:** loads a byte on `start`, drives the start bit (0), 8 data bits, then the stop bit (1), holding each for `CLKS_PER_BIT` clocks. `busy` is high during transmission.
- **RX:** detects the falling edge of the start bit, waits half a bit period to confirm it, then samples every bit at its center. `valid` pulses for one clock when a full byte has been received.

## Interface
| Module | Ports |
|---|---|
| `uart_tx` | `clk, rst, start, data[7:0]` → `tx, busy` |
| `uart_rx` | `clk, rst, rx` → `data[7:0], valid` |

## Run the simulation
Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) and optionally GTKWave.

```bash
iverilog -g2012 -o sim src/uart_tx.v src/uart_rx.v tb/tb_uart.v
vvp sim
gtkwave uart.vcd
```

You can also run it online with [EDA Playground](https://edaplayground.com): Icarus Verilog as the simulator, source files in the design pane, testbench in the testbench pane.

## Results
The testbench sends `A5, 3C, 00, FF, 55` and checks each received byte.

```
PASS: sent a5 got a5
PASS: sent 3c got 3c
PASS: sent 00 got 00
PASS: sent ff got ff
PASS: sent 55 got 55
ALL TESTS PASSED
```

![Waveform](docs/waveform.png)
![Internal signals](docs/waveform_internal.png)

Note: `dout` fills in bit by bit (LSB first) while a byte is being received. It is only valid when `valid` pulses.

## Possible improvements
- Parity bit and framing-error detection
- FIFO buffer on the TX side
- More directed tests (back-to-back bytes, corrupted stop bit)
- FPGA implementation

## Author
Gouri - [GitHub](https://github.com/Gouri1803) · [LinkedIn](https://www.linkedin.com/in/bodhangouri)
