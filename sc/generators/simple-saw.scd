(
SynthDef(\Saw, { arg outBus = 0, effectBus = 0,  level = 0.5, direct = 0.5, freq = 440, iphase = -0.5, attack = 0.05, sustain = 1.0, release = 0.8, pan = 0;
	var env, soundA, soundB, sound;

	env = Env.linen(attack, sustain, release).kr(doneAction: Done.freeSelf);
	soundA = SawDPW.ar(freq, iphase, mul: env) * (level / 2);
	soundB = SawDPW.ar(freq * 0.99, -1 * iphase, mul: env) * (level / 2);
	sound = Pan2.ar(Limiter.ar(soundA + soundB, level), pan);

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;
)