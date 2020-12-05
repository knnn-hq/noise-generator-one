(
~updaterFactory = { arg target, property;
	var updater = { arg newValue;
		target.set(property, newValue);
	};

	updater;
};
~randomUpdaterFactory = { arg target, property, randMin = 0.0, randMax = 1.0;
	var updater = ~updaterFactory.value(target, property);
	var randomUpdater = { updater.value(rrand(randMin, randMax)); };

	randomUpdater;
};
)