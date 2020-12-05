(
SynthDef.new(\Crack, { arg chaos = 1.2, outBus = 0, effectBus, direct = 0.5;
	var crack = Crackle.ar(chaos);
	Out.ar(effectBus, crack * (1 - direct));
	Out.ar(outBus, crack * direct);
}).add;

SynthDef.new(\Tish, { arg rate = 2, outBus = 0, effectBus, direct = 0.2;
	var trg = Decay2.ar(Impulse.ar(rate,0,0.3), 0.5, 1);
	var osc = {GrayNoise.ar(trg)}.dup;
	Out.ar(effectBus, osc * (1 - direct));
	Out.ar(outBus, osc * direct);
}).add;

SynthDef.new(\Grain, { arg grainSize = 0.5, pitchRatio = 0.3, outBus = 0, inBus;
	var input = In.ar(inBus, 2);
	var shift = PitchShift.ar(input, grainSize, pitchRatio, 2, 2.5 * grainSize);

	Out.ar(outBus, shift);
}).add;

SynthDef(\Reverb, { arg outBus = 0, inBus, mix = 0.5, room = 1, damp = 0.1;
	var input = In.ar(inBus, 2);
	var reverb = FreeVerb2.ar(input[0], input[1], mix, room, damp);

	Out.ar(outBus, input);
}).add;

~busR = Bus.audio(s, 2);
~busG = Bus.audio(s, 2);
)

(
~reverb = Synth.new(\Reverb, [\mix, 1, \inBus, ~busR]);
~grain = Synth.new(\Grain, [\grainSize, rrand(0.3, 0.7), \pitchRatio, rrand(0.3, 4.0), \inBus, ~busG]);
~crack = Synth.before(~grain, \Crack, [\chaos, rrand(0.5, 1.8), \effectBus, [~busG, ~busR], \direct, 0.5]);
~tish = Synth.before(~grain, \Tish, [\rate, rrand(0.3, 0.5), \effectBus, [~busG, ~busR],  \direct, 0.5]);

~updateCrack = Routine({
	var delta;
	loop {
		delta = rrand(10, 30);
		~crack.set(\chaos, rrand(0.9, 1.9));
		delta.yield;
	}
});
~updateTish = Routine({
	var d;
	loop {
		d = rrand(20, 40);
		~grain.set(\pitchRatio, rrand(0.3, 4.0));
		d.yield;
	}
});
TempoClock.default.sched(0, ~updateCrack);
TempoClock.default.sched(0, ~updateTish);
)

(
~window = Window.new(bounds:Rect(0,0,200,200));

Routine {
	~window
	.onClose_({
		~crack.free; ~tish.free;
		~reverb.free; ~grain.free;
		~busG.free; ~busR.free;
		s.freeAll;
	})
	.layout_(HLayout(
		VLayout(
			StaticText().string_("Crack"),
			Slider()
			.value_(0.5)
			.step_(0.05)
			.action_({ |sl|
				~crack.set(\direct, sl.value);
			}),
		), VLayout(
			StaticText().string_("Bosh"),
			Slider()
			.value_(0.5)
			.step_(0.05)
			.action_({ |sl|
				~tish.set(\direct, sl.value);
			})
		)
	)).front;
}.play(AppClock)
)
