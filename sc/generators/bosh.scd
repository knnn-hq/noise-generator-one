(
SynthDef.new(\Bosh, { arg out = 0, fx = 0, amp = 1.0, dry = 0.0, pan = 0, rate = 2, att = 0.6, dec = 1.0;
	var trg = Decay2.ar(Impulse.ar(rate, 0, 0.3), att, dec);
	var snd = {GrayNoise.ar(trg  * amp)} ! 2;

	// Panned output
	~outWithSidechain.(snd, out, fx, amp, pan, dry);	
}).add;
)