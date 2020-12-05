(
Require("helpers/**", always: true);
Require("generators/**", always: true);
Require("effects/**", always: true);

~busR = Bus.audio(s, 2);
~busG = Bus.audio(s, 2);
~busL = Bus.audio(s, 2);

~reverb = Synth.new(\Reverb, [
	\mix, 1,
	\inBus, ~busR]);
~grain = Synth.new(\Grain, [
	\grainSize, rrand(0.3, 0.7),
	\pitchRatio, rrand(0.3, 4.0),
	\inBus, ~busG]);
~ladder = Synth.new(\Ladder, [
	\freq, 100,
	\res, 1.5,
	\inBus, ~busL]);

~crack = Synth.before(~grain, \Crack, [
	\chaos, rrand(0.5, 1.8),
	\effectBus, [~busR, ~busL],
	\direct, 0.5]);
~bosh = Synth.before(~grain, \Bosh, [
	\rate, rrand(0.3, 0.5),
	\effectBus, [~busG, ~busR],
	\direct, 0.5]);

~startScheduledRoutines = {
	~updateCrack = ~randomIntervalRoutine.value(10, 30, ~randomUpdaterFactory.value(~crack, \chaos, 0.9, 1.9));
	~updateGrain = ~randomIntervalRoutine.value(20, 50, ~randomUpdaterFactory.value(~grain, \pitchRatio, 0.3, 4.0));
	~updateLadder = ~randomIntervalRoutine.value(20, 50, ~randomUpdaterFactory.value(~ladder, \freq, 120, 200));
};
~stopScheduledRoutines = {
	~updateCrack.stop;
	~updateGrain.stop;
	~updateLadder.stop;
};

~window = Window.new(bounds:Rect(0,0,400,400));

Routine {
	~window
	.toFrontAction_(~startScheduledRoutines)
	.onClose_({
		~stopScheduledRoutines.value;
		s.freeAll;
	})
	.layout_(HLayout(
		~makeSlider.value("Bosh (direct)", ~bosh, \direct),
		~makeSlider.value("Crack (direct)", ~crack, \direct),
		~makeSlider.value("Grain (max time)", ~grain, \timeDispersion, min: 1, max: 8.0),
		~makeSlider.value("Grain (size)", ~grain, \grainSize, min: 0.2, max: 3)
	)).front;
}.play(AppClock)
)
