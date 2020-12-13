(
SynthDef(\Greyish, { arg outBus = 0, inBus, damping = 0, delayTime = 5.0, diffusion = 0.666, feedback = 0.9, moddepth = 0.1, modfreq = 2, size = 0.666;
	var input = In.ar(inBus, 2);
	var reverb = GreyholeRaw.ar(input[0], input[1], damping, delayTime, diffusion, feedback, moddepth, SinOsc.kr(modfreq, 0.5), size);

	Out.ar(outBus, reverb);
}).add;
)