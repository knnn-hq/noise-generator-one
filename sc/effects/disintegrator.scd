(
SynthDef(\Disintegrator, { arg inBus = 0, outBus = 0, probability = 0.5, multiplier = 0.5, level = 0.5;
	var input = In.ar(inBus, 2);
	var output = Decimator.ar(Disintegrator.ar(input, probability, multiplier, level), bits: 8);

	Out.ar(outBus, output);
}).add;
)