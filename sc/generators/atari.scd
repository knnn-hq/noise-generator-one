(
SynthDef(\Atari, { arg out = 0, fx = 0, dry = 0, rate = 1.0, amp = 1.0, pan = 0;
	var rateA = rate / 2;
  var rateB = rate / 3;
  var rateC = rate / 4;

	var snd = AY.ar(
      tonea:     LFDNoise3.kr(rateA).range(4000, 4095),
      toneb:     LFDNoise3.kr(rateB).range(4000, 4095),
      tonec:     LFDNoise3.kr(rateC).range(4000, 4095),
      noise:     LFDNoise3.kr(rate).range(0, 10),
      vola:     LFDNoise3.kr(rateA / 2).range(12, 15),
      volb:     LFDNoise3.kr(rateB / 2).range(6, 12),
      volc:     LFDNoise3.kr(rateC / 2).range(10, 13),
      envfreq:     LFDNoise3.kr(rate).range(2500, 3000)
  );
	snd = Decimator.ar(snd, LFDNoise3.kr(rate).range(10000, 20000), LFDNoise3.kr(rate).range(1, 4));

	// Panned output
	~outWithSidechain.(snd, out, fx, amp, pan, dry);
}).add;
)
