public class Stretch extends Chubgraph {
	inlet => Gain dry => outlet;
    Gain wet => outlet;

	inlet 
		=> FFT _fft =^ IFFT _ifft 
		=> blackhole;

	Impulse  _imp 
		=> LPF _lpf 
		=> blackhole;
	
	_lpf 
		=> PitShift _pitch1
		=> wet;
	_lpf
		=> PitShift _pitch2
		=> wet;

	float _stretch;
    float _mix;
	dur   _window;
	int   _window_size;
	int   _half_window_size;
	int   _write_pos;
	float _output_buffer[0];

	Shred _processer;
	Shred _player;
	false => int _stretching;
	false => int _playing;

	{
		1.0   => mix;
		
		5::second => _window;

		0.9  => _imp.gain;
		1000  => _lpf.freq;

		0.4   => _pitch1.shift;
		0.5   => _pitch1.gain;

		1.6   => _pitch2.shift;
		0.5   => _pitch2.gain;

		10.0  => stretch;
	}

	fun void restart() {
		if (_stretching) {
			_processer.exit();
			_player.exit();
		}
		((_window / 1::second) * (second/samp)) $ int => _window_size;
		(_window_size / 2) $ int => _half_window_size;
		_output_buffer.size() => int old_window_size;
		_output_buffer.size(_window_size);
		for (old_window_size => int i; i < _output_buffer.size(); i++) {
			0.0 => _output_buffer[i];
		}
		0 => _write_pos;

		spork ~ _process() @=> _processer;
		spork ~ _play() @=> _player;
		true => _stretching;
	}

    fun float stretch() { return _stretch; }
    fun float stretch(float stretch) {
        stretch => _stretch;
		restart();
        return _stretch;
    }

    fun float mix() { return _mix; }
    fun float mix(float mix) {
        mix => _mix => wet.gain;
        (1.0 - _mix) => dry.gain;
        return _mix;
    }

	fun void _play() {
		0 => int read_pos;
		while (true) {
			if (_playing) {
				_output_buffer[read_pos] => _imp.next;
				(read_pos + 1) % _output_buffer.size() => read_pos;
			}
			1::samp => now;
		}
	}

	fun void _write(float output, float level) {
		if (_output_buffer[_write_pos] != 0.0) {
			(_output_buffer[_write_pos] * (1.0 - level)) + output * level => _output_buffer[_write_pos];
		} else {
			output * level => _output_buffer[_write_pos];
		}
		(_write_pos + 1) % _output_buffer.size() => _write_pos;
	}

	fun void _process() {
		2.0 * pi => float twopi;
		_window_size => _fft.size;
		Windowing.hann(_window_size) => _fft.window;
		Windowing.hann(_window_size) => _ifft.window;
		complex s[_half_window_size];
		float ifft_s[_window_size];
		float old_ifft_s[_half_window_size];

		(1+Math.sqrt(0.5))*0.5 => float hinv_sqrt2;
		float hinv_buf[_half_window_size];
		for(int i; i < _half_window_size; i++) {
    		hinv_sqrt2-(1.0-hinv_sqrt2)*Math.cos(i*twopi/_half_window_size) 
				=> hinv_buf[i];
		}
		(_window_size / _stretch) => float displace_pos;

		while (true) {
			_window => now;

			_fft.upchuck();
    		_fft.spectrum(s);

			polar pol;
    		for	(0 => int i; i < _window_size; i++) {
        		s[i] $ polar => pol;
        		Math.random2f(0, twopi) => pol.phase;
        		pol $ complex => s[i];
    		}
    		_ifft.transform(s);
    		_ifft.samples(ifft_s);
        
    		float output;
			0.1 => float level;

    		for(0 => int i; i < _half_window_size; i++) {
        		hinv_buf[i] * (ifft_s[i] * 0.5 + old_ifft_s[i] * 0.5) => output;
				if (output >= 1.0) {
					0.99 => output;
				} else if (output <= -1.0) {
					-.99 => output;
				}
				_write(output, level);
				if (level < 1.0) {
					0.05 +=> level; 
				}
        		ifft_s[i + _half_window_size] => old_ifft_s[i];
    		}
			true => _playing;
		}
	}
}
