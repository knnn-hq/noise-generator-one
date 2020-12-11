(
SynthDef(\hihat, { arg outBus = 0, effectBus = 0, level = 0.5, direct = 0.5, attack = 0.01, release = 0.2, freq = 6000, pan = 0;
	var env, sound;
	env = Env.perc(attack, release, level).kr(doneAction: 2);

	sound = Pan2.ar(HPF.ar(in: WhiteNoise.ar, freq: freq, mul: env), pan);

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;

SynthDef(\snare, {arg outBus = 0, effectBus = 0, level = 0.1, direct = 0.5, sineFreq = 180, filterFreq = 2000, attack = 0.01, release = 0.2, pan = 0;
	var env, noise, tone, sound;
	env = Env.perc(attack, release, level).kr(doneAction: 2);
	noise = HPF.ar(
		in: WhiteNoise.ar,
		freq: filterFreq,
		mul: env
	);
	tone = SinOsc.ar(freq: sineFreq, mul: env);

	sound = Pan2.ar(noise + tone, pan);

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;

SynthDef(\kick, {arg outBus = 0, effectBus = 0, level = 0.3, direct = 0.5, freq = 60, gliss = 0.9, attack = 0.01, release = 0.45, pan = 0;
	var env, sound, ramp;
	env = Env.perc(attack, release, level).kr(doneAction: 2);
	ramp = XLine.kr(start: freq, end: freq * gliss, dur: release);
	sound = Pan2.ar(SinOsc.ar(freq: ramp, mul: env), pan);

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;
)
