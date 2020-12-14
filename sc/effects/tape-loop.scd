(
SynthDef(\tapeloop_play, { arg out=0, fx=0, amp=1, dry=0.5, pan=0, bufnum=0, cutLevel=1, cutStart=0, cutLength=0, playRate=1, dist=0.2;
	var envFreq = ((BufSampleRate.kr(bufnum) * playRate) / BufSamples.kr(bufnum)) * 10;
	var envMod = Env([0.1, 0.6, 0.4, 1.0], [1, 1.1, 1, 1.2] , \exp, loopNode: 1).circle;

	var distEnv = EnvGen.kr(envMod, timeScale: envFreq);
	var distEnvRes = EnvGen.kr(envMod, timeScale: envFreq * 2);
	var distFreqEnv = TRand.kr(0, 1, trig: EnvGen.kr(envMod, timeScale: envFreq * 3));

	var panNoiseEnv = EnvGen.kr(envMod, gate: Dust.kr(2.3), levelScale: 0.1, timeScale: envFreq);

	var cleanbuf = PlayBuf.ar(1, bufnum, rate: BufRateScale.kr(bufnum) * playRate, loop: 1, doneAction: 2);
	var distbuf = MoogLadder.ar(cleanbuf,
		ffreq: distFreqEnv * 20000,
		res: distEnvRes * 0.5,
		mul: distEnv
	);
	var playbuf = (cleanbuf * (1 - dist)) + (distbuf * dist);
	var recordbuf = playbuf * if(cutLevel == 1, {1}, {
		EnvGen.kr(Env.step([1, cutLevel, 1], [cutStart, cutLength, 0]))
	});
	var revbuf = GVerb.ar(playbuf, 23, 4, 0.4, 0.19, 14, -3.dbamp, -9.dbamp, -11.dbamp, 80, 0.3);

	var output = Pan2.ar((revbuf + playbuf), pan * (panNoiseEnv - 0.05), amp);

	RecordBuf.ar(recordbuf, bufnum,  doneAction: 2, loop: 0);

	Out.ar(fx, output * (1 - dry));
	Out.ar(out, output * dry);
}).add;


~tapeloop_loadAndPlay = { arg filename, out = 0, fx = 0, level = 1.0, dry = 0.5, startRate = 0.5, startDist = 0.2, pan = 0;
	var basename = PathName(filename).fileName;
	var synth;

	var createRoutine = { arg sampleBuf;
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

			var playDirection = ~q.((startRate < 0), -1, 1);
			var rate = startRate.abs;
			var rateDeltaDir = -1; // initially, lower rate each loop

			var distLevel = startDist;

			loop {
				coinValue = coinValue + degradeModifier;

				if (coinValue.coin, {
					cutLevel = 0;
					cutStart = ~r.(loopLen);
					cutLength = ~r.(loopLen * maxPossibleCutLength);
				}, {
					cutLevel = 1;
					cutStart = 0;
					cutLength = 0;
				});

				"LOOP|".post; basename.post;
				" -- rate: ".post; (rate * playDirection).post;
				" -- dist: ".post; distLevel.postln;

				if (not(synth.isNil), {
					synth.stop;
					synth.free;
				});

				synth = Synth(\tapeloop_play, [\out, out, \fx, fx,
					\bufnum, sampleBuf,
					\cutLevel, cutLevel,
					\cutStart, cutStart,
					\cutLength, cutLength,
					\level, level,
					\dry, dry,
					\playRate, rate * playDirection,
					\dist, distLevel,
					\pan, pan
				]);

				rateDeltaDir = ~lim.(rateDeltaDir, 0.15, 0.95, 1, -1);
				rate = (rate + (~r.(0.5) * rateDeltaDir));
				playDirection = playDirection * -1;

				distLevel = min(0.8, ~rr.(distLevel + degradeModifier, distLevel + coinValue));

				delta = loopLen / rate.abs;
				delta.yield;
			};
		}).play;
	};

	Buffer.readChannel(s, filename, channels: [0], action: createRoutine);

	synth;
};
)