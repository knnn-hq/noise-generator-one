// #include "chugens/cellblock.ck"
// #include "chugens/spectrum.ck"
// #include "chugens/aging-tape.ck"

SinOsc s1 => Mix2 mx => SpectrumOfFiniteScale sp => AgingTape at => Dyno d => Gain g => dac;
SinOsc s2 => mx;

0.5 => s1.gain;
0.3 => s2.gain;
220 => s1.freq => s2.freq;
0.5 => s2.phase;
1.0 => sp.mix;
//1.0 => cb.mix => sp.mix;

// -0.5 => sp.pitchShift;
// 0.9 => sp.wet;
// 100::ms => sp.stutter;

0.8 => g.gain;

d.limit();

[220.0, 261.6256, 329.6276] @=> float tones[];

while (true) {
    tones[Std.rand2(0, tones.size()-1)] => s1.freq;
    s1.freq() * 3 + Std.rand2f(0.5, 5.0) => s2.freq;
    if (s1.freq() >= 880) {
        220 => s1.freq;
    }
    1000::ms => now;
}