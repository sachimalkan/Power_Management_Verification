onbreak {resume}
if {[batch_mode]} {
    onerror {quit -f}
}

echo "#"
echo "# NOTE: Creating library and compiling design ..."
echo "#"
if [file exists work] {
    vdel -lib work -all
}
vlib work
vlog -work work -novopt -f ./Questa/scripts/compile_rtl.f

if {[batch_mode]} {
    quit -f
}
