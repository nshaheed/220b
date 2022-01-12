SinOsc s => ADSR d => NRev r => dac;
0.1 => r.mix; d.set( 10::ms, 8::ms, .3, 400::ms );
while(true) { d.keyOn(); 100::ms => now; d.keyOff(); 1::ms * Math.random2(50,500) => now;}