(
SynthDef(\tapeloop_play, { arg outBus = 0, effectBus, level = 1.0, direct = 0.5, bufnum = 0, cutLevel = 1, cutStart = 0, cutLength = 0;
    var playbuf, recordBuf, sound;

	playbuf = PlayBuf.ar(1, bufnum, doneAction: 2);
	recordBuf = playbuf * EnvGen.kr(Env.step([1, cutLevel, 1], [cutStart, cutLength, 0]));

	RecordBuf.ar(recordBuf, bufnum, doneAction: 2, loop: 0);

	sound = (GVerb.ar(
        playbuf,
        80,
        4.85,
        0.41,
        0.19,
        15,
        -3.dbamp,
        -9.dbamp,
        -11.dbamp,
        80, 0.3
	) + playbuf) * level;

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;

~create_loop_routine = { arg sampleBuf, effectBus, outBus = 0, level, direct;
	var loopLen = sampleBuf.numFrames / sampleBuf.sampleRate;
	var degradeModifier = 0.05;
	var maxPossibleCutLength = 1/12;

	Routine({
		var delta;
		var cutLevel = 1;
		var cutStart = 0;
		var cutLength = 0;
		var coinValue = 0.3;

		loop {
			coinValue = coinValue + degradeModifier;
			if (coinValue.coin, {
				cutLevel = 0;
				cutStart = loopLen.rand;
				cutLength = (loopLen*maxPossibleCutLength).linrand;
			}, {
				cutLevel = 1;
				cutStart = 0;
				cutLength = 0;
			});

			"Restarting loop...".postln;
			sampleBuf.postln;

			Synth(\tapeloop_play, [\outBus, outBus, \effectBus, effectBus,
				\bufnum, sampleBuf,
				\cutLevel, cutLevel,
				\cutStart, cutStart,
				\cutLength, cutLength,
				\level, level,
				\direct, direct
			]);

			delta.yield;
		};
	});
};

~load_and_play_loop = { arg filename, effectBus, level = 1.0, direct = 0.5;
	var routine;
	Buffer.readChannel(s, filename, channels: [0], action: { arg buffer;
		routine = ~create_loop_routine.value(buffer, effectBus: effectBus, level: level, direct: direct).play;
	});
	routine;
};
)