onbreak {resume}
if {[batch_mode]} {
    onerror {quit -f}
}

add wave -position insertpoint sim:/interleaver_tester/dut/*
 
# run simulation
run -all

# quit simulation
if {[batch_mode]} {
    quit -f
}
