(
SynthDef.new(\Bosh, { arg rate = 2, outBus = 0, effectBus, direct = 0.2, attack = 0.6, decay = 1.0, level = 1.0;
	var trg = Decay2.ar(Impulse.ar(rate, 0, 0.3), attack, decay);
	var osc = {GrayNoise.ar(trg  * level)}.dup;
	Out.ar(effectBus, osc * (1 - direct));
	Out.ar(outBus, osc * direct);
}).add;
)