public class Tunafish {
    27.5 => float baseFreq; // A0
    float cents[0];
    
    fun void repeatCentStep(float centStep, int numDegrees) {
        cents << 0;
        for (0 => int i; i < numDegrees; i++) {
            cents << (centStep * i);
        }
    }

    fun void intervalsToSteps(float intervals[]) {
        1 => float currStep;
        if (intervals[0] > 0) {
            cents << 0;
        }
        for (0 => int i; i < intervals.size(); i++) {
            currStep * intervals[i] => currStep; 
            cents << currStep;
        }
    }

    /// Public:
    fun float note(float rootFreq, int degree) {
        if (degree <= 1) { // pretend 0  and > MAX is 1
            return rootFreq;
        }

        degree - 1 => int scaleDegree;
        0.0 => float centsOffset;

        if (degree >= cents.size()) {
            degree / cents.size() => int numOctaves;
            degree % cents.size() => scaleDegree;
            numOctaves * cents[cents.size()-1] => centsOffset;
        }

        return Tunafish.centsToFreqRatio(centsOffset + cents[scaleDegree]) * rootFreq;
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

    // Wendy Carlos's Alpha tuning
    fun static Tunafish createAlpha(float freq) {
        return Tunafish.create(freq, 77.965, 19);
    }
    // Wendy Carlos's Beta tuning
    fun static Tunafish createBeta(float freq) {
        return Tunafish.create(freq, 63.833, 20);
    }
    // Wendy Carlos's Gamma tuning
    fun static Tunafish createGamma(float freq) {
        return Tunafish.create(freq, 35.099, 36);
    }

    fun static Tunafish createShruti(float freq) {
        Tunafish ts;
        [
              0.0,
             90.2250,
            111.7313,
            182.4038,
            203.9100,
            294.1351,
            315.6414,
            386.3139,
            407.8201,
            498.0452,
            519.5515,
            590.2239,
            611.7302,
            701.9553,
            792.1803,
            813.6866,
            884.3591,
            905.8654,
            996.0905,
            1017.596,
            1088.269,
            1109.775
        ] @=> ts.cents;
        freq => ts.baseFreq;

        return ts;
    }
}