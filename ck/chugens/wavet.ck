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


public class WaveT extends Chugen {
	//#region Table
	float _table[];
	float _table_pos;
	int   _table_size;
	//#endregion

	//#region Sample rate
	float _sampleRate;
	float _sampleRateRatio;
	//#endregion

	//#region Backing props
	float _goalFreq;
	float _currFreq;
	float _phase;
	int   _sync;
	int _interp;
	int _crush;
	int _ledFilter;
	//#endregion

	//#region "Buffer"
	0.0 => float _lastIn;
	0.0 => float _nextOut;
	//#endregion

	//#region Init
	{
		Interpol.LINEAR 
				=> interpolation;
		28837.0 => sampleRate;
		false   => sync;
		0       => _table_size;
		110.0   => _currFreq;
		220.0   => freq;
		7       => crush;
		true    => ledFilter;

		spork ~ _generate();
		spork ~ _glide();
	}
	//#endregion


	//#region Public methods/props
	fun void loadTable(float table[]) {
		table @=> _table;
		_table.size() => _table_size;
	}

	fun int crush() { return _crush; }
	fun int crush(int crush) {
		crush => _crush;
		return _crush;
	}


	fun float freq() { return _goalFreq; }
	fun float freq(float freq) {
		freq => _goalFreq;
		return _goalFreq;
	}

	fun int interpolation() { return _interp; }
	fun int interpolation(int interp) {
		interp => _interp;
		return _interp;
	}
	
	fun int ledFilter() { return _ledFilter; }
	fun int ledFilter(int led_ledFilter) {
		led_ledFilter => _ledFilter;
		return _ledFilter;
	}

	fun float phase() { return _phase; }
	fun float phase(float phase) {
		phase => _phase;
		return _phase;
	}

	fun float sampleRate() { return _sampleRate; }
	fun float sampleRate(float sampleRate) {
		sampleRate => _sampleRate;
		(second/samp)/_sampleRate => _sampleRateRatio; 
		return _sampleRate;
	}

	fun int sync() { return _sync; }
	fun int sync(int sync) {
		sync => _sync;
		return _sync;
	}
	//#endregion

	//#region Filter
	float fs_rc1; // Filter state
	float fs_rc2;
	float fs_rc3;
	float fs_rc4;
	float fs_rc5;
	float denormal_offset;
	float a500e_filter1_a0;
    float a500e_filter2_a0;
    float filter_a0;

	fun float _apply_paula_filters(float in) {
		if (denormal_offset < 0.000001) {
			0.000001 => denormal_offset;
			_rc_calculate_a0(6200.0)  => a500e_filter1_a0;
			_rc_calculate_a0(20000.0) => a500e_filter2_a0;
			_rc_calculate_a0(7000)    => filter_a0;
		}
		
		Math.floor(in * 32768.0) => float input; // approx. int16

		a500e_filter1_a0 * input + (1 - a500e_filter1_a0) * fs_rc1 + denormal_offset 
			=> fs_rc1;
		a500e_filter2_a0 * fs_rc1 + (1-a500e_filter2_a0) * fs_rc2 
			=> fs_rc2;

		if (!_ledFilter) {
			return Math.floor(fs_rc2 / 32768.0);
		}

		filter_a0 * fs_rc2 + (1 - filter_a0) * fs_rc3
			=> fs_rc3;
		filter_a0 * fs_rc3       + (1 - filter_a0) * fs_rc4
			=> fs_rc4;
		filter_a0 * fs_rc4       + (1 - filter_a0) * fs_rc5 
			=> fs_rc5;
			
		return Math.floor(fs_rc5 / 32768.0);
	}

	fun float _rc_calculate_a0(float cutoff_freq) {
    /* The BLT correction formula below blows up if the cutoff is above nyquist. */
    	if (cutoff_freq >= _sampleRate / 2) {
        	return 1.0;
		} else {
    		2 * pi * cutoff_freq / _sampleRate => float omega;
			/* Compensate for the bilinear transformation. This allows us to specify the
			* stop frequency more exactly, but the filter becomes less steep further
			* from stopband. */
    		Math.tan(omega / 2) * 2 => omega;
    		return 1 / (1 + 1/omega);
		}

	}
	//#endregion

	//#region "Tick"
	fun float tick(float in) {
		in => _lastIn;
		return _nextOut;
	}
	//#endregion

	//#region Workers
	fun void _generate() {
		while (true) {
			_sampleRateRatio::samp => now;

			if (_table_size <= 1) {
				continue;
			}

			_table_size * _currFreq / _sampleRate => float step;

			if (!_sync) {
				if (_lastIn > 0) {
					_table_size * _lastIn / _sampleRate => step;
				}
				step +=> _table_pos;
			} else {
				_table_size * _lastIn => _table_pos;
			}
			_phase +=> _table_pos;
			while (_table_pos >= _table_size) {
				_table_size -=> _table_pos;
			}
			_table_pos $ int => int intpos;
			_table[intpos] => float y0;
			_table[(intpos + 1) % _table_size] => float y1;
			_table[(intpos + 2) % _table_size] => float y2;
			_table[(intpos + 3) % _table_size] => float y3;
			_table_pos - y0 => float mu;

			Interpol.interpolate(_interp, y0, y1, y2, y3, mu) * 0.9 => float result;
			if (_crush > 0) {
				(Math.pow(2, _crush) / 2.0) $ int => int peak;
				Math.floor(result * peak) / peak $ float => result;
			}
			_apply_paula_filters(result) => _nextOut;
		}
	}

	fun void _glide() {
		0 => int ticks;

		while (true) {
			if (_table_size > 0 && _goalFreq != _currFreq) {
				_goalFreq - _currFreq => float freqDiff;
				if (Std.fabs(freqDiff) < 0.5) {
					_goalFreq => _currFreq;
					0 => ticks;
				} else if (ticks % 4 == 0){
					_currFreq + freqDiff / 100.0 => _currFreq;
				}
				ticks++;
			}
			_sampleRateRatio::samp => now;
		}
	}
	//#endregion

	//#region ctor
	fun static WaveT create(float table[]) {
		WaveT w;
		w.loadTable(table);

		return w;
	}

	fun static WaveT create(int table[], int minValue, int maxValue) {
		Std.abs(minValue) $ float => float absMin;
		float wavetable[table.size()];

		for (0 => int i; i < table.size(); i++) {
			if (table[i] == 0) {
				0 => wavetable[i];
			} else if (minValue < 0) {
				if (table[i] < 0) {
					table[i] / absMin => wavetable[i];
				} else {
					table[i] / (maxValue $ float) => wavetable[i];
				}
			} else {
				(table[i] - minValue $ float) / (maxValue - minValue) => wavetable[i];
			}
		}

		WaveT w;
		w.loadTable(wavetable);

		return w;
	}

	fun static WaveT create(int table[]) {
		table[0] => int min => int max;

		for (1 => int i; i < table.size(); i++) {
			if (table[i] < min) {
				table[i] => min;
			} else if(table[i] > max) {
				table[i] => max;
			}
		}
		return create(table, min, max);
	}

	fun static WaveT create_int16(int table[]) {
		return create(table, -32768, 32767);
	}

	fun static WaveT create_int8(int table[]) {
		return create(table, -128, 127);
	}

	fun static WaveT create_uint8(int table[]) {
		return create(table, 0, 255);
	}

	fun static WaveT create_c64_A() {
		[
			16099, 31291, 25609, 29372, 26470, 28855, 26834, 28573, 27069, 28369, 27249, 28206, 27400, 28069, 27526, 27953, 27632, 27857, 27717, 27782, 27783, 27724, 27832, 27685, 27863, 27661, 27880, 27650, 27885,
			27652, 27879, 27661, 27867, 27675, 27850, 27694, 27832, 27713, 27812, 27731, 27795, 27748, 27779, 27761, 27767, 27772, 27758, 27778, 27752,
			27783, 27749, 27785, 27750, 27784, 27750, 27782, 27753, 27780, 27756, 27777, 27758, 27774, 27761, 27772, 27764, 27769, 27765, 27768, 27767,
			27767, 27768, 27767, 27769, 27765, 27769, 27765, 27768, 27766, 27768, 27767, 27768, 27767, 27767, 27767, 27767, 27767, 27767, 27767, 27767,
			27767, 27767, 27767, 27766, 27766, 27768, 27767, 27767, 27767, 27768, 27766, 27767, 27766, 27768, 27766, 27768, 27766, 27768, 27766, 27769,
			27765, 27768, 27765, 27768, 27765, 27769, 27765, 27768, 27767, 27767, 27767, 27766, 27769, 27764, 27772, 27761, 27774, 27757, 27779, 27753,
			27784, 27750, 27786, 27745, 27789, 27744, 27791, 27744, 27790, 27746, 27786, 27751, 27779, 27761, 27766, 27775, 27751, 27792, 27732, 27813,
			27708, 27837, 27686, 27861, 27661, 27884, 27640, 27903, 27625, 27913, 27618, 27914, 27624, 27901, 27646, 27870, 27685, 27820, 27748, 27746,
			27836, 27643, 27951, 27512, 28101, 27345, 28293, 27123, 28550, 26815, 28934, 26306, 29673, 25059, 32468, 10106,-31908,-26244,-29134,-27456,
			-28439,-27911,-28118,-28147,-27941,-28280,-27839,-28355,-27789,-28387, -27774,-28386,-27785,-28364,-27818,-28326,-27863,-28277,-27916,-28221,
			-27972,-28166,-28028,-28112,-28078,-28065,-28121,-28027,-28155,-27999, -28176,-27984,-28183,-27983,-28178,-27995,-28160,-28021,-28127,-28060,
			-28083,-28109,-28029,-28165,-27967,-28229,-27902,-28296,-27837,-28358, -27776,-28415,-27727,-28457,-27693,-28478,-27684,-28473,-27709,-28424, -27789,-28305,-27960,-28052,-28350,-27402,-29468, 16099
		] @=> int wavetable[];
		return create_int16(wavetable);
	}

	fun static WaveT create_c64_B() {
		[
			   40,   317,   543,   757,  1007,  1327,  1740,  2243,  2820, 3435,  4060,  4667,  5239,  5774,  6282,  6775,  7266,  7763,  8271,
			8780,  9286,  9782, 10266, 10741, 11215, 11704, 12215, 12755, 13325, 13913, 14504, 15087, 15642, 16165, 16657, 17127, 17591, 18059, 18546,
			19054, 19577, 20105, 20624, 21124, 21604, 22065, 22525, 22999, 23503, 24045, 24618, 25213, 25809, 26386, 26932, 27444, 27933, 28417, 28911,
			29427, 29960, 30488, 30971, 31366, 31623, 31712, 31622, 31365, 30972, 30488, 29961, 29428, 28912, 28417, 27935, 27444, 26932, 26386, 25809,
			25215, 24620, 24045, 23505, 23002, 22525, 22066, 21603, 21126, 20624, 20105, 19578, 19054, 18546, 18059, 17591, 17128, 16659, 16166, 15643,
			15086, 14506, 13912, 13325, 12757, 12216, 11705, 11217, 10742, 10267, 9782,  9284,  8779,  8270,  7767,  7270,  6780,  6286,  5773,  5233,
			4656,  4052,  3435,  2832,  2269,  1772,  1347,   990,   677,   374, 50,  -323,  -755, -1240, -1758, -2286, -2806, -3308, -3794, -4281,
			-4787, -5325, -5896, -6495, -7097, -7682, -8231, -8735, -9201, -9646, -10089,-10554,-11054,-11592,-12162,-12748,-13340,-13922,-14487,-15028,
			-15543,-16033,-16502,-16959,-17417,-17895,-18407,-18963,-19561,-20176, -20780,-21333,-21805,-22186,-22492,-22769,-23077,-23470,-23983,-24612,
			-25319,-26032,-26681,-27213,-27614,-27925,-28220,-28586,-29097,-29771, -30572,-31400,-32122,-32610,-32768,-32572,-32063,-31344,-30542,-29779,
			-29134,-28634,-28250,-27918,-27569,-27141,-26613,-25999,-25338,-24682, -24073,-23536,-23068,-22650,-22252,-21850,-21424,-20970,-20491,-19994,
			-19483,-18957,-18413,-17846,-17256,-16648,-16034,-15425,-14836,-14272, -13735,-13221,-12720,-12228,-11743,-11258,-10773,-10282, -9780, -9257,
			-8706, -8129, -7533, -6933, -6351, -5808, -5310, -4852, -4417, -3980, -3515, -3004, -2449, -1869, -1296,  -769,  -317,    40
 		] @=> int wavetable[];
		return create_int16(wavetable);
	}

	fun static WaveT create_c64_C() {
		[ 10519, 30280, 23541, 27780, 24659, 27114, 25119, 26767, 25401, 26531, 25603, 26354, 25761, 26214, 25885, 26104, 25982, 26019, 26054,
			25958, 26104, 25917, 26137, 25895, 26152, 25886, 26154, 25889, 26146, 25902, 26130, 25920, 26111, 25941, 26088, 25963, 26068, 25983, 26047,
			26001, 26031, 26017, 26017, 26028, 26008, 26036, 26001, 26039, 25999, 26041, 25998, 26040, 26001, 26038, 26003, 26034, 26007, 26031, 26010,
			26028, 26013, 26025, 26016, 26023, 26019, 26021, 26019, 26020, 26021, 26019, 26022, 26019, 26022, 26018, 26022, 26018, 26021, 26019, 26021,
			26019, 26021, 26019, 26021, 26019, 26022, 26018, 26022, 26016, 26024, 26016, 26025, 26015, 26025, 26013, 26027, 26013, 26027, 26014, 26026,
			26014, 26024, 26018, 26021, 26023, 26015, 26029, 26008, 26037, 26000, 26044, 25990, 26054, 25980, 26064, 25973, 26071, 25966, 26077, 25963,
			26076, 25966, 26071, 25973, 26060, 25989, 26039, 26013, 26012, 26045, 25976, 26085, 25931, 26132, 25881, 26185, 25829, 26238, 25776, 26291,
			25726, 26335, 25688, 26366, 25664, 26380, 25664, 26364, 25699, 26305, 25786, 26177, 25973, 25907, 26390, 25195, 27778,-14582,-29500,-23900,
			-27589,-24762,-27070,-25126,-26788,-25359,-26588,-25535,-26428,-25681, -26295,-25803,-26185,-25903,-26094,-25983,-26022,-26046,-25969,-26090,
			-25933,-26118,-25912,-26134,-25903,-26136,-25906,-26132,-25915,-26118, -25929,-26102,-25947,-26085,-25966,-26066,-25982,-26048,-25999,-26033,
			-26015,-26018,-26028,-26005,-26041,-25995,-26050,-25985,-26059,-25978, -26066,-25972,-26072,-25966,-26075,-25963,-26077,-25965,-26075,-25968,
			-26069,-25977,-26054,-25993,-26036,-26014,-26013,-26044,-25979,-26080, -25941,-26121,-25898,-26164,-25852,-26210,-25809,-26253,-25769,-26288,
			-25739,-26310,-25726,-26314,-25733,-26290,-25773,-26231,-25857,-26117, -26011,-25910,-26293,-25508,-26909,-24430,-29359, 10519
 	] @=> int wavetable[];
		return create_int16(wavetable);
	}

	fun static WaveT create_c64_D() {
		[   1849, 17817, 28618, 32767, 30994, 26485, 22615, 21628, 23367,
 26202, 28042, 27909, 26185, 24290, 23499, 24210, 25737, 26944, 27043,
 26086, 24851, 24212, 24562, 25552, 26444, 26616, 26024, 25134, 24608,
 24769, 25461, 26145, 26350, 25962, 25308, 24862, 24928, 25413, 25949,
 26151, 25907, 25418, 25050, 25053, 25394, 25809, 25995, 25845, 25489,
 25196, 25165, 25397, 25705, 25866, 25780, 25533, 25312, 25270, 25416,
 25629, 25752, 25710, 25552, 25406, 25368, 25451, 25576, 25653, 25634,
 25554, 25481, 25464, 25499, 25544, 25564, 25550, 25536, 25540, 25557,
 25561, 25531, 25483, 25462, 25502, 25584, 25650, 25635, 25536, 25412,
 25366, 25447, 25613, 25742, 25726, 25560, 25351, 25260, 25374, 25626,
 25836, 25837, 25605, 25297, 25141, 25274, 25620, 25932, 25969, 25678,
 25251, 25005, 25143, 25591, 26035, 26135, 25785, 25216, 24844, 24966,
 25534, 26151, 26349, 25945, 25192, 24636, 24716, 25432, 26292, 26654,
 26194, 25181, 24336, 24325, 25247, 26497, 27151, 26629, 25189, 23819,
 23598, 24869, 26881, 28181, 27612, 25238, 22541, 21606, 23700, 28121,
 32125, 32127, 25619, 12697, -3682,-18976,-29176,-32610,-30510,-26062,
-22585,-21897,-23724,-26342,-27906,-27606,-25972,-24311,-23736,-24466,
-25821,-26795,-26779,-25912,-24896,-24443,-24799,-25619,-26285,-26355,
-25850,-25187,-24842,-25015,-25528,-25983,-26075,-25783,-25358,-25111,
-25188,-25493,-25781,-25857,-25702,-25462,-25315,-25347,-25496,-25635,
-25670,-25605,-25519,-25484,-25504,-25533,-25527,-25494,-25489,-25543,
-25631,-25671,-25602,-25446,-25321,-25341,-25530,-25765,-25862,-25711,
-25393,-25132,-25152,-25477,-25897,-26093,-25878,-25363,-24913,-24892,
-25368,-26043,-26404,-26138,-25361,-24624,-24490,-25168,-26217,-26897,
-26590,-25420,-24138,-23765,-24722,-26526,-27876,-27631,-25601,-23008,
-21788,-23364,-27417,-31535,-32290,-26812,-14876,  1849
	] @=> int wavetable[];
		return create_int16(wavetable);
	}
	fun static WaveT create_c64_E() {
		[  6059, 20588, 28765, 32451, 32328, 30638, 28148, 26262, 25023,
 24441, 24329, 24739, 24954, 25296, 25448, 25648, 25540, 25622, 25555,
 25609, 25303, 25277, 25278, 25275, 25285, 25259, 25506, 25605, 25576,
 25594, 25575, 25607, 25410, 25242, 25302, 25257, 25299, 25253, 25526,
 25599, 25578, 25595, 25572, 25610, 25385, 25252, 25291, 25268, 25283,
 25274, 25280, 25276, 25279, 25277, 25276, 25277, 25276, 25278, 25276,
 25278, 25275, 25279, 25275, 25279, 25276, 25278, 25275, 25278, 25276,
 25278, 25277, 25278, 25277, 25277, 25277, 25276, 25276, 25277, 25277,
 25277, 25277, 25277, 25277, 25277, 25277, 25277, 25276, 25277, 25277,
 25277, 25277, 25277, 25276, 25276, 25278, 25277, 25277, 25277, 25277,
 25276, 25277, 25277, 25278, 25277, 25277, 25277, 25277, 25277, 25277,
 25277, 25276, 25277, 25276, 25277, 25278, 25276, 25277, 25277, 25277,
 25276, 25278, 25276, 25278, 25276, 25278, 25275, 25278, 25276, 25278,
 25277, 25278, 25276, 25277, 25276, 25277, 25278, 25277, 25278, 25276,
 25279, 25276, 25281, 25274, 25281, 25274, 25282, 25274, 25283, 25273,
 25283, 25273, 25284, 25273, 25282, 25274, 25281, 25275, 25279, 25276,
 25276, 25279, 25273, 25283, 25270, 25288, 25265, 25295, 25259, 25301,
 25252, 25307, 25243, 25317, 25232, 25333, 25211, 25366, 25146, 25549,
 22265,  8884, -6985,-20228,-28745,-32270,-32492,-30813,-28422,-26374,
-25121,-24434,-24365,-24573,-24934,-25180,-25536,-25586,-25588,-25584,
-25581,-25603,-25406,-25243,-25299,-25262,-25293,-25260,-25327,-25587,
-25583,-25588,-25583,-25589,-25571,-25302,-25271,-25281,-25275,-25280,
-25274,-25521,-25609,-25567,-25604,-25562,-25618,-25366,-25261,-25284,
-25274,-25280,-25275,-25280,-25272,-25284,-25269,-25289,-25263,-25296,
-25255,-25304,-25248,-25311,-25239,-25318,-25235,-25321,-25241,-25194,
-24866,-25065,-24872,-25070,-24876,-24672,-15335,  6059
 	] @=> int wavetable[];
		return create_int16(wavetable);
	}
	fun static WaveT create_c64_F() {
		[1555, 31381, 22354, 27449, 24045, 26493, 24668, 26051, 25002,
 25789, 25212, 25617, 25357, 25495, 25459, 25411, 25529, 25352, 25575,
 25318, 25600, 25301, 25609, 25301, 25605, 25309, 25592, 25326, 25571,
 25350, 25546, 25375, 25521, 25400, 25496, 25424, 25475, 25443, 25456,
 25460, 25443, 25472, 25431, 25479, 25427, 25482, 25424, 25482, 25426,
 25481, 25429, 25477, 25433, 25472, 25438, 25466, 25442, 25462, 25447,
 25459, 25451, 25455, 25453, 25454, 25456, 25451, 25456, 25451, 25457,
 25451, 25457, 25452, 25457, 25450, 25457, 25451, 25455, 25453, 25455,
 25453, 25455, 25453, 25454, 25454, 25453, 25454, 25454, 25454, 25453,
 25454, 25453, 25454, 25453, 25454, 25454, 25454, 25455, 25454, 25455,
 25453, 25454, 25454, 25455, 25454, 25454, 25454, 25453, 25454, 25455,
 25453, 25453, 25454, 25453, 25454, 25454, 25454, 25454, 25454, 25454,
 25454, 25455, 25454, 25454, 25454, 25455, 25453, 25454, 25454, 25454,
 25455, 25454, 25453, 25453, 25453, 25454, 25454, 25454, 25455, 25454,
 25455, 25454, 25454, 25453, 25454, 25454, 25454, 25454, 25453, 25454,
 25453, 25454, 25455, 25454, 25454, 25454, 25454, 25454, 25455, 25452,
 25454, 25452, 25455, 25452, 25456, 25451, 25456, 25453, 25456, 25453,
 25455, 25454, 25453, 25455, 25452, 25458, 25450, 25460, 25447, 25463,
 25445, 25466, 25441, 25468, 25438, 25472, 25434, 25477, 25425, 25499,
 25281, 25135, 25183, 25149, 25181, 25146, 25189, 25137, 25199, 25126,
 25210, 25114, 25222, 25103, 25232, 25093, 25240, 25088, 25241, 25089,
 25237, 25097, 25224, 25115, 25203, 25143, 25170, 25180, 25126, 25230,
 25072, 25289, 25009, 25357, 24937, 25433, 24855, 25516, 24770, 25606,
 24675, 25704, 24571, 25818, 24447, 25962, 24268, 26202, 23893, 26956,
 21241,-25891,-25536,-25131,-25929,-24860,-26151,-24656,-26361,-24423,
-26633,-24086,-27077,-23461,-28042,-21735,-32115,  1555
 	] @=> int wavetable[];
		return create_int16(wavetable);
	}
	//#endregion
}
