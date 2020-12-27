public class Repeaty extends Chugen {
    float _buffer[0];
    int _repeatLength;
    int _skipSamples;
    int _readHead;
    int _writeHead;

    {
        -1 => _readHead;
        0 => _skipSamples => _writeHead;
        5 => length;
    }

    fun int length(int length) {
        length => _repeatLength;
        _buffer.size(_repeatLength * 5);
        return _repeatLength;
    }
    fun int length() { return _repeatLength; }

    fun float tick(float in) {
        in => _buffer[_writeHead] => float out;
        (_writeHead + 1) % _buffer.size() => _writeHead;
       
        if (_skipSamples > 0) {
            _buffer[_readHead] => out;
            _skipSamples--; 
        } else {
            _repeatLength => _skipSamples;
            (_readHead + 1) % _buffer.size() => _readHead;
        }
        return out;
    }
}