onbreak {resume}
if {[batch_mode]} {
    onerror {quit -f}
}

echo "#"
echo "# NOTE: Analyzing UPF and extracting PA netlist ..."
echo "#"
vopt -work work \
     rtl_top \
     -pa_upf ./UPF/rtl_top.upf \
     -pa_genrpt=u+v \
     -pa_checks=i+r+p+cp+s+uml \
	 -o discard_opt

if {[batch_mode]} {
    quit -f
}