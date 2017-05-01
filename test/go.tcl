vcom -work work {*.vhd}
vcom -work work {../src/util.vhd}
vcom -work work {../src/*.vhd}
restart -force
run 10us
