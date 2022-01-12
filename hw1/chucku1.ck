TriOsc s => PitShift p => p => PitShift p2 => p2 => NRev r => dac; 
p.shift(1.0003); s.freq(400); 
while(true) { 0.000000001 => p2.shift; 1::second=>now; }