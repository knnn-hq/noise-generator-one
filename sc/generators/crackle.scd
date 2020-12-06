(
SynthDef.new(\Crack, { arg chaos = 1.2, outBus = 0, effectBus, direct = 0.5, level = 1.0;
	var crack = Crackle.ar(chaos, level);
	Out.ar(effectBus, crack * (1 - direct));
	Out.ar(outBus, crack * direct);
}).add;
)