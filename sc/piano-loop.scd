(
s.waitForBoot({
	Require("helpers/**", always: true);
	Require("generators/**", always: true);
	Require("effects/**", always: true);
	TempoClock.default.tempo_(0.5);

	~busReverb = Bus.audio(s, 2);
	~busDelay  = Bus.audio(s, 2);

	~reverb = Synth.new(\Reverb, [\inBus, ~busReverb,
		\roomSize, 25,
		\dry, 1,
		\time, 12,
		\head, 0.6,
		\tail, 0.3,
		\damping, 0.3
	]);

	~delay = Synth.before(~reverb, \Greyish, [\inBus, ~busDelay, \outBus, ~busReverb,
		\damping, 0.3,
		\delayTime, 23,
		\diffusion, 0.9,
		\feedback, 0.9,
		\size, 0.9
	]);

	Pbind(
		\instrument, \hihat,
		\dur, 1/8,
		\attack, 0.01,
		\release, 0.1,
		\freq, 11000,
		\pan, 0,
		\level, 0.3
	).play;

	Pbind(
		\instrument, \snare,
		\dur, Pseq([Rest(2), 1/4, Rest(2/4)], inf),
		\attack, 0.01,
		\release, 0.1,
		\sineFreq, 180,
		\filterFreq, 2000,
		\level, 0.25,
		\effectBus, ~busDelay
	).play;

	Pbind(
		\instrument, \kick,
		\dur, Pseq([Rest(1), 1/2, Rest(2/3)], inf),
		\freq, 60,
		\gliss, 0.9,
		\level, 0.4,
		\effectBus, ~busReverb
	).play;

	Pbind(
		\instrument, \CrushedPiano,
		\dur, Pseq([Rest(1.5), 1/2, 1/4, 1/4, 1/2, Rest(2)], inf),
		\midinote, Pseq([0,   38,  43,  41, 38,        0], inf),
		\level, 0.1,
		\direct, 0.4,
		\pan, -0.5,
		\effectBus, ~busReverb
	).play;

	Pbind(
		\instrument, \CrushedPiano,
		\dur, Pseq([Rest(4), 1/4, 1/4, 1/4, Rest(1/4), 1/2, 1/4, 1, Rest(1)], inf),
		\midinote, Pseq([0,   86,  81, 77, 0,          74, 81,  74,      0], inf),
		\level, 0.1,
		\direct, 0.4,
		\pan, -1,
		\effectBus, ~busReverb
	).play;
	Pbind(
		\instrument, \Saw,
		\dur, Pseq([Rest(1), 1, 1/2, 1, Rest(1.5)], inf),
		\midinote, Pseq([0, 50, 53, 50,  0], inf),
		\attack, 0.2,
		\sustain, 2,
		\release, 1.0,
		\level, 0.1,
		\direct, 0.5,
		\pan, 0.5,
		\effectBus, ~busReverb
	).play;

	Pbind(
		\instrument, \Saw,
		\dur, Pseq([Rest(3), 1/2, 1/4, 1/2, 1/4, 2, Rest(3)], inf),
		\midinote, Pseq([0,   65,  69,  74, 76, 74,  0], inf),
		\release, 0.99,
		\sustain, 1.5,
		\level, 0.1,
		\direct, 0.5,
		\pan, 1,
		\effectBus, ~busReverb
	).play;
});
)
