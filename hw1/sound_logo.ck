// me.dir() + "/test_tone_rev.wav" => string filename;
// me.dir() + "/test_tone.wav" => string filename;
me.dir() + "/chapman_rev.wav" => string filename;

// This is the score. These arrays track the changes of the global variable that
// affect the file playback in playAudio. Those global variables are updated to 
// their corresponding values in these arrays in the advanceScore() function. 

[ 
    0.04,
    0.1,
    0.2,
    0.6,
    1
] @=> float chances[]; // How likely is it that playAudio is called?

[
    16::ms,
    37::ms,
    75::ms,
    75::ms,
    75::ms
] @=> dur rhythms[]; // The rhythm of the playAudio calls

// How much of the frequency is possible to be randomly generated? 
// This is a reverse percentile, i.e. a value of 0.1 means only the top 
// 10% of frequencies will be considered for the filter frequency.
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
] @=> float Qs[]; // The filter resonance

[
    5::second,
    6::second,
    7::second,
    7::second,
    12::second
] @=> dur rehMarks[]; // How long each section is

// The global variables to be updated
float chance;
dur rhythm;
float percentile;
float panRange;
float Q;

1 => int running;


// this is meant to be sporked to allow lots of layers
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

// sporked to have a clock and update variables as needed
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

// main loop
while(running) {
    // not every beat will play back the audio file
    if (Math.randomf() < chance) {
        // get the lowest frequency that the filter can be
        50 + (1.0 - percentile) * (4000 - 50) => float lowFreq;
        
        // give it that extra oomph
        spork~ playAudio(Math.random2f(lowFreq,4000));
    }
    rhythm => now;
}

// play the full, unfiltered audio file
SndBuf buf => dac;
filename => buf.read;
2 => buf.gain;

0 => buf.pos;
buf.length() => now; 