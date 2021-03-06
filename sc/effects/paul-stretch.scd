(
SynthDef(\paulstretchMono, { 
	arg out = 0, fx = 0, amp = 1.0, dry = 0.5, bufnum, envBufnum, pan = 0, stretch = 50, window = 0.25, amp = 1;
	// Paulstretch for SuperCollider
	// Based on the Paul's Extreme Sound Stretch algorithm by Nasca Octavian PAUL
	// https://github.com/paulnasca/paulstretch_python/blob/master/paulstretch_steps.png
	//
	// By Jean-Philippe Drecourt
	// http://drecourt.com
	// April 2020
	//
	// Arguments:
	// out: output bus (stereo output)
	// bufnum: the sound buffer. Must be Mono. (Use 2 instances with Buffer.readChannel for stereo)
	// envBufnum: The grain envelope buffer created as follows:
	//// envBuf = Buffer.alloc(s, s.sampleRate, 1);
	//// envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
	//// envBuf.loadCollection(envSignal);
	// pan: Equal power panning, useful for stereo use.
	// stretch: stretch factor (modulatable)
	// window: the suggested grain size, will be resized to closest fft window size
	// amp: amplification
	var trigPeriod, sig, chain, trig, pos, fftSize, output;
	// Calculating fft buffer size according to suggested window size
	fftSize = 2**floor(log2(window*SampleRate.ir));
	// Grain parameters
	// The grain is the exact length of the FFT window
	trigPeriod = fftSize/SampleRate.ir;
	trig = Impulse.ar(1/trigPeriod);
	pos = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod/stretch));
	// Extraction of 2 consecutive grains
	// Both grains need to be treated together for superposition afterwards
	sig = [GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos, envbufnum: envBufnum),
		GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos + (trigPeriod/(2*stretch)), envbufnum: envBufnum)];
	// FFT magic
	sig = sig.collect({ |item, i|
		chain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
		// PV_Diffuser is only active if its trigger is 1
		// And it needs to be reset for each grain to get the smooth envelope
		chain = PV_Diffuser(chain, 1 - trig);
		item = IFFT(chain, wintype: -1);
	});
	// Reapply the grain envelope because the FFT phase randomization removes it
	sig = sig*PlayBuf.ar(1, envBufnum, 1/(trigPeriod), loop:1);
	// Delay second grain by half a grain length for superposition
	sig[1] = DelayC.ar(sig[1], trigPeriod/2, trigPeriod/2);

	// Panned output
	~outWithSidechain.(Mix.new(sig), out, fx, amp, pan, dry);
}).add;


~paulstretch_loadAndPlay = { arg filename, out = 0, fx = 0, amp = 1.0, dry = 0.5, stretch = 50, window = 0.25, pan = 0;
	var envBuf = Buffer.alloc(s, s.sampleRate, 1);
	var envSignal = Signal.newClear(s.sampleRate).waveFill({ |x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
	var currStretch = 10;
	var basename = PathName(filename).fileName;
	var synth;

	var do_stretch = { | buffer |
		"STRETCH|".post; basename.post; " -- factor: ".post; currStretch.postln;

		Routine({
			var delta;
			synth = Synth(\paulstretchMono, [
				\out, out, \fx, fx,
				\bufnum, buffer, \envBufNum, envBuf,
				\amp, amp, \dry, dry,
				\stretch, currStretch, \window, window,
				\pan, pan
			]);
			loop {
				if (currStretch < stretch, {
					currStretch = currStretch * 1.5;
				}, {
					currStretch = currStretch + 0.5;
				});
				synth.set(\stretch, currStretch);

				delta = ~rr.(1, 5);
				delta.yield;
			};
		}).play;
	};

	envBuf.loadCollection(envSignal);
	s.sync();

	Buffer.readChannel(s, filename, channels: [0], startFrame: rrand(400000, 600000), numFrames: rrand(1300000, 1500000), action: do_stretch);

	synth;
};
)
