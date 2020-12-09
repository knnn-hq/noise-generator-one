(Quarks.save(Document.current.dir.postln ++ "/quarks.txt");)
(Quarks.load(Document.current.dir.postln ++ "/quarks.txt");)
(
MIDIClient.init;
MIDIIn.connectAll;
)
(
Require("helpers/**", always: true);
Require("generators/**", always: true);
Require("effects/**", always: true);
~busMaster = Bus.audio(s, 2);
~busR = Bus.audio(s, 2);
~busD = Bus.audio(s, 2);

~masterReverb = Synth.new(\Reverb, [\inBus, ~busMaster,
	\roomSize, 66,
	\dry, 0.95,
	\time, 15,
	\head, 0.5,
	\tail, 0.25,
	\damping, 0.3
]);

~reverb = Synth.before(~masterReverb, \Reverb, [\inBus, ~busR, \outBus, ~busMaster,
	\roomSize, 10,
	\damping, 0.1
]);
~delay = Synth.before(~masterReverb, \Greyish, [\inBus, ~busD, \outBus, ~busMaster]);

~atari = Synth.before(~delay, \Atari, [\effectBus, [~busD, ~busD]]);
~bosh = Synth.before(~delay, \Bosh, [\effectBus, [~busD, ~busR]]);
~piano = Synth.before(~reverb, \PianoRepeater, [\effectBus, [~busR, ~busD],
	\rate, 0.3
]);

~midiCC = MIDIFunc.cc({arg ...args;
	"CC".postln;
	args.postln;
});
~midiNote = MIDIFunc.noteOn({arg ...args;
	"Note".postln;
	args.postln;
});
~midiBend = MIDIFunc.bend({arg num, chan, src;
	var target = switch(chan,
		0, { ~atari },
		1, { ~bosh },
		2, { ~piano },
		8, { ~masterReverb },
		{ false }
	);
	var level = LinLin.ar(num, 0, 16383, 0, 1);
	if (target != false, {
		target.set(\level, LinLin.ar(num, 0, 16383, 0, 1));
	});
});

MIDIFunc.trace(true);


Routine {
	Window()
	.alwaysOnTop_(true)
	.onClose_({ s.freeAll })
	.layout_(VLayout(
		VLayout(
			StaticText().string_("Generators"),
			HLayout(
				VLayout(
					StaticText().string_("Atari"),
					HLayout(
						~makeSlider.value("dry", ~atari, \direct, start: 0.1)
					)
				),
				20,
				VLayout(
					StaticText().string_("Bosh"),
					HLayout(
						~makeSlider.value("dry", ~bosh, \direct, start: 0.5),
						~makeSlider.value("rate", ~bosh, \rate, start: 0.5, min: 0.1, max: 10),
					)
				),
				20,
				VLayout(
					StaticText().string_("Piano"),
					HLayout(
						~makeSlider.value("dry", ~piano, \direct, start: 0.5)
					)
				),

			),
		),
		20,
		VLayout(
			StaticText().string_("Effects"),
			HLayout(
				VLayout(
					StaticText().string_("Reverb"),
					HLayout(
						~makeSlider.value("delay", ~reverb, \time, start: 12, min: 0, max: 30),
						~makeSlider.value("head level", ~reverb, \head, start: 0.8),
						~makeSlider.value("tail level", ~reverb, \tail, start: 0.6)
					)
				),
				20,
				VLayout(
					StaticText().string_("Delay"),
					HLayout(
						~makeSlider.value("delay", ~delay, \delayTime, start: 2, min: 0.1, max: 60),
						~makeSlider.value("diffusion", ~delay, \diffusion, start: 0.8),
						~makeSlider.value("feedback", ~delay, \feedback, start: 0.666),
						~makeSlider.value("size", ~delay, \size, start: 0.666, min: 0.5, max: 5),
					)
				)

			)
		)
	)).front;
}.play(AppClock)
)
