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


SynthDef(\electrokick, { arg outBus = 0, effectBus = 0, level = 1, direct = 0, pan = 0;
	var env0, env1, env1m, out;

	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	out = out + WhiteNoise.ar(1);
	out = LPF.ar(out, env1m*1.5, env0);
	out = out + SinOsc.ar(env1m, 0.5, env0);

	out = out * 1.2;
	out = (out.clip2(1)).dup * level;
	out = Pan2.ar(out, pan);

	Out.ar(effectBus, out * (1 - direct));
	Out.ar(outBus, out * direct);
}).add;

SynthDef(\electrosnare, { arg outBus = 0, effectBus = 0, level = 1.0, direct = 0, pan = 0;
	var env0, env1, env2, env1m, oscs, noise, out;

	env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
	env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
	env1m = env1.midicps;
	env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m*1.2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

	noise = WhiteNoise.ar(0.2);
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
	noise = noise * env2;

	out = oscs + noise;
	out = (out.clip2(1)).dup * level;
	out = Pan2.ar(out, pan);

	Out.ar(effectBus, out * (1 - direct));
	Out.ar(outBus, out * direct);
}).add;

SynthDef(\clap, { arg outBus = 0, effectBus = 0, level = 0.5, direct = 0, pan = 0;
	var env1, env2, out, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	out = noise1 + noise2;
	out = out * 2;
	out = out.softclip.dup * level;
	out = Pan2.ar(out, pan);

	Out.ar(effectBus, out * (1 - direct));
	Out.ar(outBus, out * direct);
}).add;

SynthDef(\electrohihat, { arg outBus = 0, effectBus = 0, level = 0.3, direct = 0, pan = 0;
	var env1, env2, out, oscs1, noise, n, n2;

	n = 5;
	thisThread.randSeed = 4;

	env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]));
	env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), doneAction:2);

	oscs1 = Mix.fill(n, {|i|
		SinOsc.ar(
			( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
			SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
			1/n
		)
	});

	oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
	n2 = 8;
	noise = WhiteNoise.ar;
	noise = Mix.fill(n2, { |i|
		var freq;
		freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
		CombN.ar(noise, 0.04, freq, 0.1)
	}) * (1/n) + noise;
	noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
	noise = BLowShelf.ar(noise, 3000, 0.5, -6);
	noise = BHiPass.ar(noise, 1000, 1.5, env2);
	out = noise + oscs1;
	out = out.softclip.dup * level;
	out = Pan2.ar(out, pan);

	Out.ar(effectBus, out * (1 - direct));
	Out.ar(outBus, out * direct);
}).add;

SynthDef(\acid, { arg outBus = 0, effectBus = 0, level = 1.0, direct = 0, gate = 1, freq = 440, amp = 8, pan = 0;
	var env1, env2, out, pitch;
	pitch = Lag.kr(freq.cpsmidi, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
	env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), gate, amp);
	env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
	out = LFSaw.ar(pitch.midicps, 2, -1);

	out = MoogLadder.ar(out, (pitch + env2/2).midicps+(LFNoise1.kr(0.2,1100,1500)),LFNoise1.kr(0.4,0.9).abs+0.3,3);
	out = LeakDC.ar((out * env1).tanh/2.7).dup * level;
	out = Pan2.ar(out, pan);

	Out.ar(effectBus, out * (1 - direct));
	Out.ar(outBus, out * direct);
}).add;


SynthDef(\acidAlt, { arg outBus = 0, effectBus = 0, level = 1.0, direct = 0, freq = 200, gate=1, amp = 3.5, pan = 0;
	var env1, env2, out, pitch;

	pitch = Lag.kr(freq.cpsmidi, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
	env1 = EnvGen.ar(Env.perc(0.001,0.7,4,-4), gate, amp);
	env2 = EnvGen.ar(Env.perc(0.001,0.3,600,-3), gate);
	out = LFPulse.ar(pitch.midicps, 0, 0.5);

	out = MoogLadder.ar(out, 100+pitch.midicps + env2,0.1);
	out = LeakDC.ar((out * env1).tanh).dup * level;
	out = Pan2.ar(out, pan);

	Out.ar(effectBus, out * (1 - direct));
	Out.ar(outBus, out * direct);
}).add;

)
