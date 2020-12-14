(
SynthDef(\Reverb, { arg out = 0, in, roomSize = 50, time = 4.0, damping = 0.1, inputDamping = 0.1, spread = 15, dry = 0, head = 0.85, tail = 0.5, amp = 1.0;
	var input = In.ar(in, 2);
	var reverb = GVerb.ar(input, roomSize, time, damping, inputDamping, spread, dry, head, tail);

	Out.ar(out, reverb * amp);
}).add;
)