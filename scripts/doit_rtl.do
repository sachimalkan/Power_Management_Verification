onbreak {resume}
if {[batch_mode]} {
    onerror {quit -f}
}
echo "#"
echo "# NOTE: Starting simulator and running DEMO ..."
echo "#"
vsim work.interleaver_tester \
     +nowarnTSCALE \
    +nowarnTFMPC \
     -L mtiPA \
	 -l rtl.log \
     -wlf rtl.wlf \
     -assertdebug \
     +notimingchecks
	 
# run simulation
do ./Questa/scripts/sim.do