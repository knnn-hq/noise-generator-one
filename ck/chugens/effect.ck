public class Effect extends Chubgraph {
    inlet => Gain dry => outlet;
    Gain wet => outlet;

    float _mix;

    fun float mix() { return _mix; }
    fun float mix(float mix) {
        mix => _mix => wet.gain;
        (1.0 - _mix) => dry.gain;

        return _mix;
    }
}