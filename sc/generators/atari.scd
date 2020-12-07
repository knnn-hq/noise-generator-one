(
SynthDef(\Atari, { arg outBus = 0, effectBus;
	var baseRate = \rate.kr(1);
	var rateA = baseRate / 2, rateB = baseRate / 3, rateC = baseRate / 4;
	var directLevel = \direct.kr(0.5);
	var effectLevel = 1 - directLevel;

	var ay = AY.ar(
        tonea:     LFDNoise3.kr(rateA).range(4000, 4095),
        toneb:     LFDNoise3.kr(rateB).range(4000, 4095),
        tonec:     LFDNoise3.kr(rateC).range(4000, 4095),
        noise:     LFDNoise3.kr(baseRate).range(0, 10),
        vola:     LFDNoise3.kr(rateA / 2).range(12, 15),
        volb:     LFDNoise3.kr(rateB / 2).range(6, 12),
        volc:     LFDNoise3.kr(rateC / 2).range(10, 13),
        envfreq:     LFDNoise3.kr(baseRate).range(2500, 3000),
		mul: \level.kr(1.0)
    );
	var crushed = Decimator.ar(ay, LFDNoise3.kr(baseRate).range(10000, 20000), LFDNoise3.kr(baseRate).range(1, 4));

	Out.ar(effectBus, crushed * effectLevel);
	Out.ar(outBus, crushed * directLevel);
}).add;
)
