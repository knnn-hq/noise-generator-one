(
SynthDef(\patch, {
	arg in = 0, out = 0, amp = 1.0, pan = 0, numChannels = 2;
	var input = In.ar(in, numChannels);

	Out.ar(out, Pan2.ar(input, pan, amp));
}).add;
)