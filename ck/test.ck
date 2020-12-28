// #include "chugens/ondes.ck"

Ondes ondes => Dyno d => Gain g => dac;
ondes.initVoices(6);
0.7 => ondes.gain;
0.8 => g.gain;

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
	choose(tones) $ int => ondes.noteOn;
    
	humanize(400) => now;

	if (Math.randomf() > downChance) {
		ondes.freq() / choose([1.5, 3.0]) => ondes.noteOn;
    	humanize(1200) => now;
	} 
	if (Math.randomf() > upChance) {
		ondes.freq() * choose([2.5, 3.0]) => ondes.noteOn;
    	humanize(600) => now;
		if (Math.randomf() > upChance - 0.02 && upChance > 0) {
			0.03 -=> upChance;
			0.001 +=> downChance;
		}
	}
	ondes.freq() * 1.5 => ondes.noteOn;
	
	humanize(600) => now;

}
