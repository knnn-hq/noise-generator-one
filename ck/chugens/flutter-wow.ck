// #include "effect.ck"

class Flutter extends Effect {
    inlet => LPF _lpf;

    float _rate;
    float _depth;
    float _tone;
    int _size;

    SinOsc _lfos[0];
    PitShift _shifts[0];

    {
        3   => size;
        0.1 => rate;
        0.1 => depth;
        0.1 => tone;
        0.5 => mix;

        spork ~ _update();
    }

    fun float rate() { return _rate; }
    fun float rate(float rate) {
        rate => _rate;
        _linterp(_rate, 0.0, 1.0, 0.001, 0.1) => float r;
        r => _lfos[0].freq;
        for (1 => int i; i < _size; i++) {
            r + (r / (i * 1.5)) => _lfos[i].freq;
        }
        return _rate;
    }
    fun float depth() { return _depth; }
    fun float depth(float depth) {
        depth => _depth;
        _linterp(_depth, 0.0, 1.0, 0.001, 0.1) => float d;
        d => _lfos[0].gain;
        for (1 => int i; i < _size; i++) {
            d - (d / (i * 1.5)) => _lfos[i].gain;
        }
        return _depth;
    }

    fun float tone() { return _tone; }
    fun float tone(float tone) {
        tone => _tone;
        _linterp(_tone, 0.0, 1.0, 440.0, 2640.0) => _lpf.freq;
        return _tone;
    }

    fun int size() { return _size; }
    fun int size(int size) {
        _lfos.size() => int prevSize;

        _lfos.size(size);
        _shifts.size(size);

        for (prevSize => int i; i < size; i++) {
            SinOsc lfo => blackhole;
            _lpf => PitShift shift => wet;

            lfo @=> _lfos[i];
            shift @=> _shifts[i];
        }
        size => _size;
        return _size;
    }

    fun void _update() {
        while (true) {
            1::samp => now;

            for (0 => int i; i < _size; i++) {
                Math.pow(2.0, _lfos[i].last()) => _shifts[i].shift;
            }
        }
    }

    fun float _linterp(float value, float sourceMin, float sourceMax, float targetMin, float targetMax) {
        return targetMin + (targetMax - targetMin) * ((value - sourceMin) / (sourceMax - sourceMin));
    }
}

public class FlutterAndWow extends Effect {
    inlet => Flutter _flutter => wet;
    inlet => Flutter _wow     => wet;

    SinOsc _lfoFlutter => blackhole;
    SinOsc _lfoWow => blackhole;

    0.1 => float _wowDeltaRate;
    0.5 => float _wowDepth;
    0.2 => float _wowRate;

    0.5 => float _flutterDeltaRate;
    1.5 => float _flutterDepth;
    1.5 => float _flutterRate;

    {
        _flutterDeltaRate => _lfoFlutter.freq;
        _wowDeltaRate     => _lfoWow.freq;

        1.0 => _lfoFlutter.gain => _lfoWow.gain;

          6 => _flutter.size;
          5 => _wow.size;

        0.6 => _flutter.mix;
        0.8 => _wow.mix;

        1.0 => mix;

        spork ~ _update();
    }

    fun void _update() {
        0.01 => float t;
        while (true) {
            2::samp => now;
			if (Math.randomf() > 0.9) {
				1.2 => t;
			}
            t * t => float t_2;
            t_2 * t_2 => float t_4;


            _lfoFlutter.last() + 1.0 => float flutterLfo;
            _lfoWow.last() + 1.0 => float wowLfo;

            Math.sinh(t_4 * flutterLfo) * _flutterRate  => _flutter.rate;
            Math.sinh(t_2 * flutterLfo) * _flutterDepth => _flutter.depth;

            Math.tanh(t_2 * wowLfo) * _wowRate => _wow.rate;
            Math.tanh(t * wowLfo) * _wowDepth  => _wow.depth;

            Std.rand2f(0.001, 0.01) +=> t;
            if (t >= 1.0) {
                0.01 => t;
                _wowDeltaRate * Std.rand2f(0.9, 1.1) => _lfoWow.freq;
                _flutterDeltaRate * Std.rand2f(0.9, 1.1) => _lfoFlutter.freq;
            }
        }
    }
}

