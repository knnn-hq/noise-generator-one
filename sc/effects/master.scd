(
var mx = { arg ...channels;
	channels.reduce({ |p, c| (p * 0.5) + (c * 0.5) });
};
SynthDef(\Master, { arg outBus = 0, inBus = 0;
	var in = In.ar(inBus, 2);
	var effected = mx.(
		Normalizer.ar(LPF.ar(in, 66), 1.0),
		LPF.ar(in, 90),
		[BPF.ar(in[0], 400, 4), BPF.ar(in[1], 410, 5)]
	);
	var output = mx.(in, effected);
	Out.ar(outBus, output);
}).add;
)