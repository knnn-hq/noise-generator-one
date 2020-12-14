(
SynthDef(\fatsaw, { | outBus=0, effectBus=0, direct=0, level=1.0, pan=0, freq = 440, gate=1, attack=0.01, decay=0.3, sustain=0.5, release=1, filterSpeed=100, filterFreqStart=300, filterFreqEnd=400, resonance=1, hfFilterFreq=1, hfFilterResonance=1 |
	var sig, env, filtFreq;

	env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, levelScale:0.5, doneAction:Done.freeSelf);
	sig = env * Splay.ar(LFSaw.ar(freq*[0.98,0.99,1.0,1.01,1.02],[LFNoise0.kr(2), LFNoise0.kr(1.9), LFNoise0.kr(2.1)]) + SinOsc.ar(freq*[0.98,0.99,1.0,1.01,1.02],[LFNoise0.kr(2), LFNoise0.kr(1.9), LFNoise0.kr(2.1)]));
	filtFreq = LFSaw.kr(filterSpeed,iphase:1).range(filterFreqStart,filterFreqEnd);
	sig = RLPF.ar(sig, filtFreq, resonance);
	sig = RHPF.ar(sig, hfFilterFreq, hfFilterResonance);
	2.do({
		sig = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1);
	});

	sig = Pan2.ar(sig.tanh, pan, level);

	Out.ar(effectBus, sig * (1 - direct));
	Out.ar(outBus, sig * direct);
}).add;

SynthDef(\organ, { | outBus = 0, effectBus = 0, level = 0.1, direct = 0, pan = 0, freq = 440, gate=1, attack=0.01, decay=0.3, sustain=0.5, release=1 |
	var sig, env;
	sig = 0.5*Klang.ar(`[[freq/8, freq/4, freq/2, freq, freq*2, freq*4, freq*8],[0.7, 0.7, 0.7, 1, 1, 0.6, 0.4],[0,0.1,0.2,0.3,0.4,0.5,0.6]]);
	sig = RLPF.ar(sig, 5000, 1);
	env = EnvGen.ar(Env.adsr(attack,decay, sustain, release), gate, doneAction:Done.freeSelf);
	sig = env*sig;
	4.do({
		sig = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1);
	});

	sig = Pan2.ar(sig.tanh, pan, level);

	Out.ar(effectBus, sig * (1 - direct));
	Out.ar(outBus, sig * direct);
}).add;

)