(
~makeSlider = { arg label, target, targetProperty, start = 0.5, step = 0.05, min = 0, max = 1.0;
	var layout = VLayout(
		StaticText().string_(label),
		Slider()
		.value_(LinLin.ar(start, min, max, 0.0, 1.0))
	    .step_(step)
		.action_({ |sl|
			target.set(targetProperty, LinLin.ar(sl.value, dstlo: min, dsthi: max));
		}),
	);
	layout;
};
)