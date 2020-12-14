(
//// Mathy stuff:
~sr = { |n| n.softRound(0.01, 0) }; // round
~rr = { |min, max| ~sr.(rrand(min, max)) }; // rounded random - min < r < max

~r  = ~rr.(0, _); // rounded random - 0 < r < max
~r1 = ~r.(1.0); // rounded random - 0 < r < 1.0

~q = { |c, t, f| if(c,{t},{f})}; // ternary operator :D

~lim = { |n, min, max, vmin, vmax|
	~q.((n > min) and: (n < max),
		n,
		~q.((n >= max), vmax, vmin)
	);
};

//// Routing:
~outWithSidechain = { arg snd, out = 0, fx = 0, amp = 1.0, pan = 0, dry = 0;
	snd = Pan2.ar(snd, pan, amp);

	Out.ar(fx, snd * (1 - dry));
	Out.ar(out, snd * dry);
};

)