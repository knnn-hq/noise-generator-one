(
~randomIntervalRoutine = { arg minDelay = 5.0, maxDelay = 10.0, fun;
	var routine = Routine({
		var delta;
		loop {
			delta = rrand(minDelay, maxDelay);
			fun.value;
			delta.yield;
		}
	});

	TempoClock.default.sched(0, routine);
};
)