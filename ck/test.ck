// #include "chugens/wavet.ck"
WaveT.create_c64_E() @=> WaveT wav;
wav => Dyno d => Gain g => dac;
0.7 => wav.gain => g.gain;

d.limit();
0.98 => float downChance;
0.96 => float upChance;

[45, 48, 52, 43, 55, 57, 45] @=> int tones[];

fun dur humanize(float millis) {
	Std.rand2f(millis * 0.99, millis * 1.01) => float duration;
	return duration::ms;
}
fun float choose(int list[]) {
	return list[Std.rand2(0, list.size() -1)] $ float;
}
fun float choose(float list[]) {
	return list[Std.rand2(0, list.size() -1)];
}

while (true) {
	Std.mtof(choose(tones)) => wav.freq;
    
	humanize(400) => now;

	if (Math.randomf() > downChance) {
		wav.freq() / choose([1.5, 3.0]) => wav.freq;
    	humanize(1200) => now;
	} 
	if (Math.randomf() > upChance) {
		wav.freq() * choose([2.5, 3.0]) => wav.freq;
    	humanize(600) => now;
		if (Math.randomf() > upChance - 0.02 && upChance > 0) {
			0.03 -=> upChance;
			0.001 +=> downChance;
		}
	}
	wav.freq() * 1.5 => wav.freq;
	
	humanize(600) => now;

}
