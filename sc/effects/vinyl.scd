(
var noise = { |rate, min, max| LFNoise1.kr(rate).range(min, max) };
var noise_e = { |rate, min, max| LFNoise1.kr(rate).exprange(min, max) };
var mix = (_ + _);
var mf  = { arg func, m = mix; { |val| m.(val, func.(val)); } };
var chain = { arg init, funcs;
	var prev = init;
	funcs.do({ |f| prev = mix.(prev + f.(prev)); });
	prev;
};
var noisefuncs = [
	mf.(LPF.ar(_, noise_e.(10, 1000, 20000))),
	mf.(Lag.ar(_, noise.(20, 0.008, 0.0001))),
	mf.(FreeVerb.ar(_, 0.8, 1, mul: 0.11)),
	mf.({ |val|
		var mod = { SinOsc.kr(noise.(5, 0.2, 0.7)).range(-0.2, 0.2); };
		mix.(Pan2.ar(val, mod.value, 0.5), Pan2.ar(val, mod.value, 0.5));
	}),
	mix.(_, BPF.ar(BrownNoise.ar([0.01, 0.002]), 7200, 0.4)),
	mix.(_, HPF.ar(Crackle.ar([1.999,1.999], 0.0025), 2000))
];


SynthDef(\vinyl, { arg out=0, fx=0, amp=1, dry=1, pan=0;
	var output = LPF.ar(GrayNoise.ar(0.001), 100) + BPF.ar(Dust2.ar(0.01, 0.1), 230, 0.2);
	noisefuncs.do({ |f| output = f.(output);});
	output = output * amp;

	// Panned output
	~outWithSidechain.(output, out, fx, amp, pan, dry);
}).add;
)