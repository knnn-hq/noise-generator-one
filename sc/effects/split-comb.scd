(
SynthDef(\SplitComb, { arg inBus, outBus = 0, diff = 0.15;
	var in = In.ar(inBus, 2);
	var env = EnvGen.kr(
		Env([0.1, 0.6, 0.3, 1.0], 2 ! 4, \exp, loopNode: 1).circle,
		gate: Dust.kr(2.3)
	);
	var combed = Pan2.ar(
		CombN.ar(in, delaytime: env * diff, maxdelaytime: 0.5),
		(diff / 2) * env
	);
	var output = (in * (1 - diff)) + (combed * diff);
	Out.ar(outBus, output);
}).add;
)