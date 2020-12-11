(
var d = { arg density = 8; Dust.ar(density); };
var r = { arg n, lim = 0.5; TRand.ar(n - lim, n + lim, d.value); };
var generator = { arg freqA = 100, freqB = 240, lpFreqA = 3000, lpFreqB = 3000, rescale = 15, room = 1.0, coef = 0.5, pan = 0;
	Pan2.ar(
		OnePole.ar(
			LPF.ar(
				LPF.ar(
					(FreeVerb.ar(
						(SinOsc.ar(r.value(freqA)) +
							SinOsc.ar(r.value(freqB))
						) * SinOsc.ar(
							GbmanL.ar(r.value(10000, 100), r.value(1.2, 0.1), r.value(2.1, 0.1))
						),
						room: room,
						damp: 0.3
					) * rescale.dbamp).tanh,
					r.value(lpFreqA)),
				r.value(lpFreqB)
			) * (-1 * rescale).dbamp,
			r.value(coef, 0.1)
		),
		r.value(pan, 0.05)
	);
};

SynthDef(\stockhaus, { arg outBus = 0, effectBus = 0, freq = 100, level = 0.5, direct = 0.5, pan = 0;
	var soundA, soundB, sound;
	soundA = generator.value(freqA: freq, freqB: freq * 2, pan: pan) * (level / 2);
	soundB = generator.value(freqA: freq, freqB: freq * 2, pan: pan) * (level / 2);
	sound = Pan2.ar(Limiter.ar(soundA + soundB, level, 0.05), pan);
	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;

SynthDef(\stockhausFilter, { arg outBus = 0, inBus = 0, freq = 100, dry = 0.0;
	var input = In.ar(inBus, 2);
	var wet = [
		MoogLadder.ar(input[0], generator.value(freqA: freq, freqB: freq * 2), 2),
		MoogLadder.ar(input[1], generator.value(freqA: freq * 0.9, freqB: freq * 2.1), 2)
	];
	var mix = (wet * (1 - dry)) + (input * dry);
	Out.ar(outBus, mix);
}).add;
)