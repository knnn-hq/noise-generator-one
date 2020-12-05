(
SynthDef.new(\Grain, { arg grainSize = 0.5, pitchRatio = 0.3, pitchDispersion = 2, timeDispersion = 4.0, outBus = 0, inBus;
	var input = In.ar(inBus, 2);
	var shift = PitchShift.ar(input, grainSize, pitchRatio, pitchDispersion, timeDispersion);

	Out.ar(outBus, shift);
}).add;
)