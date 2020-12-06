(
Require("helpers/**", always: true);
Require("generators/**", always: true);
Require("effects/**", always: true);

~busR = Bus.audio(s, 2);
~busG = Bus.audio(s, 2);
~busD = Bus.audio(s, 2);

~grain = Synth.new(\Grain, [
	\grainSize, 0.666,
	\pitchRatio, 3.2,
	\inBus, ~busG]);

~reverb = Synth.new(\Reverb, [
	\roomSize, 15,
	\time, 5.0,
	\inBus, ~busR]);

~delay = Synth.new(\Greyish, [
	\feedback, 0.666,
	\diffusion, 0.5,
	\inBus, ~busD]);

~atari = Synth.before(~delay, \Atari, [
	\level, 0.5,
	\direct, 0.1,
	\effectBus, [~busD, ~busG]
]);

~bosh = Synth.before(~grain, \Bosh, [
	\rate, 0.2,
	\effectBus, [~busG, ~busR],
	\level, 0.4,
	\direct, 0.5]);

~crack = Synth.before(~reverb, \Crack, [
	\level, 0.5,
	\chaos, 1.8,
	\effectBus, [~busR, ~busG],
	\direct, 0.5]);


Routine {
	Window()
	.alwaysOnTop_(true)
	.onClose_({ s.freeAll })
	.layout_(VLayout(
		VLayout(
			StaticText().string_("Generators"),
			HLayout(
				VLayout(
					StaticText().string_("Atari"),
					HLayout(
						~makeSlider.value("gain", ~atari, \level, start: 0.5),
						~makeSlider.value("dry", ~atari, \direct, start: 0.1)
					)
				),
				20,
				VLayout(
					StaticText().string_("Bosh"),
					HLayout(
						~makeSlider.value("gain", ~bosh, \level, start: 0.4),
						~makeSlider.value("dry", ~bosh, \direct),
						~makeSlider.value("rate", ~bosh, \rate, start: 0.2, min: 0.1, max: 10),
					)
				),
				20,
				VLayout(
					StaticText().string_("Crack"),
					HLayout(
						~makeSlider.value("gain", ~crack, \level, start: 0.5),
						~makeSlider.value("dry", ~crack, \direct),
						~makeSlider.value("chaos", ~crack, \chaos, start: 1.8, min: 0.0, max: 2.0),
					)
				),

			),
		),
		20,
		VLayout(
			StaticText().string_("Effects"),
			HLayout(
				VLayout(
					StaticText().string_("Grain"),
					HLayout(
						~makeSlider.value("max time", ~grain, \timeDispersion, min: 1, max: 8.0),
						~makeSlider.value("grain size", ~grain, \grainSize, min: 0.2, max: 3)
					)
				),
				20,
				VLayout(
					StaticText().string_("Reverb"),
					HLayout(
						~makeSlider.value("delay", ~reverb, \time, start: 5, min: 0, max: 30),
						~makeSlider.value("head level", ~reverb, \head, start: 0.85),
						~makeSlider.value("tail level", ~reverb, \tail),
					)
				),
				20,
				VLayout(
					StaticText().string_("Delay"),
					HLayout(
						~makeSlider.value("delay", ~delay, \delayTime, start: 5.0, min: 0.1, max: 60),
						~makeSlider.value("diffusion", ~delay, \diffusion),
						~makeSlider.value("feedback", ~delay, \feedback, start: 0.666),
						~makeSlider.value("size", ~delay, \size, start: 0.666, min: 0.5, max: 5),
					)
				)

			)
		)
	)).front;
}.play(AppClock)
)
