class Interpol {
	1 => static int LINEAR;
	2 => static int LAGRANGE;
	4 => static int CUBIC;
	8 => static int HERMITE;

	fun static float linear(float y1, float y2, float mu) {
   		return y1 * (1.0 - mu) + y2 * mu;
	}

	fun static float cubic(float y0, float y1, float y2, float y3, float mu) {
        mu * mu => float mu2;
        -0.5*y0 + 1.5*y1 - 1.5*y2 + 0.5*y3 => float a0;
        y0 - 2.5*y1 + 2*y2 - 0.5*y3 => float a1;
        -0.5*y0 + 0.5*y2 => float a2;
        y1 => float a3;

        return a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3;
	}

	fun static float lagrange(float y0, float y1, float y2, float y3, float mu) {
        return (y1 + mu * (
            (y2 - y1) - 0.1666667 * (1.-mu) * (
                (y3 - y0 - 3.0 * (y2 - y1)) * mu + (y3 + 2.0 * y0 - 3.0 * y1))));
	}

	fun static float hermite(float y0, float y1, float y2, float y3, float mu) {
        mu * mu => float mu2;
        mu2 * mu => float mu3;
        (y1-y0)/2 => float m0;
        (y2-y1)/2 +=> m0;
        (y2-y1)/2 => float m1;
        (y3-y2)/2 +=> m1;
        2 * mu3 - 3 * mu2 + 1 => float a0;
        mu3 - 2 * mu2 + mu => float a1;
        mu3 -   mu2 => float a2;
        -2 * mu3 + 3 * mu2 => float a3;

        return a0 * y1 + a1 * m0 + a2 * m1 + a3 * y2;
	}

	fun static float interpolate(int mode, float y0, float y1, float y2, float y3, float mu) {
		if (mode == LINEAR) {
			return linear(y0, y1, mu);
		} else if (mode == LAGRANGE) {
			return lagrange(y0, y1, y2, y3, mu);
		} else if (mode == CUBIC) {
			return cubic(y0, y1, y2, y3, mu);
		} else if (mode == HERMITE) {
			return hermite(y0, y1, y2, y3, mu);
		}
		return y0;
	}
}

class WaveTablePlayer extends Chugen {
	float _table[0];
	float _table_pos;
	0 => int count;
	int sync;
	int interp;
	float phase;
	float _freq;
	float _actualFreq;

	{
		false => sync;
		1     => interp;
		0.0   => phase 
			  => _table_pos;
		0 => _actualFreq => _freq;
	}

	fun float freq(float freq) {
		freq => _freq;
		return _freq;
	}
	fun float freq() { return _freq; }

	fun void setTable(float table[]) {
		table @=> _table;
	}

	fun float tick(float in) {
		(second/samp) => float sampleRate;
		_table.size() => int   table_size;

		if (_freq != _actualFreq) {
			_freq - _actualFreq => float freqDiff;
			if (Std.fabs(freqDiff) < 0.5) {
				_freq => _actualFreq;
				0 => count;
			} else if (count % 4 == 0){
				_actualFreq + freqDiff / 100.0 => _actualFreq;
			}
			count++;
		}
		Std.rand2f(0, 0.005) => phase;

		if (table_size <= 1) {
			return 0.0;
		}

		table_size * _actualFreq / sampleRate => float step;

		if (!sync) {
        	if (in > 0) {
          		table_size * in / sampleRate => step;
			}
        	step +=> _table_pos;
		} else {
			table_size * in => _table_pos;
		}
		phase +=> _table_pos;
        while (_table_pos >= table_size) {
			table_size -=> _table_pos;
		}
        _table_pos $ int => int intpos;
		_table[intpos] => float y0;
        _table[(intpos + 1) % table_size] => float y1;
        _table[(intpos + 2) % table_size] => float y2;
        _table[(intpos + 3) % table_size] => float y3;
		_table_pos - y0 => float mu;

		return (gain() * Interpol.interpolate(interp, y0, y1, y2, y3, mu));
	}
}

fun float[] createTable(int useSine, int bias) {
	// Wavetables from <https://gist.github.com/matthewSorensen/1288734>
	int sourcetable[];
	if (useSine) {
		[127,130,133,136,139,143,146,149,152,155,158,161,164,167,170,173,
		176,179,182,184,187,190,193,195,198,200,203,205,208,210,213,215,
		217,219,221,224,226,228,229,231,233,235,236,238,239,241,242,244,
		245,246,247,248,249,250,251,251,252,253,253,254,254,254,254,254,
		255,254,254,254,254,254,253,253,252,251,251,250,249,248,247,246,
		245,244,242,241,239,238,236,235,233,231,229,228,226,224,221,219,
		217,215,213,210,208,205,203,200,198,195,193,190,187,184,182,179,
		176,173,170,167,164,161,158,155,152,149,146,143,139,136,133,130,
		127,124,121,118,115,111,108,105,102,99,96,93,90,87,84,81,
		78,75,72,70,67,64,61,59,56,54,51,49,46,44,41,39,
		37,35,33,30,28,26,25,23,21,19,18,16,15,13,12,10,
		9,8,7,6,5,4,3,3,2,1,1,0,0,0,0,0,
		0,0,0,0,0,0,1,1,2,3,3,4,5,6,7,8,
		9,10,12,13,15,16,18,19,21,23,25,26,28,30,33,35,
		37,39,41,44,46,49,51,54,56,59,61,64,67,70,72,75,
		78,81,84,87,90,93,96,99,102,105,108,111,115,118,121,124] @=> sourcetable;
	} else {
		[127,134,141,148,155,162,169,176,183,189,195,201,207,212,
		217,222,227,231,234,238,241,244,246,248,250,251,252,253,
		253,254,253,253,252,251,250,248,246,244,242,240,238,235,
		233,230,227,225,222,219,216,214,211,208,206,203,201,199,
		196,194,192,190,189,187,185,184,183,181,180,179,178,178,
		177,176,176,175,175,174,174,174,173,173,173,173,172,172,
		172,171,171,171,170,170,169,169,168,168,167,166,166,165,
		164,163,162,161,160,159,158,157,156,155,153,152,151,150,
		148,147,146,144,143,142,140,139,137,136,135,133,132,131,
		129,128,127,125,124,122,121,120,118,117,116,114,113,111,
		110,109,107,106,105,103,102,101,100,98,97,96,95,94,93,92,
		91,90,89,88,87,87,86,85,85,84,84,83,83,82,82,82,81,81,81,
		80,80,80,80,79,79,79,78,78,77,77,76,75,75,74,73,72,70,69,
		68,66,64,63,61,59,57,54,52,50,47,45,42,39,37,34,31,28,26,
		23,20,18,15,13,11,9,7,5,3,2,1,0,0,0,0,0,1,2,3,5,7,9,12,15,
		19,22,26,31,36,41,46,52,58,64,70,77,84,91,98,105,112,119] @=> sourcetable;
	}
	float wavetable[sourcetable.size()];
	for (0 => int i; i < sourcetable.size(); i++) {
		sourcetable[i] $ float => float value;
		if (bias != 0.0) {
			bias +=> value;
			while (value > 255) {
				255.0 -=> value;
			}
			while (value < 0) {
				255.0 +=> value;
			}
		}
		value / 255.0 => wavetable[i];
	}
	return wavetable;
}
fun float[] createTable(int useSine) {
	return createTable(useSine, 0);
}

public class Ondes extends Chubgraph {
	LPF lpfMain  
		=> Envelope envMain  
		=> JCRev rev 
			=> LPF lpfMaster
			=> HPF hpfMaster
			=> Gain master
			=> outlet;
	
	LPF lpfExtra 
		=> envMain;

	WaveTablePlayer players[0];

	int   _sync;
	float _freq;
	float _gain;

	{
		0.5 => master.gain;
		4500 => lpfMaster.freq;
		400 => hpfMaster.freq;
		3500 => lpfMain.freq;
		3000 => lpfExtra.freq;
		0.7 => lpfExtra.gain;
		0.4 => rev.mix;
	}

	fun void noteOn(float noteFreq) {
		noteFreq => freq;
		75::ms => envMain.duration;
		1 => envMain.keyOn;
		100::ms => now;
		300::ms => envMain.duration;
		1 => envMain.keyOff;
	}

	fun void noteOn(int note) {
		noteOn(Std.mtof(note));
	}

	fun void initVoices(int numVoices) {
		WaveTablePlayer newPlayers[numVoices];
		createTable(false) @=> float ondtable[];
		createTable(true) @=> float sintable[];
		numVoices / 2 $ int => int half; 

		for (0 => int i; i < half; i++) {
			inlet => WaveTablePlayer ondPlayer => lpfMain;
			inlet => WaveTablePlayer sinPlayer => lpfExtra;

			ondPlayer.setTable(ondtable);
			sinPlayer.setTable(sintable);
			Interpol.LAGRANGE => ondPlayer.interp;
			Interpol.CUBIC  => sinPlayer.interp;

			1 / (i + 1) => ondPlayer.gain;
			1 / (i + 2) => sinPlayer.gain;

			ondPlayer @=> newPlayers[i];
			sinPlayer @=> newPlayers[i + half];
		}
		newPlayers @=> players;
	}

	fun int sync() { return _sync; }
	fun int sync(int sync) {
		sync => _sync;
		for (0 => int i; i < players.size(); i++) {
			_sync => players[i].sync;

		}
		return _sync;
	}

	fun float freq() { return _freq; }
	fun float freq(float freq) {
		freq => _freq;
		while (_freq < 50.0) {
			2 *=> _freq;
		}
		players.size() / 2 $ int => int half;
		for (0 => int i; i < half; i++) {
			_freq + (_freq * i + (0.0001 * i)) => players[i].freq;
			_freq + (_freq * (i + 1) + (0.01 * (i + 1))) => players[i + half].freq;
		}
		
		return _freq;
	}

	fun float gain() { return _gain; }
	fun float gain(float gain) {
		gain => _gain => master.gain;
		return _gain;
	}

}
