// #include "effect.ck"

public class Freeze extends Effect {
    LiSa _lisas[0];
    8 => int _size;
    400::ms => dur _rate;
    40::ms => dur _recRamp;
    100::ms => dur _attack;
    800::ms => dur _decay;
    0.20 => float _spread;
    0 => int _index;

    1.0 => float _playbackRate;

    0 => static int THAWED;
    1 => static int FREEZING;
    2 => static int FROZEN;
    3 => static int THAWING;

    THAWED => int _state;

    {
        _lisas.size(_size);

        for (0 => int i; i < _size; i++) {
            inlet => LiSa lisa => wet;
            _rate => lisa.duration;
            1 => lisa.loop;
            0 => lisa.play;
            1 => lisa.record;
            _recRamp => lisa.recRamp;
            lisa.voiceGain(0, 0.8);
            lisa @=> _lisas[i];
        }

        spork ~ _update();
    }

    fun float playbackRate() { return _playbackRate; }
    fun float playbackRate(float playbackRate) {
        playbackRate => _playbackRate;
        for (0 => int i; i < _size; i++) {
            _playbackRate => _lisas[(_index + 1) % _size].rate;
        }
        return _playbackRate;
    } 

    fun void freeze() {
        if (_state == THAWED) {
            FREEZING => _state;
            for (0 => int i; i < _size; i++) {
                _lisas[(_index + 1) % _size] @=> LiSa lisa;
                0::samp => lisa.playPos;
                _attack => lisa.rampUp;
                0 => lisa.record;
                1 => lisa.bi;
            }
            FROZEN => _state;
        }
    }

    fun void thaw() {
        if (_state == FROZEN) {
            THAWING => _state;
            for (0 => int i; i < _size; i++) {
                _lisas[(_index + 1) % _size] @=> LiSa lisa;
                1.0 => lisa.rate;
                0 => lisa.bi;
                _decay => lisa.rampDown;
            }
            THAWED => _state;
        }
    }

    fun void _update() {
        while (true) {
            _rate/_size => now;

            if (_state == THAWED) {
                // only randomly update (1.0 - spread) at any one time
                if (Math.randomf() > (1.0 - _spread)) {
                    _lisas[_index] @=> LiSa lisa;

                    0 => lisa.record;
                    lisa.clear();

                    0::samp => lisa.recPos;
                    1 => lisa.record;
                }
                (_index + 1) % _size => _index;
            }
        }
    }
}