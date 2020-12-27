public class AgingTape extends Chugen {
    28000.0 => float sampleRate; 
    1.0/sampleRate => float _t;

    0.0 => float _x_p;
    0.0 => float _x_q_p;
    0.0 => float _y_p;
    
    0.8  => float pre_gain;
    0.05  => float bias;
    0.05 => float hysteresis;
    0.01  => float hysteresisWidth;
    0.01 => float quantum;
    0.04 => float cut;
    0.8  => float post_gain;

    0.2  => float maxBias;
    0.2 => float maxHysteresis;
    0.05  => float maxHysteresisWidth;
    0.2 => float maxQuantum;
    0.5  => float maxCut;


    0 => int uptime;

    Noise _noise 
        => Phasor _lfo
        => Phasor _lfo2 
        => blackhole;

    {
        0.5  => _lfo.freq;
        0.04 => _lfo2.freq;
        1.0 => _lfo2.phase;

        spork ~ _modulate();
    }

    fun float tick(float in) {
        in * pre_gain => float x;

        _diff(x, _x_p, _t) => float dx;
        _sat(x, dx, bias, hysteresisWidth, hysteresis) => float x_sat;
        _x_quant(x_sat, _x_q_p, _t, quantum) => float x_quant;
        _play(x_quant, _y_p, cut) => float y;

        x => _x_p;
        x_quant => _x_q_p;
        y => _y_p;

        return y * post_gain;
    }

    fun float _apply(float base, float lfo) {
        return base * lfo;
    }

    fun void _modulate() {
        0.0001 => float _t;
        0.00001 => float _dt; 
        while (true) {
            _lfo.last()  * _tanh(_t) * _t  => float lfoVal;
            _lfo2.last() * _tanh(_t) => float lfoVal2;
            _dt +=> _t;

            if (_t >= 1.0) {
                -1 *=> _dt;
                0.99999 => _t; 
            } else if (_t <= 0.0) {
                -1 *=> _dt;
                0.00001 => _t;
            }

            maxBias            * lfoVal  => bias;
            maxHysteresisWidth * lfoVal2 => hysteresisWidth;
            maxHysteresis      * lfoVal  => hysteresis;
            maxQuantum         * lfoVal  => quantum;
            maxCut             * lfoVal2 => cut;

            ((second/samp) / sampleRate)::samp => now;
        }
    }

    fun float _diff(float x, float x_p, float t) {
        return (x - x_p)/t;
    }

    fun float _sech(float x, float w, float amt) {
        1.0/w*x => float x1; // change width of hyp-secant by making the input steeper
        x1*x1 => float x2;    // pre-compute square of x
        24.0/((x2 + 12.0)*x2 + 24.0) => float sech;
        return sech*(w/100.0)*amt;    // scale output for smoother hysteresis
    }
    fun float _tanh(float x) {
        x * x => float x_2;
        return x/(1.0+x_2/(3.0+x_2/(5.0+x_2/(7.0+x_2/13.0))));
    }

    /// tape saturation
    /// + x     input
    /// + dx    derivative of input
    /// + bias  input bias (asymmetric distortion)
    /// + w     hysteresis width
    /// + k     hysteresis depth
    fun float _sat(float x, float dx, float bias, float w, float k) {
        return _tanh((x + bias)*0.8 + _sech(x, w, k)*dx) - bias/1.316;
    }

    /// stochastic quantization
    ///     simulates quantum nature of magnetic tape magnetization
    /// + x:    input
    /// + y_p:  previous output
    /// + T:    intersample period
    /// + q:    quantization amount
    fun float _x_quant(float x, float x_p, float T, float q) {
        _diff(x, x_p, T) => float dx;

        Std.fabs(dx) => float _dx;
        Std.rand2f(0.0, 1.0) * 10.0 => float r;

        _dx * Math.pow(1.0 - q, T*sampleRate*8.0) => float x_r;

        if (r < x_r){
            return x;
        }
        return x_p;
    }

    /// playback head frequency response
    ///     simulates the playback head not picking up high frequencies
    /// + x     : input
    /// + y_p   : previous output
    /// + cut   : cutoff (as proportion of nyquist modLimit)
    fun float _play(float x, float y_p, float cut) {
        return x*(1.0 - cut) + y_p*cut;
    }
}