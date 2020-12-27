// See 'pm/Chuck/Runner.pm'...
// #include "lib/stringer.ck"
// #include "lib/tracky.ck"
// #include "chugens/freeze.ck"
// #include "chugens/percy.ck"
// #include "chugens/tape-machine.ck"

// patch
PRCRev r => Freeze fr => TapeMachine tape => Dyno master => Gain globGain => dac;

.9 => master.gain => globGain.gain;
.4 => r.mix;
.0 => fr.mix;

master.limit();

// misc
Event e;

fun void stutter() {
    while (true) {
        1::second => now;

        if (Math.randomf() > 0.98) {
            <<< "Freezing..." >>>;
            1.0 => fr.playbackRate;
            Std.rand2f(0.5, 0.75) => float goalRate;

            fr.freeze();

            while (fr.mix() < 1.0) {
                0.05 + fr.mix() => fr.mix;
                10::ms => now;
            }
            while(fr.playbackRate() > goalRate) {
                fr.playbackRate() - 0.01 => fr.playbackRate;
                10::ms => now;
            }
            
            Std.rand2f(750,4500)::ms => now;
            
            Std.rand2f(0.9,1.2) => goalRate;

            while(fr.playbackRate() < goalRate) {
                fr.playbackRate() + 0.01 => fr.playbackRate;
                10::ms => now;
            }
            while (fr.mix() > 0.0) {
                fr.mix() - 0.1 => fr.mix;
                10::ms => now;
            }
            0.0 => fr.mix;
            fr.thaw();
        }
    }
}

fun void playTrack(Event e, Tracky track, int index) {
    Percy perc => r;
    
    <<< "Starting track:", index >>>;

    index % 2 == 0 && index  => int isEven;
    (index % 4) - isEven     => int modIndex;
    Math.min(index, 2) $ int => int clampIndex;
    1 - (2 * isEven)         => int panDir;

    0.2 * modIndex * panDir   => perc.pan;
    (clampIndex) + 1          => perc.octave;
    0.8 - (clampIndex * 0.15) => perc.gain;
    0.9 - (clampIndex * 0.10) => perc.velocity;

    while (true) {
        e => now;
        track.nextNote() => perc.noteOn;
    }
}

Tracky tracks[0];
tracks << Tracky.create(["1 5"]);
tracks << Tracky.create([
    " #  >  >  > > | % ",
    " 11 >  >  > > ",
    " >  > 10  > > ",
    " 13 >  > 14 > ",
    " >  >  >  > > "
]);
tracks << Tracky.create([
    " > > >   > > > > | %",
    "19 > >  15 > > # ",
    "18 > >  14 > > # ",
    " > > >   > > > > "
]);
tracks << Tracky.create([
    " # > > > | % ",
    " > > > > | % ",
    " 7 > > > | > > > > ",
    " # > > > | 5 > # > ",
    " 9 > > > | 4 > 9 > "
]);
tracks << Tracky.create([
    " > >>> > >>  5 > 4 > ",
    " 1 >>> > >>  5 > > > ",
    " 1 >>> > >>  5 > 8 >",
    " > >>> > >>  7 > 9 > ",
    " 3 >>> > >>  6 > 7 > ",
    " 1 >>> > >>  6 > 9 > ",
    " > >>> 7 >>  > > > > ",
    " # >>> > >>  > > > >"
]);
tracks << Tracky.create([
    "> > > > > > | % ",
    " 4 > > > > > ",
    " > > 5 > > > ",
    " 9 > > 1 > >"
]);

    0 => int tempoWaitCounter;
    0 => int trackWaitCounter;
 10.0 => float baseDelta;
500.0 => float currDelta;
  0.0 => float targetDelta;
    1 => int minChange;
    4 => int maxChange;
false => int changeTempo;
    0 => float actualDelta;
  64 => int waitForChange;
  
    1 => int nextTrack;
   16 => int waitForNext;
    1 => int startedTracks;

spork ~ playTrack(e, tracks[0], 0);
spork ~ stutter();

while(true) {
    baseDelta +=> actualDelta;

    if (actualDelta >= currDelta) {
        1 +=> tempoWaitCounter;
        1 +=> trackWaitCounter;
        0  => actualDelta;

        if (trackWaitCounter == waitForNext) {
            tracks[nextTrack] @=> Tracky nt;

            spork ~ playTrack(e, nt, startedTracks);

            startedTracks++;
            nextTrack++;

            if (nextTrack >= tracks.size()) {
                1 => nextTrack;
            }

            0 => trackWaitCounter;
            Std.rand2(nt.trackLength() >> 1, nt.trackLength() << 1) => waitForNext;
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
                Std.rand2f(currDelta - (3 * baseDelta), currDelta - baseDelta) => targetDelta;
                <<< "Ramping delta to: ", targetDelta, " ms" >>>;
                true => changeTempo;
            }
        }
    }
    baseDelta::ms => now;
}