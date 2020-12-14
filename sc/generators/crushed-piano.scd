(
SynthDef.new(\CrushedPiano, { arg out = 0, fx, freq = 440, amp = 1.0, rel = 0.5, crushSampleRate = 20000, crushBits = 8, dry = 0.9, pan = 0;
	var env = Env.linen(0, 1, rel * 2, amp).kr(doneAction: Done.freeSelf);
	var snd = MdaPiano.ar(freq, gate: 1, release: rel, sustain: 0, mul: amp);	

	snd = Decimator.ar(snd, rate: crushSampleRate, bits: crushBits, mul: env);

	~outWithSidechain.(snd, out, fx, amp, pan, dry);
}).add;
)