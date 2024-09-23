# The timing HAL of the Apple IIe

The Apple IIe HAL (Hard Array Logic) chip plays a crucial role in the functioning of this system. It generates several clock and other vital signals that drives almost every other component of the Apple IIe. This repository contains a VHDL implementation of the HAL's equations. It should be useful to anyone trying to create a new HAL using a CPLD or FPGA, as well as to those seeking to understand how this component works.

## Project State
![HAL](https://img.shields.io/badge/TIMING_HAL-Stable-green)<br/>
The code has been tested on an Apple IIe for all video modes, using an ALTERA MAX 7000S (EPM7128STC100-10). However, the testbenches still need to be fixed.

# Compiling and testing
## Prerequisites
A VHDL compiler such as GHDL is required. Additionally, a wave analyzer such as GTKWave can be used to view the test outputs.
## Compiling
VHDL files must first be analyzed. For example, to analyze a file named my_vhdl_component.vhdl, run the following command:
```bash
ghdl -a --workdir=work my_vhdl_component.vhdl
```
Then, the component must be elaborated. For example, if the file above contains a component named `MY_VHDL_COMPONENT`, this would elaborate the component:
```bash
ghdl -e --workdir=work MY_VHDL_COMPONENT
```
Finally, to run a testbench once it has been analysed and elaborated, run this command
```bash
ghdl -r --workdir=work MY_COMPONENT_TB  --vcd=debug.vcd
```
This will run the testbench `MY_COMPONENT_TB` and dump the generated signals in the file `debug.vcd`. To view the dump, run:
```bash
gtkwave debug.vcd
```
## Compiling all
Alternatively, all the sources can be analysed and elaborated with this command:
```bash
./make.sh
```
(You can ignore any warnings stating "... is neither an entity nor a configuration")

And all testbenches can be simulated with this command:
```bash
./testall.sh
```

## License

This repository is licensed under the Creative Commons Zero License. You are free to use, modify, distribute, and build upon the code in any way you see fit. The Creative Commons License grants you the freedom to adapt the code for personal, academic, commercial, or any other purposes without seeking explicit permission.
