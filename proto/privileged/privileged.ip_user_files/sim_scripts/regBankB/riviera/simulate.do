onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+regBankB -L dist_mem_gen_v8_0_13 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.regBankB xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {regBankB.udo}

run -all

endsim

quit -force
