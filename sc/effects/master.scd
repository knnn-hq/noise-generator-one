(
var mx = { arg ...channels;
	channels.reduce({ |p, c| (p * 0.5) + (c * 0.5) });
};

SynthDef(\Master, { arg out = 0, in = 0;
	var input = In.ar(in, 2);
	var effected = mx.(
		Normalizer.ar(LPF.ar(input, 66), 1.0),
		LPF.ar(input, 90),
		[BPF.ar(input[0], 400, 4), BPF.ar(input[1], 410, 5)]
	);
	var output = mx.(input, effected);
	Out.ar(out, output);
}).add;
)