// me.dir() + "/test_tone_rev.wav" => string filename;
// me.dir() + "/test_tone.wav" => string filename;
me.dir() + "/chapman_rev.wav" => string filename;


[ 
    0.04,
    0.1,
    0.2,
    0.6,
    1
] @=> float chances[];

[
    16::ms,
    37::ms,
    75::ms,
    75::ms,
    75::ms
] @=> dur rhythms[];

[
    5::second,
    6::second,
    7::second,
    7::second,
    12::second
] @=> dur rehMarks[];

[
    0.1,
    0.25,
    0.4,
    0.5,
    0.75
] @=> float freqPercentile[];

[
    100.,
    80.,
    60.,
    40.,
    15.
] @=> float Qs[];

float chance;
dur rhythm;
float percentile;
float panRange;
float Q;

1 => int running;


fun void playAudio(float freq) {
    SndBuf buf => ResonZ r => Pan2 p => dac;
    filename => buf.read;
    
    Math.random2f(-1. * panRange, panRange) => p.pan;
    freq => r.freq;
    Q => r.Q;
    4 => r.gain;

    0 => buf.pos;
    buf.length() => now;  
}


fun void advanceScore() {
    // 0 => int idx;
    
    for (0 => int i; i < chances.cap(); i++) {
        chances[i] => chance;
        rhythms[i] => rhythm;
        freqPercentile[i] => percentile;
        Qs[i] => Q;
        (1.0 * i) / chances.cap() => panRange;
                
        <<< chance, rhythm >>>;
        rehMarks[i] => now;
    }
    
    0 => running;
}

spork~ advanceScore();


while(running) {
    if (Math.randomf() < chance) {
        50 + (1.0 - percentile) * (4000 - 50) => float lowFreq;
        
        // give it that extra oomph
        /*
        if (chance > 0.99) {
            spork~ playAudio(Math.random2f(lowFreq,500));
        }
        */
        spork~ playAudio(Math.random2f(lowFreq,4000));
    }
    rhythm => now;
}

SndBuf buf => dac;
filename => buf.read;
2 => buf.gain;

0 => buf.pos;
buf.length() => now; 