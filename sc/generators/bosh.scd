(
SynthDef.new(\Bosh, { arg rate = 2, outBus = 0, effectBus, direct = 0.2;
	var trg = Decay2.ar(Impulse.ar(rate,0,0.3), 0.5, 1);
	var osc = {GrayNoise.ar(trg)}.dup;
	Out.ar(effectBus, osc * (1 - direct));
	Out.ar(outBus, osc * direct);
}).add;
)