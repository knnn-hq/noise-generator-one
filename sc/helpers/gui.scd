(
//// GUI helper:
~gh_win = nil;
~gh_logview = nil;

~gh_mkWindow = { | title |
	var scope;
	~gh_win = Window.new(title, 800 @ 600, scroll: true).front;
	~gh_win.view.decorator = FlowLayout(~gh_win.view.bounds, 15@15, 15@15);
    ~gh_win.view.palette = QPalette.dark;

	scope = FreqScopeView(~gh_win, (~gh_win.view.bounds.width - 30) @ (~gh_win.view.bounds.height / 4));
	scope.inBus_(0);
	scope.freqMode_(1);
	scope.active_(true);

	~gh_logview = TextView(~gh_win, (~gh_win.view.bounds.width - 30) @ (~gh_win.view.bounds.height / 6));
	~gh_logview.editable_(false);

	~gh_win.onClose = {
		scope.kill;
		s.freeAll;
		thisProcess.stop;
	};

	~gh_win;
};
~gh_log = { arg ...items;
	var text = Date.getDate.format("[%Y-%m-%d %H:%M:%S]");
	items.do({ |item, i| text = text ++ (if(i > 0,{" , "},{": "})) ++ item; });
	Routine({~gh_logview.setString(text ++ "\n", 0, 0)}).play(AppClock);
};
~gh_mkNum = { arg synth, name, prop = \level, initVal = 1.0, min = 0, max = 1.0, step = 0.05;
	Routine({
		var ezn;
		var width = ~gh_win.view.bounds.width * 0.9;
		var height = 20;

		~gh_win.view.decorator.nextLine;

		ezn = EZNumber(~gh_win,
			width @ height, name ++ " " ++ prop ++ " ",
			ControlSpec(min, max, \lin, step: step),
			{ |ez| synth.set(prop, ez.value) },
			initVal,
			labelWidth: width * 0.6,
			numberWidth: width * 0.3
		);
		ezn.setColors(
			numBackground: QPalette.dark.baseText,
			numNormalColor: QPalette.dark.base,
			numTypingColor: Color.fromHexString("00AFFE")
		);
	}).play(AppClock);
};
)