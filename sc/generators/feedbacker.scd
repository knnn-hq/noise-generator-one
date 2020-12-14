(
SynthDef(\feedbacker, { arg out = 0, fx = 0, amp = 1, dry = 0.5, pan = 0, miditone = 40, rt = 0.25;
	var freq = Duty.ar(16/rt, 0, Dseq([0,8,7,-1,1,4,5].collect(_ + miditone).midicps, inf));

	var src = Saw.ar(freq) * Decay.ar(Impulse.ar(rt),1/rt,0.25);
	var loc = LocalIn.ar(2) + src;

	loc = FreqShift.ar(loc, -1);
	loc = loc + DelayC.ar(loc, 0.2, freq.reciprocal);
	loc = DelayC.ar(loc, 4, LFNoise1.ar(rt ! 2).range(0.25, 2));
	loc = DelayC.ar(loc, 4, 2);
	loc = loc + AllpassC.ar(loc, 0.1, LFNoise0.ar(rt ! 2).range(0.05, 0.1), 4);
	loc = HPF.ar(loc, 100);

	~outWithSidechain.(Limiter.ar(loc), out, fx, amp, pan, dry);
}).add;
)