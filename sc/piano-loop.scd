(
var wavDir = PathName.new(Document.current.dir).parentPath +/+ "wav";

s.waitForBoot({
	s.options.memSize = 500000;
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
	// Subtle reverb
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
		\roomSize, 46,
		\dry, 0.15,
		\time, 30,
		\head, 0.3,
		\tail, 0.6,
		\damping, 0.1
	]);
	// Delay
	~delay = Synth.before(~wetReverb, \Greyish, [\inBus, ~busDelay, \outBus, ~busWetReverb,
		\damping, 0.2,
		\delayTime, 15,
		\diffusion, 0.95,
		\feedback, 0.95,
		\size, 0.3
	]);

	~feed = Synth.before(~delay, \feedbacker, [\effectBus, ~busDelay,
		\rt, 0.2, \level, 0.3, \direct, 0.3, \pan, 0
	]);
	~vinyl = Synth.before(~delay, \vinyl, [\effectBus, ~busDelay, \level, 0.1, \direct, 0]);

	~playOrder = Routine({ [100, 200].do({ |dur| dur.yield }) });
	~playList = Routine({ ["piano-1.wav", "piano-2.wav" ].do({ |f| f.yield }) });

	~window = Window.new.front;
	~window.view.decorator = FlowLayout(~window.view.bounds);
    ~window.view.background = Color.rand;

	~addController = { | synth, name, initVal = 1.0, prop = \level |
		Routine({
			~window.view.decorator.nextLine;
			EZNumber(~window,
				~window.view.bounds.width @ 20, name ++ " " ++ prop ++ " ",
				ControlSpec(0, 1, \lin, step: 0.05),
				{ |ez| synth.set(prop, ez.value) },
				initVal,
				labelWidth: ~window.view.bounds.width * 0.65,
				numberWidth: ~window.view.bounds.width * 0.35
			);
		}).play(AppClock);
	};

	Pbind(
		\instrument, \kick,
		\dur, Pseq([Rest(5), 1, Rest(5)], inf),
		\freq, 70,
		\gliss, 0.9,
		\level, 0.1,
		\direct, 0,
		\effectBus, ~busDelay
	).play;

	~addController.(~feed, "feedback", initVal: 1.0);
	~addController.(~vinyl, "vinyl", initVal: 0.3);


	Task({
		var delta;
		var pan = -1;

		while {
			delta = ~playOrder.next;
			delta.notNil
		} {
			var filename = wavDir +/+ ~playList.next;
			var basename = PathName(filename).fileNameWithoutExtension;
			var paul, tape;
			var paulLevel = ~rr.(0.6, 0.8);
			var tapeLevel = ~rr.(0.15, 0.4);

			paul = ~paulstretch_loadAndPlay.(filename, effectBus: ~busReverb, direct: 0, stretch: 1500, level: paulLevel, pan: 0.5 * pan);
			~addController.(paul, "Stretch " ++ basename, initVal: paulLevel);
			(~rr.(1, 2)).wait;
			tape = ~tapeloop_loadAndPlay.(filename, startRate: pan * 0.5, effectBus: ~busReverb, level: tapeLevel, direct: 0, startDist: 0.15, pan: 0.3 * pan);
			~addController.(tape, "Loop " ++ basename, initVal: tapeLevel);
			pan = pan * -1;
		}
	}).play;


	Task({
		var delta;
		var pan = 0;
		var panDirection = -1;
		var rt = 0.25;
		var midiBase = 40;

		loop {
			midiBase = [27, 36, 45, 50].choose;
			pan = pan + (0.1 * panDirection);
			rt = ~rr.(rt / 2, rt * 2);

			if (pan.abs >= 1, { panDirection = panDirection * -1});

			"FEEDBACKER -- pan: ".post; pan.post; ", rt: ".post; rt.post; ", midiBase: ".post; midiBase.postln;

			~feed.set(\midiBase, midiBase);
			~feed.set(\rt, rt);
			~feed.set(\pan, pan);

			delta = ~rr.(5, 10);

			delta.yield;
		}
	}).play;
});
)
