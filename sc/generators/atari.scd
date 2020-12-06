(
SynthDef(\Atari, { arg rateA = 1.5, rateB = 0.3, rateC = 0.5, outBus = 0, effectBus, direct = 0.5, level = 1.0;
	var rate = rateA * rateB * rateC;
	var ay = AY.ar(
        tonea:     LFDNoise3.kr(rateA).range(3000, 4095),
        toneb:     LFDNoise3.kr(rateB).range(2500, 3095),
        tonec:     LFDNoise3.kr(rateC).range(2750, 4095),
        noise:     LFDNoise3.kr(rate).range(0, 10),
        vola:     LFDNoise3.kr(rateA / 2).range(12, 15),
        volb:     LFDNoise3.kr(rateB / 2).range(12, 15),
        volc:     LFDNoise3.kr(rateC / 2).range(12, 15),
        envfreq:     LFDNoise3.kr(rate).range(1500, 4095),
        mul: level
    );
	Out.ar(effectBus, ay * (1 - direct));
	Out.ar(outBus, ay * direct);
}).add;
)
