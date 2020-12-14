(
var wavDir = PathName.new(Document.current.dir).parentPath +/+ "wav";
var includes = (
	helpers: ["misc", "gui"],
	generators: ["feedbacker", "drumkit"],
	effects: ["delay", "paul-stretch", "reverb", "split-comb", "tape-loop", "vinyl"]
);
includes.keys.do({ |dir|
	includes[dir].do({ |name|
		Require(dir ++ "/" ++ name ++ ".scd", always: true);
	});
});

s.waitForBoot({
	///
	/// INIT
	///
	s.options.memSize = 1000000;
	TempoClock.default.tempo_(0.5);


	///
	/// BUSSES
	///
	~busReverb = Bus.audio(s, 2);
	~busWetReverb = Bus.audio(s, 2);
	~busDelay  = Bus.audio(s, 2);
	~busFilter = Bus.audio(s, 2);


	///
	/// FILTERS
	///

	// Master - everything goes through ~filter
	~filter = Synth(\SplitComb, [\inBus, ~busFilter]);

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


	///
	/// INSTRUMENTS
	///
	~feed = Synth.before(~delay, \feedbacker, [\fx, ~busDelay,
		\rt, 0.2, \amp, 0.3, \dry, 0.3, \pan, 0
	]);
	~vinyl = Synth.before(~delay, \vinyl, [\fx, ~busDelay, \amp, 0.1, \dry, 0]);

	Pbind(
		\instrument, \kick,
		\dur, Pseq([Rest(5), 1, Rest(5)], inf),
		\freq, 70,
		\gliss, 0.9,
		\amp, 0.1,
		\dry, 0,
		\fx, ~busDelay
	).play;


	///
	/// GUI
	///
	~gh_mkWindow.("KNNN: `Piano Loops`");
	~gh_mkNum.(~feed, "Feedbacker", initVal: 0.3);
	~gh_mkNum.(~vinyl, "vinyl", initVal: 0.3);


	///
	/// Piano loops
	///
	~playOrder = Routine({ [100, 200].do({ |dur| dur.yield }) });
	~playList = Routine({ ["piano-1.wav", "piano-2.wav" ].do({ |f| f.yield }) });

	Task({
		var delta;
		var pan = -1;

		while {
			delta = ~playOrder.next;
			delta.notNil
		} {
			var paul, tape;
			var filename = wavDir +/+ ~playList.next;
			var basename = PathName(filename).fileNameWithoutExtension;
			var paulLevel = ~rr.(0.6, 0.8);
			var tapeLevel = ~rr.(0.15, 0.4);

			paul = ~paulstretch_loadAndPlay.(filename, fx: ~busReverb, dry: 0, stretch: 1500, amp: paulLevel, pan: 0.5 * pan);
			tape = ~tapeloop_loadAndPlay.(filename, startRate: pan * 0.5, fx: ~busReverb, amp: tapeLevel, dry: 0, startDist: 0.15, pan: 0.3 * pan);
			~gh_mkNum.(paul, "Stretch " ++ basename, initVal: paulLevel);
			~gh_mkNum.(tape, "Loop " ++ basename, initVal: tapeLevel);

			pan = pan * -1;
		}
	}).play;


	///
	/// Main loop
	///
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

			~feed.set(\midiBase, midiBase);
			~feed.set(\rt, rt);
			~feed.set(\pan, pan);

			~gh_log.("FEEDBACKER", "midiBase", midiBase, "rt", rt, "pan", pan);

			delta = ~rr.(5, 10);

			delta.yield;
		}
	}).play;
});
)
