(
SynthDef(\Ladder, { arg outBus = 0, inBus, freq = 90, res = 1.5, reset = 0;
	var input = In.ar(inBus, 2);
	var ladder = MoogFF.ar(input, freq, res, reset);

	Out.ar(outBus, ladder);
}).add;
)