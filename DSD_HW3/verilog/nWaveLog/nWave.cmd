wvConvertFile -win $_nWave1 -o \
           "/home/raid7_2/userb04/b04044/DSDHW/DSD_HW3/verilog/SingleCycleRTL.vcd.fsdb" \
           "/home/raid7_2/userb04/b04044/DSDHW/DSD_HW3/verilog/SingleCycleRTL.vcd"
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/raid7_2/userb04/b04044/DSDHW/DSD_HW3/verilog/SingleCycleRTL.vcd.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/SingleCycle_tb"
wvAddAllSignals -win $_nWave1
wvFindSignal -win $_nWave1 -next "Jump"
wvFindSignal -win $_nWave1 -next "Jump"
wvFindSignal -win $_nWave1 -next "Jump"
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvFindSignal -win $_nWave1 -previous "Jump"
wvFindSignal -win $_nWave1 -previous "Jump"
wvFindSignal -win $_nWave1 -next "Jump"
wvFindSignal -win $_nWave1 -next "Jump"
wvExit
