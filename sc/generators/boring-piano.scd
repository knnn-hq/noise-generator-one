(
SynthDef.new(\PianoRepeater, { arg outBus = 0, effectBus, level = 1.0, direct = 0.9;
	var piano = MdaPiano.ar(
        LFNoise0.kr(\rate.kr(0.5)).range(0, 20).round.midicps, // random note
        stereo: 0.5,
        gate: LFPulse.kr(\rate.kr(0.5)),
        vel: LFPar.kr(0.1).range(10, 100), // varying velocity
        mul: level,
		sustain: LFPulse.kr(\rate.kr(0.5) / 3)
    );
	var crushedPiano = Decimator.ar(piano, rate: 14000, bits: 8);
	Out.ar(effectBus, crushedPiano * (1 - direct));
	Out.ar(outBus, crushedPiano * direct);
}).add;
)