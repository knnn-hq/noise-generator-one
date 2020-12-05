(
SynthDef.new(\Crack, { arg chaos = 1.2, outBus = 0, effectBus, direct = 0.5;
	var crack = Ramp.ar(Crackle.ar(chaos), 0.2);
	Out.ar(effectBus, crack * (1 - direct));
	Out.ar(outBus, crack * direct);
}).add;
)