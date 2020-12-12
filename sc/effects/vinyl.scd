(
~noise = { |rate, min, max| LFNoise1.kr(rate).range(min, max) };
~noise_e = { |rate, min, max| LFNoise1.kr(rate).exprange(min, max) };
~mix = (_ + _);
~mf  = { arg func, mix = ~mix; { |val| ~mix.(val, func.(val)); } };
~chain = { arg init, funcs;
	var prev = init;
	funcs.do({ |f| prev = ~mix.(prev + f.(prev)); });
	prev;
};
~noisefuncs = [
	~mf.(LPF.ar(_, ~noise_e.(10, 1000, 20000))),
	~mf.(Lag.ar(_, ~noise.(20, 0.008, 0.0001))),
	~mf.(FreeVerb.ar(_, 0.8, 1, mul: 0.11)),
	~mf.({ |val|
		var mod = { SinOsc.kr(~noise.(5, 0.2, 0.7)).range(-0.2, 0.2); };
		~mix.(Pan2.ar(val, mod.value, 0.5), Pan2.ar(val, mod.value, 0.5));
	}),
	~mix.(_, BPF.ar(BrownNoise.ar([0.01, 0.002]), 7200, 0.4)),
	~mix.(_, HPF.ar(Crackle.ar([1.999,1.999], 0.0025), 2000))
];


SynthDef(\vinyl, { arg outBus=0, effectBus=0, level=1, direct=1, pan=0;
	var output = LPF.ar(GrayNoise.ar(0.001), 100) + BPF.ar(Dust2.ar(0.01, 0.1), 230, 0.2);
	~noisefuncs.do({ |f|
		output = f.(output);
	});
	output = output * level;

	Out.ar(effectBus, output * (1 - direct));
	Out.ar(outBus, output * direct);
}).add;
)