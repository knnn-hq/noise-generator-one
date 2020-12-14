(
var includes = (
	helpers: ["crossbeat"],
	generators: ["drumkit", "synths"],
	effects: ["reverb", "master", "delay"]
//	effects: ["delay", "paul-stretch", "reverb", "split-comb", "tape-loop", "vinyl"]
);
includes.keys.do({ |dir|
	includes[dir].do({ |name|
		Require(dir ++ "/" ++ name ++ ".scd", always: true);
	});
});

s.waitForBoot({
	var hhbeatA, hhbeatB, snbeat, kbeat, sawbeat, orgbeat;
	#orgbeat, sawbeat, hhbeatA, hhbeatB, snbeat, kbeat = ~crossbeat.(beats: [3, 2, 6, 9, 3, 2], basenote: 8, rest: false);

	TempoClock.default.tempo_(1);

	~busMaster = Bus.audio(s, 2);
	~busReverb = Bus.audio(s, 2);
	~busDelay = Bus.audio(s, 2);

	~master = Synth(\Master, [\in, ~busMaster]);

	~reverb = Synth.before(~master, \Reverb, [\in, ~busReverb, \out, ~busMaster,
		\roomSize, 15,
		\dry, 0.9,
		\time, 5,
		\head, 0.4,
		\tail, 0.3,
		\damping, 0.7
	]);
	~delay = Synth.before(~reverb, \Greyish, [\in, ~busDelay, \out, ~busReverb,
		\damping, 0.2,
		\delayTime, 15,
		\diffusion, 0.7,
		\feedback, 0.8,
		\size, 0.3
	]);

	Pbind(
		\instrument, \electrohihat,
		\dur, Pseq(hhbeatA, inf),
		\pan, -0.7,
		\amp, 0.4,
		\dry, 0,
		\fx, ~busReverb
	).play;

	Pbind(
		\instrument, \clap,
		\dur, Pseq(hhbeatB, inf),
		\pan, 0.7,
		\amp, 0.1,
		\dry, 0,
		\fx, ~busReverb
	).play;

	Pbind(
		\instrument, \electrosnare,
		\dur, Pseq(snbeat, inf),
		\pan, -0.3,
		\amp, 0.3,
		\dry, 0,
		\fx, ~busReverb
	).play;


	Pbind(
		\instrument, \electrokick,
		\dur, Pseq(kbeat, inf),
		\pan, 0.2,
		\amp, 0.6,
		\dry, 0,
		\fx, ~busReverb
	).play;

	Pbind(
		\instrument, \fatsaw,
		\amp, 0.4,
		\attack, 0.5,
		\decay, 0.1,
		\sustain, 1,
		\release, 5,
		\filterSpeed, Pfunc({rand(0.5)}),
		\filterFreqStart, 50,
		\filterFreqEnd, 800,
		\dry, 0,
		\fx, ~busDelay,
		\pan, 1,
		\dur, Pseq(sawbeat.collect(_*3), inf),
		\midinote, Pfunc({#[48, 52].choose})
	).play;
	//intro.play;

	Pbind(
		\instrument, \organ,
		\amp, Pseq([0.6,0.15,0.2,0.25,0.3,0.25,0.2,0.15]*0.1, inf),
		\attack, 0.5,
		\decay, 0.1,
		\sustain, 0.5,
		\release, 0.1,
		\dry, 0,
		\fx, ~busReverb,
		\pan, -1,
		\dur, Pseq(orgbeat, inf),
		\midinote, Pseq([60, 64, 67], inf)
	).play;

	Routine({
		var tempo = 1.0;
		loop {
			tempo = tempo + 0.01;
			TempoClock.default.tempo_(tempo);
			if (tempo > 3) {
				0.yield;
			} {
				(1 / tempo).yield;
			}
		}
	}).play;
//	s.scope;
});
)