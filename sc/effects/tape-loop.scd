(
var sr = { arg n; n.softRound(0.01, 0); };
var r = { arg max, min = 0; sr.value(rrand(min, max)); };

SynthDef(\tapeloop_play, { arg outBus = 0, effectBus, level = 1.0, direct = 0.5, bufnum = 0, cutLevel = 1, cutStart = 0, cutLength = 0, playRate = 1.0;
	var playbuf, recordBuf, sound;

	playbuf = PlayBuf.ar(1, bufnum, rate: BufRateScale.kr(bufnum) * playRate, startPos: 0, loop: 1, doneAction: 2);
	recordBuf = playbuf * EnvGen.kr(Env.step([1, cutLevel, 1], [cutStart, cutLength, 0]));

	RecordBuf.ar(recordBuf, bufnum,  doneAction: 2, loop: 0);

	sound = (
		GVerb.ar(playbuf, r.value(23, 50), r.value(3, 5), r.value(0.3, 0.45), 0.19, r.value(10, 15), -3.dbamp, -9.dbamp, -11.dbamp, 80, 0.3)
		+ playbuf
	) * level;

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;

~create_loop_routine = { arg sampleBuf, effectBus, outBus = 0, level, direct, startRate;
	var numFrames = sampleBuf.numFrames;
	var loopLen = (numFrames / sampleBuf.sampleRate) / 2;
	var degradeModifier = 0.05;
	var maxPossibleCutLength = 1/12;

	Routine({
		var delta;
		var cutLevel = 1;
		var cutStart = 0;
		var cutLength = 0;
		var coinValue = 0.3;
		var rate = startRate.abs;
		var rateDeltaDir = -1;
		var playDirection = if (startRate < 0, { -1 }, { 1 });
		var synth;

		loop {
			coinValue = coinValue + degradeModifier;

			if (coinValue.coin, {
				cutLevel = 0;
				cutStart = r.value(loopLen);
				cutLength = r.value(loopLen * maxPossibleCutLength);
			}, {
				cutLevel = 1;
				cutStart = 0;
				cutLength = 0;
			});

			"Restarting loop...".postln;
			sampleBuf.postln;
			(rate * playDirection).postln;

			if (not(synth.isNil), { // stop synth if playing
				synth.stop;
				synth.free;
			});

			synth = Synth(\tapeloop_play, [\outBus, outBus, \effectBus, effectBus,
				\bufnum, sampleBuf,
				\cutLevel, cutLevel,
				\cutStart, cutStart,
				\cutLength, cutLength,
				\level, level,
				\direct, direct,
				\playRate, rate * playDirection
			]);

			if (rate.abs <= 0.15, { rateDeltaDir = 1 }, {
				if (rate.abs >= 0.95, { rateDeltaDir = -1 });
			});
			rate = (rate + (r.value(0.5) * rateDeltaDir));
			playDirection = playDirection * -1;

			delta = (loopLen - r.value(loopLen / 24));
			delta.yield;
		};
	});
};

~load_and_play_loop = { arg filename, effectBus, level = 1.0, direct = 0.5, startRate = 0.5;
	var routine;
	Buffer.readChannel(s, filename, channels: [0], action: { arg buffer;
		routine = ~create_loop_routine.value(buffer, effectBus: effectBus, level: level, direct: direct, startRate: startRate).play;
	});
	routine;
};
)