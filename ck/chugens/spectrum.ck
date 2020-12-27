public class SpectrumOfFiniteScale extends Chubgraph {
    //#region routing
    inlet
        => Gain _dryMix
        => outlet;

    inlet
        => PitShift _pitch
        => LiSa     _sampler
        => Gain     _wetMix
        => outlet;

    _sampler 
        => LPF _lpf
        => Echo _delay 
        => _wetMix;

    _delay
        => Gain _delayFeedback
        => _pitch;

    Noise _noise
        => Phasor _lfo
        => Phasor _lfo2 
        => blackhole;
    
    //#endregion

    //#region backing props
    float _playbackRate;
    float _maxWetMix;
    float _pitchShift;
    float _sampleRate;
    float _sampleRateRatio;

    dur _stutterLength;
    //#endregion


    //#region Init
    {
        1.5 => _lfo.freq;
        0.5 => _lfo2.freq;
        _noise => _lfo2;

        1.0 => _delay.mix;
        500::ms => _delay.delay;
        10000::ms => _delay.max;

        0.5 => _delayFeedback.gain;

        //#region Set defaults
        0.5       => playbackRate;
        -.5       => pitchShift;
        11000.0   => sampleRate;
        100::ms   => stutter;
        1.0       => mix;
        //#endregion

        0 => _sampler.record;
        0 => _sampler.play; 

        spork ~ _modulator();
        spork ~ _stutterer();
    }
    //#endregion

    //#region Getters/setters
    fun float playbackRate() { return _playbackRate; }
    fun float playbackRate(float playbackRate) {
        playbackRate => _playbackRate;
        return _playbackRate;
    }
    fun float pitchShift() { return _pitchShift; }
    fun float pitchShift(float pitchShift) {
        pitchShift => _pitchShift;
        return _pitchShift;
    }

    fun float sampleRate() { return _sampleRate; }
    fun float sampleRate(float sampleRate) {
        sampleRate => _sampleRate;
        ((second/samp) / _sampleRate)  => _sampleRateRatio;
        return _sampleRate;
    }

    fun dur stutter() { return _stutterLength; }
    fun dur stutter(dur stutter) {
        stutter => _stutterLength;
        return _stutterLength;
    }

    fun float mix() { return _maxWetMix; }
    fun float mix(float mix) {
        mix => _maxWetMix => _wetMix.gain;
        (1.0 - _maxWetMix) => _dryMix.gain;
        return _maxWetMix;
    }
    //#endregion

    fun float _scaleLfo(float factor, float max) {
        return Std.rand2f( _lfo.last() * factor * max + ((1.0 - factor) * max), max);
    }
    fun float _scaleLfo2(float factor, float max) {
        return Std.rand2f( _lfo2.last() * factor * max + ((1.0 - factor) * max), max);
    }

    fun void _modulator() {
        while (true) {
            _lfo2.last() * 500 + 1000 => _lpf.freq;
            _sampleRateRatio::samp => now;
        }
    }

    fun void _stutterer() {
        15::ms => dur startRamp;
        15::ms => dur endRamp;

        while (true) {
            if (Std.randf() < -0.5) {
                _scaleLfo(0.2, _playbackRate) => _sampler.rate;
                _sampler.clear();
            }
            if (Std.randf() > 0.5) {
                _scaleLfo2(0.5, _pitchShift) => _pitch.shift;
            }

            (_stutterLength * Std.rand2f(1.0,4.0)) => dur currStutter;
            currStutter - endRamp => dur waitForRamp; 
            currStutter => _sampler.duration;
            1           => _sampler.record;

            waitForRamp => now;

            endRamp     => _sampler.recRamp;

            endRamp     => now;

            0           => _sampler.record;

            1 => _sampler.bi;
            1 => _sampler.loop;
            1 => _sampler.play;
            1 => _sampler.loopRec;
            0.1 => _sampler.feedback;

            currStutter * Std.rand2(4,8) => now;
        }
    }
}