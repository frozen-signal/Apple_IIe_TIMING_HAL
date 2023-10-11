# The timing HAL of the Apple IIe 

This is a VHDL implementation of the Apple IIe's timing HAL.

## In development
Note: This project is currently under development.<br/>
<br/>
![HAL](https://img.shields.io/badge/TIMING HAL-Unfinished-red)<br/>

# Compiling and testing
## Prerequisites
A VHDL compiler such as GHDL is required, and optionnaly a wave analyser such as GTKWave can be used to view the tests outputs.
## Compiling
VHDL files must first be analysed. For example for a file `my_vhdl_component.vhdl` run the command:
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
(You can ignore warnings saying "... is neither an entity nor a configuration")

And all testbenches can be simulated with this command:
```bash
./testall.sh
```

## License

This repository is licensed under the Creative Commons Zero License. You are free to use, modify, distribute, and build upon the code in any way you see fit. The Creative Commons License grants you the freedom to adapt the code for personal, academic, commercial, or any other purposes without seeking explicit permission.
