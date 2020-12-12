(
SynthDef(\feedbacker, { arg outBus = 0, effectBus = 0, level = 1, direct = 0.5, pan = 0, midiBase = 40, rt = 0.25;
	var freq = Duty.ar(16/rt, 0, Dseq([0,8,7,-1,1,4,5].collect(_ + midiBase).midicps, inf));

	var src = Saw.ar(freq) * Decay.ar(Impulse.ar(rt),1/rt,0.25);
	//src = SoundIn.ar(0);
	var loc = LocalIn.ar(2) + src;

	loc = FreqShift.ar(loc, -1);
	loc = loc + DelayC.ar(loc, 0.2, freq.reciprocal);
	loc = DelayC.ar(loc, 4, LFNoise1.ar(rt ! 2).range(0.25, 2));
	loc = DelayC.ar(loc, 4, 2);
	//loc = (loc*250).tanh;
	//loc = LPF.ar(loc,2500);
	loc = loc + AllpassC.ar(loc, 0.1, LFNoise0.ar(rt ! 2).range(0.05, 0.1), 4);
	loc = HPF.ar(loc, 100);
///	LocalOut.ar(loc * 1.75);

	loc = Pan2.ar(Limiter.ar(loc), pan, level);

	Out.ar(effectBus, loc * (1 - direct));
	Out.ar(outBus, loc * direct);
}).add;

)