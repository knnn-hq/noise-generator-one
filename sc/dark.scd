(
var includes = (
	helpers: ["crossbeat"],
	generators: ["prophet", "electro-kit"],
	effects: ["reverb"]
);
includes.keys.do({ |dir|
	includes[dir].do({ |name|
		Require(dir ++ "/" ++ name ++ ".scd", always: true);
	});
});

s.waitForBoot({
	var tempo = TempoClock.default;
	var beats = [12, 6, 3, 2];
	var hh1, hh2, kk1, kk2, pr1, pr2;
	var lcm = ~lcmarr.(beats);
	var lcmbeat = lcm / 2; // one beat in bar is 1/4, one beat in beats is 1/8

	tempo.tempo_(0.5);
	tempo.schedAbs(tempo.nextBar, {tempo.beatsPerBar_(lcm)});

	~busReverb = Bus.audio(s, 2);
	~reverb = Synth(\Reverb, [\in, ~busReverb,
		\roomSize, 15,
		\dry, 0.9,
		\time, 15,
		\head, 0.4,
		\tail, 0.3,
		\damping, 0.7
	]);

	hh1 = Pbind(
		\instrument, \cymbal808,
		\dur, lcmbeat / 12,
		\pan, -0.25,
		\amp, Pseq([5, 4, 3, 2, 1] * 0.025, inf),
		\reverb, 0,
		\dec, 0.1,
		\decLevel, 0.1,
		\size, 0.1,
		\out, ~busReverb
	).play;

	hh2 = Pbind(
		\instrument, \cymbal808,
		\dur, lcmbeat / 6,
		\pan, 0.25,
		\amp, Pseq([1, 2, 3, 4, 5, 6, 7, 8] * 0.025, inf),
		\dec, 0.1,
		\out, ~busReverb
	).play;

	kk1 = Pbind(
		\instrument, \kick808,
		\dur, lcmbeat / 3,
		\pan, -0.2,
		\amp, Prand([0.8, 0.77, 0.82], inf),
		\freq1, Pfunc({ rrand(90, 100) }),
		\freq2, Pfunc({ rrand(40, 45) }),
		\out, ~busReverb
	).play;

	kk2 = Pbind(
		\instrument, \kick808,
		\dur, lcmbeat / 8,
		\pan, 0.2,
		\amp, Prand([0.8, 0.77, 0.82], inf),
		\freq1, 80,
		\freq2, 30,
		\fx, ~busReverb
	).play;

	pr1 = Pbind(
		\instrument, \prophet,
		\amp, 0.05,
		\att, 2.5,
		\rel, 0.5,
		\sus, 0.9,
		\dec, 0.1,
		\pan, 0.4,
		\midinote, Pseq(#[rest, 45], inf),
		\dur, lcmbeat / 1.5,
		\fx, ~busReverb
	).play;

	pr1 = Pbind(
		\instrument, \prophet,
		\amp, 0.05,
		\att, 1.5,
		\rel, 0.5,
		\sus, 0.9,
		\dec, 0.1,
		\pan, -0.4,
		\midinote, Pseq(#[rest, rest, rest, 57, 64, 57, 57], inf),
		\dur, lcmbeat / 6,
		\fx, ~busReverb
	).play;


	Task({
		var tempoValue = tempo.tempo;
		var ratio = 0.95;
		var delta;

		loop {
			if (tempoValue <= 0.25) {
				ratio = 1.05;
			} {
				if (tempoValue >= 0.7) {
					ratio = 0.95;
				}
			};

			tempoValue = tempoValue * (ratio + rrand(-0.025, 0.025));
			tempo.tempo_(tempoValue);
			delta = tempo.beatDur * (2..lcm).choose;
			
			delta.yield;
		};
	}).play;
});
)