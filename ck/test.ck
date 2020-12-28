// #include "chugens/ondes.ck"

Ondes ondes => Dyno d => Gain g => dac;
ondes.initVoices(6);
0.7 => ondes.gain;
0.8 => g.gain;

d.limit();

[45, 48, 52, 43, 55, 57] @=> int tones[];
while (true) {
    tones[Std.rand2(0, tones.size()-1)] => ondes.noteOn;
	Std.rand2f(399,401)::ms => now;
	if (Math.randomf() > 0.97) {
		ondes.freq() / 3 => ondes.noteOn;
    	Std.rand2f(998,1001)::ms => now;
	} 
	ondes.freq() * 1.5 => ondes.noteOn;
	Std.rand2f(599,601)::ms => now;

}
