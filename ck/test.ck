// patch
PRCRev r => Gain globGain => dac;
.9 => globGain.gain;
.4 => r.mix;

// misc
Event e;
58.27 => float Bb;
19 => int alphaOctave;

// player
fun void playtrack(Event e, Tracky track) {
    Tunafish.createAlpha(Bb) @=> Tunafish alphaTunerBb; // Bb alpha-scale
    
    PercFlut inst => Gain g => Pan2 p => r;

    Math.random2f(1.4, 2.3) * track.octave => inst.lfoSpeed;
    Math.random2f(0.05, 0.1) => inst.lfoDepth;

    track.velocity / 2 => g.gain;
    track.pan => p.pan;

    // infinite time loop
    Tracky.NoteBlank => int lastNote;

    while (true) {
        e => now;

        track.nextNote() => int note;
        
        if (note == Tracky.NoteRest) {
            track.velocity => inst.noteOff;
            track.velocity => inst.afterTouch;
        } else if (note != Tracky.NoteBlank) {
            alphaTunerBb.note(note + (alphaOctave * (track.octave - 1))) => inst.freq;
            Std.rand2f(track.velocity - 0.05, track.velocity + 0.05) => inst.noteOn;
        } else if (lastNote == Tracky.NoteRest) {
            track.velocity / 2 => inst.afterTouch;
        }
        note => lastNote;
    }
}
spork ~ playtrack(e, Tracky.create(1, 0.2, 0.9, ["1 5"]));

Tracky tracks[0];

tracks << Tracky.create(3, -0.8, 0.8, 0, [
    " # > > > | % ",
    " > > > > | % ",
    " 7 > > > | > > > > ",
    " # > > > | 5 > # > ",
    " 9 > > > | 4 > 9 > "
]);
tracks << Tracky.create(2, -0.4, 0.7, [
    " #  >  >  > > | % ",
    " 11 >  >  > > ",
    " >  > 10  > > ",
    " 13 >  > 14 > ",
    " >  >  >  > > "
]);
tracks << Tracky.create(3, 0.2, 0.6, 0, [
    " > >>> > >>  5 > 4 > ",
    " 1 >>> > >>  5 > > > ",
    " 1 >>> > >>  5 > 8 >",
    " > >>> > >>  7 > 9 > ",
    " 3 >>> > >>  6 > 7 > ",
    " 1 >>> > >>  6 > 9 > ",
    " > >>> 7 >>  > > > > ",
    " # >>> > >>  > > > >"
]);

tracks << Tracky.create(3, 0.4, 0.6, 0, [
    "> > > > > > | % ",
    " 4 > > > > > ",
    " > > 5 > > > ",
    " 9 > > 1 > >"
]);
tracks << Tracky.create(2, 0.8, 0.8, [
    " > > >   > > > > | %",
    "19 # >  25 # > > ",
    "20 # >  25 # > > ",
    " > > >   > > > > "
]);

    0 => int tempoWaitCounter;
    0 => int trackWaitCounter;
 10.0 => float baseDelta;
240.0 => float currDelta;
  0.0 => float targetDelta;
    1 => int minChange;
    4 => int maxChange;
false => int changeTempo;
    0 => float actualDelta;
  256 => int waitForChange;
  
    1 => int nextTrack;
   32 => int waitForNext;
    2 => int waitFactor;

while(true) {
    baseDelta +=> actualDelta;

    if (actualDelta >= currDelta) {
        1 +=> tempoWaitCounter;
        1 +=> trackWaitCounter;
        0  => actualDelta;

        if (trackWaitCounter == waitForNext) {
            <<< "Starting track:", nextTrack >>>;
            tracks[nextTrack] @=> Tracky nt;
            nextTrack++;
            if (nextTrack >= tracks.size()) {
                1 => nextTrack;
                waitFactor++;
            }
            Std.rand2(nt.trackLength(), nt.trackLength() * waitFactor) => waitForNext;
            0 => trackWaitCounter;

            spork ~ playtrack(e, nt);
        }

        e.broadcast();
        
        if (currDelta >= 120.0) {
            if (changeTempo) {
                Math.fabs(targetDelta - currDelta) => float dist;

                if (dist <= minChange) {
                    targetDelta => currDelta;
                    false => changeTempo;
                    0 => tempoWaitCounter;
                    Std.rand2(128, 512)  => waitForChange;
                } else {
                    1 => int direction;
                    if (targetDelta < currDelta) {
                        -1 => direction;
                    }
                    Std.rand2(minChange, maxChange) * direction => int deltaDelta;
                    deltaDelta +=> currDelta;
                }
            } else if (tempoWaitCounter == waitForChange) {
                currDelta - baseDelta => targetDelta;
                <<< "Ramping delta to: ", targetDelta, " ms" >>>;
                true => changeTempo;
            }
        }
    }
    baseDelta::ms => now;
}