 #! /bin/bash

module=""

function set_module() {
	read -p "set module:" module
}

function check_abort(){
	read -p "abort?:" a
	if [[ $a = "y" ]]; then
		return 1
	else
		return 0
	fi	
}

function build_flash(){
	mkdir -p ./build/
	echo "yosys -p read_verilog $module.v; synth_gowin -json ./build/$module.json"
	yosys -p "read_verilog $module.v; synth_gowin -json ./build/$module.json"	
	echo **DONE**
	echo ""

	check_abort
	[[ "$?" -eq 1 ]] && return
	
	echo "nextpnr-himbaechel --json ./build/$module.json --write ./build/$module.pnr.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst"
	nextpnr-himbaechel --json ./build/$module.json --write ./build/$module.pnr.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst
	echo **DONE**
	echo ""

	check_abort
	[[ "$?" -eq 1 ]] && return
		
	echo "gowin_pack -d GW1N-9C -o ./build/$module.pack.fs ./build/$module.pnr.json"
	gowin_pack -d GW1N-9C -o ./build/$module.pack.fs ./build/$module.pnr.json
	echo **DONE**
	echo ""

	check_abort
	[[ "$?" -eq 1 ]] && return

	echo "openFPGALoader -b tangnano9k ./build/$module.pack.fs"
	openFPGALoader -b tangnano9k ./build/$module.pack.fs

	echo "build_flash complete"
	echo ""
}

function help(){
	echo "iv - run iverilog"
	echo "vvp - run vvp (dump variables for gtkwave"
	echo "gw - run gtkwave" 
	echo "bf - build flash, build module and flash to FPGA"
	echo "mod - set module name"
	echo "exit"
}

set_module

while true; do
	read -p "verilog tool - module:$module >" userIn

	if [[ $userIn = "exit" ]]; then
		break
	elif [[ $userIn = "iv" ]]; then
		mkdir -p ./sim/
		inputFile="$module.v"
		echo "iverilog -o ./sim/$module  $inputFile"
		iverilog -o ./sim/$module  $inputFile
		echo "done"
		echo ""
	elif [[ $userIn = "vvp" ]]; then
		mkdir -p ./sim/
		echo "vvp ./sim/$module"
		vvp ./sim/tb_counter
		echo "done"
		echo ""
	elif [[ $userIn = "gw" ]]; then
		echo "gw ./sim/$module.vcd"
		gtkwave "./sim/$module.vcd" &
		echo "done"
		echo ""
	elif [[ $userIn = "bf" ]]; then
		build_flash
	elif [[ $userIn = "mod" ]]; then
		set_module
	elif [[ $userIn = "help" ]]; then
		help
	elif [[ $userIn = "" ]]; then
		: #Do nothing
	else
		echo "unknown command $userIn"
	fi
done
