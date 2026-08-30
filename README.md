# FPGA Retro Arcade Console

A fully custom hardware and firmware implementation of a retro arcade game engine built from scratch. This project interfaces a Digilent Cmod A7 FPGA with a custom-designed printed circuit board (PCB) featuring a resistor-based VGA Digital-to-Analog Converter (DAC), isolated power delivery, and NES controller input logic.

![Hardware Assembly](media/soldered_board_photo.jpg) 

## System Architecture

This project bridges bare-metal hardware design with digital logic synthesis, entirely bypassing traditional microcontrollers in favor of hardware description logic.

### 1. Hardware Design (KiCad)
The motherboard is a custom 4-layer PCB designed to route high-speed digital signals and manage power delivery safely.
* **VGA DAC:** Engineered a discrete 0805 resistor network to convert 12-bit digital color signals (4 bits per channel for Red, Green, and Blue) into standard 0-0.7V analog VGA signals.
* **Power Isolation Network:** Designed a physical jumper block "drawbridge" system to safely isolate the 5V USB logic power running the FPGA from the external DC barrel jack powering the 3.3V peripheral voltage regulator.
* **NES Controller Port:** Routed standard 5-wire shift register interface (VCC, GND, Latch, Clock, Data) to communicate with an external gamepad.

### 2. Digital Logic & Firmware (Verilog / Vivado)
The entire game engine and display driver are synthesized in Verilog using Xilinx Vivado.
* **VGA Timing Controller:** Generates precise 31.5 kHz Horizontal Sync (H-Sync) and 60 Hz Vertical Sync (V-Sync) pulses to continuously drive a VGA monitor.
* **Controller State Machine:** A custom finite state machine (FSM) polls the NES controller at 60Hz, sending a latch pulse and generating a clock signal to shift out serial button data.
* **Game Engine:** Renders the player sprite, target, and laser projectiles directly to the screen by controlling pixel color values based on horizontal and vertical beam counters.

## Debugging & Hardware Troubleshooting

A significant portion of this project involved bridging the gap between digital simulation and physical realities:
* **Ground Loop Elimination:** Initial breadboard prototyping resulted in severe video artifacting and hardware crashes due to ground loops. Moving to a custom PCB with a dedicated copper ground plane completely stabilized the 31.5 kHz sync signals.
* **Software-Defined Trace Corrections:** During manufacturing, the physical PCB trace routes for H-Sync and V-Sync were swapped. Instead of cutting copper traces and soldering bodge wires, the error was instantly corrected by swapping the `PACKAGE_PIN` assignments in the Vivado `.xdc` constraints file, demonstrating the rapid iteration power of FPGAs.

## Pin Mapping Master Table

| Function | Signal Name | Cmod A7 Pin (Header) |
| :--- | :--- | :--- |
| **H-Sync** | `VGA_HS` | PIO48 |
| **V-Sync** | `VGA_VS` | PIO47 |
| **Red DAC** | `RED_3` - `RED_0` | PIO37, PIO36, PIO35, PIO34 |
| **Green DAC** | `GREEN_3` - `GREEN_0` | PIO33, PIO32, PIO31, PIO30 |
| **Blue DAC** | `BLUE_3` - `BLUE_0` | PIO29, PIO28, PIO27, PIO26 |
| **NES Clock** | `NES_CLK` | PIO23 |
| **NES Latch** | `NES_LATCH` | PIO22 |
| **NES Data** | `NES_DATA` | PIO21 |

## Media
![Gameplay](media/gameplay_video.gif) *Placeholder: Convert your video of the game running into a short GIF and place it here.*
