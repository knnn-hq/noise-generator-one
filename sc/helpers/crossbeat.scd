(
~lcmarr = { arg arr;
	arr.collect(_.asInt).reduce({ |prev, curr|
		((curr * prev) / gcd(prev, curr)).asInt;
	});
};
~crossbeat = { arg basenote = 8, beats = [3, 2], rest = true;
	var notelen = 1 / basenote;
	var barlen = ~lcmarr.(beats); // ~lcmarr.([3, 2]) => 6

	beats.collect({ | beat |
		var beatlen = (1 / beat) * notelen;
		var numcells = (barlen / beat).asInt;
		var cell = if (rest, {
			[ beatlen ] ++ (Rest(beatlen) ! (beat - 1));
		}, { [beatlen * beat] });
		(cell ! (numcells)).flatten;
	});
};

~beattotune = { arg crossbeat, notes = [45, 48, 50, 52, 54, 58];
	crossbeat.do(_.do(notes.rand));
};

~crosstune = { arg basenote = 8, beats = [3, 2], notes = [45, 48, 50, 52, 54, 58], bars = 1;
	~beattotune.(~crossbeat.(basenote, beats, false, bars));
};
)