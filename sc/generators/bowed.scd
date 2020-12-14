(
SynthDef(\Bowed, { arg out = 0, fx = 0,  amp = 0.5, dry = 0.5, freq=440, force=1, gate=1, pos=0.07, c1=0.25, c3=31, pan=0;
    var vib = Gendy1.kr(1,1,1,1,0.1, 4, mul:0.003, add:1);
    var snd = DWGBowedSimple.ar(freq * vib, amp, force, gate, pos, 0.1, c1, c3);
    snd = DWGSoundBoard.ar(snd);
    snd = BPF.ar(snd,  0.2 * freq, 1) + snd;
    snd = BPF.ar(snd,  0.9 * freq, 1) + snd;
    snd = BPF.ar(snd,  1.1 * freq, 1) + snd;
    snd = LPF.ar(snd, 13.6 * freq) * (amp / 10);

	// Panned output
	~outWithSidechain.(snd, out, fx, amp, pan, dry);
}).add;
)