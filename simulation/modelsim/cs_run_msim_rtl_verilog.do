transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/cpu.v}
vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/mips_os.v}
vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/memery.v}
vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/clkgen.v}
vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/vga_ctrl.v}
vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/cs.v}
vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem {D:/program/FPGA/DigitalCircuit-ComputerSystem/fsm.v}

vlog -vlog01compat -work work +incdir+D:/program/FPGA/DigitalCircuit-ComputerSystem/simulation/modelsim {D:/program/FPGA/DigitalCircuit-ComputerSystem/simulation/modelsim/cs.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  cs_vlg_tst

add wave *
view structure
view signals
run -all
