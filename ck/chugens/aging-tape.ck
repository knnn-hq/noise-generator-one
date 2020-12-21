public class AgingTape extends Chugen {
    11025.0 => float _sr; 
    1.0/11025.0 => float _t;
    0.0 => float _x_p;
    0.0 => float _x_q_p;
    0.0 => float _y_p;

    0.001 => float modLimit;
    0.05  => float feedbackLimit;
    
    0.8  => float pre_gain;
    0.1  => float bias;
    0.05  => float hysteresis;
    0.1  => float hysteresisWidth;
    0.01  => float quantum;
    0.2  => float cut;
    0.8  => float post_gain;
    0.1  => float modAmount;
    0.5  => float modRate;

    float window[0];
    1024  => int windowSize;
    0     => int windowWritePos;
    0     => int windowReadPos;
    false => int addFeedback;
    0.1   => float feedback;

    0 => int uptime;

    {
        window.size(windowSize);
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

        return _output(y * post_gain);
    }


    fun float _output(float y) {
        Std.fabs(y) => float abs_y;
        if (windowWritePos == windowSize - 1) {
            addFeedback++;
        }
        if (addFeedback && abs_y < feedbackLimit) {
            (1/windowSize) * windowReadPos * 0.45 => float ff;
            _mix(y, window[windowReadPos], (feedback * 0.5) + (feedback * ff)) => y;
            (windowReadPos+1) % windowSize => windowReadPos;
        }
        if (abs_y > modLimit) {
            y => window[windowWritePos];
            (windowWritePos+1) % windowSize => windowWritePos;
        }
        return y;
    }

    fun float _mix(float direct, float effect, float wet) {
        return (direct * (1.0 - wet)) + (effect * wet);
    }

    fun void _modulate() {
        60.0 * 5.0 => float maxTime; // 5 min
        1.0 => float modSign;
        if (Std.randf() < 0) {
            -1 *=> float modSign;
        }
        while (true) {
            if (Std.fabs(_y_p) > modLimit) {
                uptime++;

                uptime $ float / maxTime => float mod;
                mod * mod => float mod2;
                mod2 * mod => float mod3;
                mod2 * mod2 => float mod4;

                Math.min(0.9, mod2 * modAmount + hysteresisWidth) => hysteresisWidth;
                Math.min(0.9, mod3 * modAmount + cut) => cut;
                Math.min(0.9, mod4 * modAmount + quantum) => quantum;
                Math.min(0.9, mod4 * mod * modAmount + hysteresis) => hysteresis;

                if (modRate < _sr) {
                    mod2 * modAmount +=> modRate;
                }
            }
            (1 /  modRate)::second => now;
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

        _dx * Math.pow(1.0 - q, T*_sr*8.0) => float x_r;

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