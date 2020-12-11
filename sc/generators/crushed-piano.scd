(
SynthDef.new(\CrushedPiano, { arg outBus = 0, effectBus,
	freq = 440, level = 1.0, release = 0.5, crushSampleRate = 20000, crushBits = 8, direct = 0.9;
	var env = Env.linen(0, 1, release * 2, level).kr(doneAction: Done.freeSelf);
	var piano = MdaPiano.ar(freq, gate: 1, release: release, sustain: 0, mul: level);
	var crushedPiano = Decimator.ar(piano, rate: crushSampleRate, bits: crushBits, mul: env);
	Out.ar(effectBus, crushedPiano * (1 - direct));
	Out.ar(outBus, crushedPiano * direct);
}).add;
)