public class Cellblock extends Chugen {
    //#region Tone
    TriOsc _toneOsc => blackhole;
    //#endregion

    //#region Timing
    float _sampleRate;    
    float _sampleRateRatio;
    int   _sampleRateRatioMin;
    int   _sampleRateRatioMax;
    //#endregion

    //#region Buffer
    float _buffer[0];
    int   _bufferSize;
    int   _writeHead;
    int   _readHead;
    int   _readStart;
    int   _readEnd;
    //#endregion

    //#region Misc settings
     0.9    => float _const_a;
    -0.6013 => float _const_b;
     2.0    => float _const_c;
     0.5    => float _const_d;

    float _mix;
    //#endregion

    //#region Counters, flags, registers
    float _lastSample;
    float _x_p;
    float _y_p;
    int   _repeatSample; // to time it to _sampleRate
    int   _ticksTotal;
    //#endregion

    //#region Init:
    {
        440 => _toneOsc.freq;
        0.2 => _toneOsc.gain;

        -0.72  => _x_p;
        -0.64  => _y_p;
        20000.0 => sampleRate;
        2048   => bufferSize; // ~ 500ms
        1.0    => mix;
        0 => _writeHead => _readHead;
        -1 => _readStart => _readEnd;
    }
    //#endregion

    //#region Getters/setters
    fun int bufferSize() { return _bufferSize; }
    fun int bufferSize(int bufferSize) {
        bufferSize => _bufferSize;
        if (_buffer.size() < _bufferSize) {
            _buffer.size() => int oldSize;
            _buffer.size(_bufferSize);
            for (oldSize => int i; i < _bufferSize; i++) {
                0.0 => _buffer[i];
            }
            _bufferSize %=> _writeHead;
            _bufferSize %=> _readHead;
        }
        return _bufferSize;
    }

    fun float mix() { return _mix; }
    fun float mix(float mix) {
        mix => _mix;
        return _mix;
    }

    fun float sampleRate() { return _sampleRate; }
    fun float sampleRate(float sampleRate) {
        sampleRate => _sampleRate;
        (second/samp) / _sampleRate => _sampleRateRatio;
        Math.floor(_sampleRateRatio) $ int => _sampleRateRatioMin;
        Math.ceil(_sampleRateRatio)  $ int => _sampleRateRatioMax;
        return _sampleRate;
    }
    //#endregion

    //#region Tick
    fun float tick(float in) {
        in => _buffer[_writeHead] => float out;
        (_writeHead + 1) % _bufferSize => _writeHead;
        if (_repeatSample) {
            _lastSample => out;
            _repeatSample--;
        } else {
            if (_ticksTotal >= _bufferSize) {
                if (_readStart < 0 || _readHead == _readEnd) {
                    _process(in);
                    _readStart => _readHead;
                }
                _buffer[_readHead] => out;
                if (_readEnd > _readStart) {
                    _readHead++;
                } else {
                    _readHead--;
                }
            }
            out => _lastSample;
            _sampleRateRatio $ int => _repeatSample; 
        }
        _ticksTotal++;
        return (out * _mix) + (in * (1.0 - _mix));
    }
    //#endregion

    //#region Internal
    fun void _process(float in) {
        // Tinkerbell map!
        (_x_p * _x_p - _y_p * _y_p) + (_const_a * _x_p) + (_const_b * _y_p) => float x;
        (2 * _x_p * _y_p) + (_const_c * _x_p)+ (_const_d * _y_p) => float y;
        x => _x_p;
        y => _y_p;

        (x * _bufferSize) $ int % _bufferSize => int readHeadX;
        (y * _bufferSize) $ int % _bufferSize => int readHeadY;
        while (readHeadX < 0) { _bufferSize +=> readHeadX; }
        while (readHeadY < 0) { _bufferSize +=> readHeadY; }
        readHeadX => _readStart;
        readHeadY => _readEnd;
    }
    //#endregion
}