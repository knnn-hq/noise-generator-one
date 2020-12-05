(
SynthDef(\Reverb, { arg outBus = 0, inBus, mix = 0.5, room = 1, damp = 0.1;
	var input = In.ar(inBus, 2);
	var reverb = FreeVerb2.ar(input[0], input[1], mix, room, damp);

	Out.ar(outBus, reverb);
}).add;
)