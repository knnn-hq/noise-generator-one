// #include "effect.ck"
// #include "aging-tape.ck"
// #include "flutter-wow.ck"

public class TapeMachine extends Effect {
    inlet 
        => AgingTape     _agingTape
        => FlutterAndWow _wow 
        => Gain _dryMix
        => wet;

    _wow
        => LPF _lpf
        => Gain _lpfMix
        => wet;

    _wow
        => HPF _hpf
        => Gain _hpfMix
        => wet;

    _agingTape
        => Delay _fatten
        => Gain _fattenMix
        => wet;

    {
        1::ms => _fatten.delay => _fatten.max;

        2.0 => _agingTape.pre_gain;
        0.8 => _agingTape.post_gain;
        0.7 => _wow.mix;
        0.99 => mix;
        2500 => _hpf.freq;
        3500 => _lpf.freq;
        0.25 => _lpfMix.gain => _hpfMix.gain => _fattenMix.gain;
        0.8 => _dryMix.gain;
    }
}
