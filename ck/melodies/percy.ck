public class Percy extends Chubgraph {
    Tunafish _t;
    
    PercFlut _f;
    Gain _g;
    Pan2 _p;
    _f => _g => _p => outlet;

    0     => int _tuner;
    58.27 => float _baseFreq;
    1     => int _octave;
    1.0   => float _maxVelocity;
    0.9   => float _lastVelocity;
    0     => int _lastNote;
    0.0   => float _detuneAmount;
    false => int _detune;

    float _pan;
    float _gain;

    {
        tuner(0);
        Math.random2f(1.4, 2.3)  => _f.lfoSpeed;
        Math.random2f(0.05, 0.1) => _f.lfoDepth;
        spork ~ _update();
    }
    fun int tuner(int tuner) {
        tuner % 4 => _tuner;
        if (_tuner == 0) {
            Tunafish.createAlpha(_baseFreq)  @=> _t;
        } else if (_tuner == 1) {
            Tunafish.createBeta(_baseFreq) @=> _t;
        } else if (_tuner == 2) {
            Tunafish.createGamma(_baseFreq) @=> _t;
        } else if (_tuner == 3) {
            Tunafish.createShruti(_baseFreq) @=> _t;
        }
        return _tuner;
    }
    fun int tuner() {
        return _tuner;
    }

    fun float baseFreq(float freq) {
        freq => _baseFreq;
        Tunafish.createAlpha(_baseFreq) @=> _t;
        return _baseFreq;
    }
    fun float baseFreq() {
        return _baseFreq;
    }

    fun float velocity(float velocity) {
        velocity => _maxVelocity;
        return _maxVelocity;
    }
    fun float velocity() {
        return _maxVelocity;
    }

    fun float pan(float pan) {
        pan => _pan => _p.pan; 
        return _pan;
    }
    fun float pan() {
        return _pan;
    } 
    fun float gain(float gain) {
        gain => _gain => _g.gain;
        return _gain;
    }
    fun float gain() {
        return _gain;
    }
    fun int octave(int octave) {
        octave => _octave;
        return _octave;
    }
    fun int octave() {
        return _octave;
    }

    fun void noteOn(int note) {
        Std.rand2f(_maxVelocity * 0.85, _maxVelocity) => float velocity;

        if (note < 0) {
            _rest(note, velocity);
        } else if (note == 0) {
            _blank(note, velocity);
        } else {
            _note(note, velocity);
        }
        note => _lastNote;
    }

    fun int _absoluteDegree(int degree) {
        if (_octave <= 1) {
            return degree;
        }
        return _octave * _t.cents.size() + degree;
    }

    fun void _blank(int note, float velocity) {
        if (_lastNote < 0) {
            _lastVelocity / 2 => _f.afterTouch;
        }
    }
    
    fun void _rest(int note, float velocity) {
        velocity => _f.noteOff;
        velocity / 2 => _lastVelocity => _f.afterTouch;
    }

    fun void _note(int note, float velocity) {
        _t.note(_baseFreq, _absoluteDegree(note)) => float freq;
        freq => _f.freq;
        velocity => _lastVelocity => _f.noteOn;
        true => _detune;
        freq - _baseFreq => _detuneAmount;
    }

    fun void _update() {
        0 => int t;
        0.0 => float d;
        while (true) {
            if (_detune) { // start detune
                1 => t;
                1.0 => d;
            } else if (t > 0 && t < 100) {
                t / 100.0 => float f;
                f * f * _detuneAmount => d;
                <<< "detune:", d >>>;
                _f.freq() - d => _f.freq;
                t++;
            } else if (t) {
                0 => t => _detune;
                0.0 => d;
            }
            50::ms => now;
        }
    }
}