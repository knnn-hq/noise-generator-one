(
var wavDir = PathName.new(Document.current.dir).parentPath +/+ "wav";

s.waitForBoot({
	s.options.memSize = 10000;
	TempoClock.default.tempo_(1);

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

	~vinyl = Synth.before(~delay, \vinyl, [\effectBus, ~busDelay, \level, 0.05, \direct, 0]);


	~stock = Synth.before(~wetReverb, \stockhaus, [\effecBus, ~busWetReverb,
		\level, 0.1,
		\direct, 0,
		\freq, 70
	]);

	Pbind(
		\instrument, \kick,
		\dur, Pseq([Rest(5), 1, Rest(5)], inf),
		\freq, 40,
		\gliss, 0.9,
		\level, 0.3,
		\direct, 0,
		\effectBus, ~busDelay
	).play;


	~load_and_stretch.(wavDir +/+ "piano-1.wav", effectBus: ~busReverb, direct: 0, stretch: 200, level: 0.7);
	~load_and_play_loop.value(wavDir +/+ "piano-1.wav", startRate: 0.8, effectBus: ~busReverb, level: 0.4, direct: 0, startDist: 0.2, pan: -0.3);
	~load_and_play_loop.value(wavDir +/+ "piano-2.wav", startRate: -0.8, effectBus: ~busFilter, level: 0.4, direct: 0, startDist: 0.3, pan: 0.3);
});

s.freeAll;
)
