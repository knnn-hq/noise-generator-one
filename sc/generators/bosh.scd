(
SynthDef.new(\Bosh, { arg outBus = 0, effectBus;
	var trg = Decay2.ar(Impulse.ar(\rate.kr(2), 0, 0.3), \attack.kr(0.6), \decay.kr(1.0));
	var osc = {GrayNoise.ar(trg  * \level.kr(1.0))}.dup;
	var directLevel = \direct.kr(0.2);
	Out.ar(effectBus, osc * (1 - directLevel));
	Out.ar(outBus, osc * directLevel);
}).add;
)