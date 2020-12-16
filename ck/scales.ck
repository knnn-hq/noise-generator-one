public class Scaler {
    440.0 => float baseFreq;
    100.0 => float centStep;

    fun float note(int degree) {
        if (degree == 0 || degree == 1) { // pretend 0 is 1
            return baseFreq;
        }
        return Scaler.centsToFreqRatio(degree * centStep) * baseFreq;
    }

    ///
    /// STATIC
    ///
    fun static float centsToFreqRatio(float cents) {
        return Math.pow(2, cents / 1200.0);
    }

    fun static Scaler create(float freq, float step) {
        Scaler s;

        freq => s.baseFreq;
        step => s.centStep;

        return s;
    }

    fun static Scaler createAlpha(float freq) {
        return Scaler.create(freq, 77.965);
    }
}