(
var wavDir = PathName.new(Document.current.dir).parentPath +/+ "wav";

s.waitForBoot({
	s.options.memSize = 10000;
	TempoClock.default.tempo_(0.5);

	Require("helpers/**", always: true);
	Require("generators/**", always: true);
	Require("effects/**", always: true);

	~busReverb = Bus.audio(s, 2);
	~busWetReverb = Bus.audio(s, 2);
	~busDelay  = Bus.audio(s, 2);
	~busFilter = Bus.audio(s, 2);

	// Master - everything goes through ~filter
	~filter = Synth.new(\stockhausFilter, [\inBus, ~busFilter, \dry, 0.5, \freq, 90]);

	// Subtler reverb
	~reverb = Synth.before(~filter, \Reverb, [\inBus, ~busReverb, \outBus, ~busFilter,
		\roomSize, 14,
		\dry, 1,
		\time, 12,
		\head, 0.6,
		\tail, 0.3,
		\damping, 0.3
	]);
	// Big reverb
	~wetReverb = Synth.before(~filter, \Reverb, [\inBus, ~busWetReverb, \outBus, ~busFilter,
		\roomSize, 23,
		\dry, 0.9,
		\time, 30,
		\head, 0.3,
		\tail, 0.6,
		\damping, 0.1
	]);

	~delay = Synth.before(~wetReverb, \Greyish, [\inBus, ~busDelay, \outBus, ~busWetReverb,
		\damping, 0.2,
		\delayTime, 5,
		\diffusion, 0.95,
		\feedback, 0.95,
		\size, 0.3
	]);

	~stock = Synth.before(~wetReverb, \stockhaus, [\effecBus, ~busWetReverb,
		\level, 0.01,
		\direct, 0,
		\freq, 70
	]);

	Pbind(
		\instrument, \kick,
		\dur, Pseq([Rest(1), 1/2, Rest(5)], inf),
		\freq, 60,
		\gliss, 0.9,
		\level, 0.05,
		\direct, 0,
		\effectBus, ~busDelay
	).play;

	~load_and_play_loop.value(wavDir +/+ "piano-1.wav", effectBus: ~busReverb, level: 0.2, direct: 0);
	~load_and_play_loop.value(wavDir +/+ "piano-2.wav", effectBus: ~busFilter, level: 0.2, direct: 0);
});

s.freeAll;
)
