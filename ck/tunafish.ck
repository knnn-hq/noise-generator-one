public class Tunafish {
    27.5 => float baseFreq; // A0
    float cents[0];
    
    fun void repeatCentStep(float centStep, int numRepeats) {
        for (0 => int i; i < numRepeats; i++) {
            cents << (centStep * i);
        }
    }

    fun void intervalsToSteps(float startStep, int octaves, float intervals[]) {
        startStep => float currStep;
        for (0 => int i; i < intervals.size(); i++) {
            currStep * intervals[i] => currStep; 
            cents << currStep;
        }
        if (octaves <= 1) {
            return;
        }
        intervalsToSteps(currStep, octaves - 1, intervals);
    }

    fun void intervalsToSteps(int octaves, float intervals[]) {
        intervalsToSteps(1, octaves, intervals);
    }

    fun void intervalsToSteps(float intervals[]) {
        intervalsToSteps(8, intervals);
    }

    /// Public:
    fun float note(float rootFreq, int degree) {
        if (degree == 0 || degree == 1 || degree > cents.size()) { // pretend 0  and > MAX is 1
            return rootFreq;
        }
        return Tunafish.centsToFreqRatio(cents[degree]) * rootFreq;
    }

    fun float note(int degree) {
        return note(baseFreq, degree);
    }

    ///
    /// STATIC
    ///

    fun static float centsToFreqRatio(float cents) {
        return Math.pow(2, cents / 1200.0);
    }

    /// Factory methods

    fun static Tunafish create(float freq, float intervals[]) {
        Tunafish s;
        freq => s.baseFreq;
        s.intervalsToSteps(intervals);

        return s;
    }

    fun static Tunafish create(float freq, float step, int degrees) {
        Tunafish s;

        freq => s.baseFreq;
        s.repeatCentStep(step, degrees);

        return s;
    }

    fun static Tunafish create(float freq, float step) {
        return Tunafish.create(freq, step, 128);
    }

    // Wendy Carlos's Alpha tuning
    fun static Tunafish createAlpha(float freq) {
        return Tunafish.create(freq, 77.965);
    }
}