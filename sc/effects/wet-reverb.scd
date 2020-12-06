(
SynthDef(\Reverb, { arg outBus = 0, inBus, roomSize = 50, time = 4.0, damping = 0.1, inputDamping = 0.1, spread = 15, dry = 0, head = 0.85, tail = 0.5;
	var input = In.ar(inBus, 2);
	var reverb = GVerb.ar(input, roomSize, time, damping, inputDamping, spread, dry, head, tail);

	Out.ar(outBus, reverb);
}).add;
)