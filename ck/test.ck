// patch
PRCRev r => Gain globGain => dac;
.9 => globGain.gain;
.4 => r.mix;

// misc
Event e;
KBHit kb;

58.27 => float Bb;

// main player
fun void main(Event e, int octave, float pan, float vel, PianoRoll track) {
    Scaler.createAlpha(octave * Bb) @=> Scaler scale; // Bb alpha-scale
    
    PercFlut inst => Gain g => Pan2 p => r;
    Math.random2f(5.5, 9.9) => inst.lfoSpeed;
    Math.random2f(0.05, 0.1) => inst.lfoDepth;

    vel / 2 => g.gain;
    pan => p.pan;

    // infinite time loop
    PianoRoll.CellContinue => int lastNote;
    while (true) {
        track.next() => int note;
        if (note == PianoRoll.CellRest) {
            vel => inst.noteOff;
            vel => inst.afterTouch;
        } else if (note != PianoRoll.CellContinue) {
            scale.note(note) => inst.freq;
            Math.random2f(vel - 0.05, vel + 0.05) => inst.noteOn;
        } else if (lastNote == PianoRoll.CellRest) {
            vel / 2 => inst.afterTouch;
        }
        note => lastNote;
        e => now;
    }
}


fun void keyplayer(KBHit @ _kb) {
    PercFlut inst => ADSR adsr => Gain g => Pan2 p => r;
    Scaler.createAlpha(Bb * 2) @=> Scaler scale; // Bb alpha-scale
    "zxcvbnmasdfghjklqwertyuiop1234567890" => string keys;
    adsr.set(150::ms, 200::ms, 0.8, 300::ms);

    Math.random2f(5.5, 9.9) => inst.lfoSpeed;
    Math.random2f(0.05, 0.1) => inst.lfoDepth;
    0 => float pan;
    0.8 => float gain;

    gain => g.gain;
    pan  => p.pan;
    false => int escape;
    while(true) {
        _kb => now;
        while(_kb.more()) {
            _kb.getchar() => int c;
            if (c == 91) {
                true => escape;
            } else {
                if (escape) {
                    if (c == 67) { // right
                        0.1 +=> pan;       
                    } else if (c == 68) {
                        0.1 -=> pan;
                    } else if (c == 66) {
                        0.1 -=> gain;
                    } else if (c == 65) {
                        0.1 +=> gain;
                    }
                    <<< "gain: ", gain, "pan: ", pan >>>;
                    gain => g.gain;
                    pan => p.pan;
                } else if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
                    keys.find(c) => int pos;
                    if (pos >= 0) {
                        scale.note(pos + 1) => inst.freq;
                        0.9 => inst.noteOn;
                        1 => adsr.keyOn;

                        50::ms => now;
                        1 => adsr.keyOff;
                    }
                }
                false => escape;
            }
        }
    }
}

spork ~ main(e, 3, -0.8, 0.8, PianoRoll.create(
    "> > > > | 5 > X > | > > 9 > | X > > > | 5 > X > | 9 > X >"
));
spork ~ main(e, 2, -0.4, 0.7, PianoRoll.create(
    "> > > > > | > > > > > | 4 > > > > | > > 5 > > | 9 > > 1 >"
));
spork ~ main(e, 4, 0.2, 0.4, PianoRoll.create(
    ">>>>>>>>>>> | >>>>>>>>>>> | >>>>>>> 5 > 4 > | 1 >>>>>> 5 >>> | 1 >>>>>>> 5 > 1"
));
spork ~ main(e, 1, 0.2, 0.9, PianoRoll.create("1 5"));
spork ~ main(e, 2, 0.4, 0.6, PianoRoll.create(
    "> > > > > > | > > > > > > | 4 > > > > > | > > 5 > > > | 9 > > 1 > >"
));
spork ~ main(e, 3, 0.8, 0.8, PianoRoll.create(
    "> > >  > > > > | 19 X >  25 X > > | 20 X >  25 X > >"
));
spork ~ keyplayer(kb);

    0 => int n;
 10.0 => float baseDelta;
100.0 => float currDelta;
  0.0 => float targetDelta;
    1 => int minChange;
    4 => int maxChange;
false => int changeTempo;
    0 => float actualDelta;
  200 => int waitForChange; 

while(true) {
    baseDelta +=> actualDelta;

    if (actualDelta >= currDelta) {
        1 +=> n;
        0 => actualDelta;
        e.signal();
        
        if (changeTempo) {
            Math.fabs(targetDelta - currDelta) => float dist;

            if (dist <= minChange) {
                targetDelta => currDelta;
                false => changeTempo;
                0 => n;
            } else {
                1 => int direction;
                if (targetDelta < currDelta) {
                    -1 => direction;
                }
                Std.rand2(minChange, maxChange) * direction => int deltaDelta;
                deltaDelta +=> currDelta;
            }
        } else if (n == waitForChange) {
            Std.rand2(0, 3) - 1 => int amt;
            currDelta + (amt * baseDelta) => targetDelta;
            true => changeTempo;
        }
    }
    baseDelta::ms => now;
}