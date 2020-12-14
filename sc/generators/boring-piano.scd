(
SynthDef.new(\PianoRepeater, { arg out = 0, fx, amp = 1.0, dry = 0.9, pan = 0;
	var piano = MdaPiano.ar(
        LFNoise0.kr(\rate.kr(0.5)).range(0, 20).round.midicps, // random note
        stereo: 0.5,
        gate: LFPulse.kr(\rate.kr(0.5)),
        vel: LFPar.kr(0.1).range(10, 100), // varying velocity
        mul: amp,
		sustain: LFPulse.kr(\rate.kr(0.5) / 3)
    );
	var crushedPiano = Decimator.ar(piano, rate: 14000, bits: 8);
	Out.ar(fx, crushedPiano * (1 - dry));
	Out.ar(out, crushedPiano * dry);
}).add;
)