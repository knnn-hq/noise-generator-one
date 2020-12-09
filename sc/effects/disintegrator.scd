(
SynthDef(\Disintegrator, { arg inBus = 0, outBus = 0, size = 0.5, rate = 55, level = 0.5;
	var input = In.ar(inBus, 2);
	var outputL = MonoGrain.ar(input[0], size, rate, 25, level);
	var outputR = MonoGrain.ar(input[1], size * 0.99, rate * 0.99, 25, level);
	var output = Disintegrator.ar([outputL, outputR], 0.5, -1);
//	var output = Decimator.ar(Disintegrator.ar(input, probability, multiplier, level), bits: 8);

	Out.ar(outBus, output);
}).add;
)