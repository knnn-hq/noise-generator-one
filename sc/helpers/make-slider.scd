(
~makeSlider = { arg label, target, targetProperty, start = 0.5, step = 0.01, min = 0, max = 1.0;
	var spec = ControlSpec(min, max, step: step);
	var update = { arg newValue;  target.set(targetProperty, newValue); };
	var layout = VLayout(
		StaticText().string_(label),
		Slider()
		.action_({ |sl|
			update.value(spec.map(sl.value));
		})
		.step_(step)
		.value_(spec.unmap(start))
	);
	update.value(start);
	layout;
};
)