(
/*
 * KICKS
 */
SynthDef(\kickElectro, {
    arg out = 0, pan = 0, amp = 0.3, att = 0.005, rel = 0.3;

    var body, bodyFreq, bodyAmp, pop, popFreq, popAmp, click, clickAmp, snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = Env.new(
		    levels: [261, 120, 51],
		    times: [rel / 8.57, rel / 3.75],
		    curve: \exp
		).kr;

    bodyAmp = Env.linen(
		    attackTime: att,
		    sustainTime: rel / 3,
		    releaseTime: rel
	    ).kr;

    body = SinOsc.ar(freq: bodyFreq, mul: bodyAmp);

    // pop sweeps over the midrange
    popFreq = XLine.kr(start: 750, end: 261, dur: 0.02);

	popAmp = Env.linen(
		    attackTime: att / 5,
		    sustainTime: rel / 15,
		    releaseTime: rel / 30,
		    level: 0.15
	    ).kr;

    pop = SinOsc.ar(freq: popFreq, mul: popAmp);

    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = Env.perc(
		    attackTime: att / 5,
		    releaseTime: rel / 300,
		    level: 0.15
	    ).kr;

    click = LPF.ar(
	    	in: Formant.ar(fundfreq: 910, formfreq: 4760, bwfreq: 2110),
	    	freq: 3140,
	    	mul: clickAmp
	    );

	//Putting it all together:
	snd = Mix.ar([body, pop, click]);
    snd = snd.tanh * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

    Out.ar(out, Pan2.ar(snd, pan, amp));
},
metadata: (
	credit: "By Nathan Ho aka Snappizz",
	category: \drums,
	tags: [\percussive, \bass, \kick, \electronic]
	)
).add;

SynthDef("kick808", {arg out = 0, freq1 = 240, freq2 = 60, amp = 1, ringTime = 10, att = 0.001, rel = 1, dist = 0.5, pan = 0;
	var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	Out.ar(0, Pan2.ar(snd, pan));
},
metadata: (
	credit: "unknown",
	category: \drums,
	tags: [\percussion, \kick, \808]
)
).add;


/*
 * SNARES
 */

SynthDef("snare909", {
	arg
	//Standard Values
	out = 0, pan = 0, freq = 185, amp = 1, att = 0.0005, curve = -2,
	//Other Controls
	toneRel = 0.075, toneAmp = 0.25, noiseRel = 0.4, noiseAmp = 0.2,
	nyquist = 500, lpFreq = 7040, hpFreq = 523;

	var relTimes, env, tone, noise, snd;

	relTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env.perc(attackTime: att, releaseTime: relTimes, level: amp, curve: curve).kr;

	tone = LFTri.ar(freq: [1, 1.78] * freq, mul: toneAmp);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(in: noise, freq: lpFreq, mul: noiseAmp);

	snd = tone ++ [noise, HPF.ar(in: noise, freq: hpFreq)];

	snd = Mix.ar(snd * env);

	DetectSilence.ar(in: snd, doneAction: 2);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Author Unknown",
	category: \drums,
	tags: [\unpitched, \snare, \synth, \909]
	)
).add;


SynthDef("snareElectro", {
    arg
	//Standard Values
	out = 0, pan = 0, amp = 0.4, att = 0.001, rel = 0.15, curve = -4,
	//Other Controls, blend ranges from 0 to 1
	popfreq = 160, sweep = 0.01, noisefreq = 810, rq = 1.6, blend = 0.41;

    var pop, popEnv, popSweep, noise, noiseEnv, snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popSweep = Env.new(levels: [20.4, 2.6, 1] * popfreq, times: [sweep / 2, sweep], curve: \exp).ar;

    popEnv = Env.perc(attackTime: att, releaseTime: 0.73 * rel, level: blend, curve: curve).kr;

	pop = SinOsc.ar(freq: popSweep, mul: popEnv);

    // bandpass-filtered white noise
    noiseEnv = Env.perc(attackTime: att, releaseTime: rel, level: 1 - blend, curve: curve).kr(doneAction: 2);

	noise = BPF.ar(in: WhiteNoise.ar, freq: noisefreq, rq: rq, mul: noiseEnv);

    snd = Mix.ar(pop + noise) * amp;

    Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Nathan Ho aka Snappizz",
	category: \organ,
	tags: [\pitched]
	)
).add;


/*
 * MISC
 */
SynthDef("clapElectro", {
    arg
	//Standard Arguments
	out = 0, amp = 0.5, pan = 0, att = 0.02, rel = 0.2, curve = -4,
	//Other Controls: mix is 0 - 1, fadeTime is a fraction of noise1's length.
	mix = 0.6, fadeFreq = 4000, fadeTime = 0.52;

    var env1, env2, snd, noise1, noise2;

    // noise 1: four short repeats
    env1 = Env.new(
            levels: [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            times: [att / 20, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            curve: [0, curve, 0, curve, 0, curve, 0, curve]
        ).kr;

    noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(in: noise1, freq: 600);
    noise1 = LPF.ar(
		    in: noise1,
		    freq: XLine.kr(start: 7200, end: fadeFreq, dur: fadeTime * 0.058)
	    );
    noise1 = BPF.ar(in: noise1, freq: 1620, rq: 3);

    // noise 2: one longer single burst
	env2 = Env.perc(attackTime: att, releaseTime: rel, curve: [0, curve]).kr;

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(in: noise2, freq: 1000);
    noise2 = LPF.ar(in: noise2, freq: 7600);
    noise2 = BPF.ar(in: noise2, freq: 1230, rq: 0.7);

	//Mixing
	snd = Mix.ar((mix * noise1) + ((1 - mix) * noise2));
	snd = (snd * 2).softclip;
	snd = snd * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

    Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Nathan Ho aka Snappizz, http://sccode.org/1-523",
	category: \drums,
	tags: [\unpitched, \clap, \electronic, \percussion]
	)
).add;


SynthDef(\cymbal808, {
	arg
	//Standard Values:
	out = 0, pan = 0, att = 0.002, dec = 0.25, rel = 0.05, amp = 0.1,
	//Other Controls:
	freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5;

	var snda, sndb, snd, env, pulseEnv, freqs;

	freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	env = Env.new(
		levels: [0, 1, decLevel, 0],
		times: [att, dec, rel],
		curve: [0, -0.5, 0]
	).kr;

	pulseEnv = Env.new(
		levels: [1.0, 0.6],
		times: dec,
		curve: -0.5
	).kr;

	snd = Mix.ar(LFPulse.ar(freq: freqs * 4.09));

	snd = (BinaryOpUGen('==', snd, 6.0) * 0.6) + (BinaryOpUGen('==', snd, 2.0) * 0.2) + (BinaryOpUGen('==', snd, 1.0) * 0.9);

	snd = (snd * pulseEnv) + Mix.ar(LFPulse.ar(freq: freqs, width: 0.55, mul: 0.9));

	snd = RLPF.ar(in: snd, freq: 7000, rq: 0.6);
 	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 1200, rq: 1.5);

	snd = snd + FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp);
	snd = Mix.ar(snd);
	snd = snd * env * amp;

	DetectSilence.ar(in: snd, doneAction: 2);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Published on sc-users 2007-08-25 by Ryan Brown",
	category: \drums,
	tags: [\808, \hihat, \percussion, \cymbal, \unpitched]
	)
).add;


SynthDef("hihatElectro", {
    arg out = 0, pan = 0, amp = 0.3, att = 0.001, rel = 0.3, curve = -8, filterFreq = 4010, rq = 0.56;

    var env, snd;

    // noise -> resonance -> exponential dec envelope
    env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr(doneAction: 2);

	snd = ClipNoise.ar(amp);
	snd = BPF.ar(
		in: snd,
		freq: [1, 1.035] * filterFreq,
		rq: [0.27, 1] * rq,
		mul: [1.0, 0.6]
	);
	snd = Mix(snd) * env;

    Out.ar(out, Pan2.ar(snd, pan));

	},
metadata: (
	credit: "By Nathan Ho aka Snappizz",
	category: \drums,
	tags: [\clap, \percussion, \hihat]
	)
).add;
)