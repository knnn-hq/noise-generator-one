(
SynthDef(\Bowed, { arg outBus = 0, effectBus = 0,  level = 0.5, direct = 0.5, freq=440, force=1, gate=1, pos=0.07, c1=0.25, c3=31, pan=0;
    var vib = Gendy1.kr(1,1,1,1,0.1, 4,mul:0.003,add:1);
    var sound = DWGBowedSimple.ar(freq*vib, level, force, gate, pos, 0.1, c1, c3);
    sound = DWGSoundBoard.ar(sound);
    sound = BPF.ar(sound,118,1)+sound;
    sound = BPF.ar(sound,430,1)+sound;
    sound = BPF.ar(sound,490,1)+sound;
    sound = LPF.ar(sound,6000);
	sound = Pan2.ar(sound * 0.1, pan);

	Out.ar(effectBus, sound * (1 - direct));
	Out.ar(outBus, sound * direct);
}).add;
)