//require("internal/tracky-track.ck")

public class Tracky {
    1   => int skipWhenRemixing;
    string sourceTrack[];
    TrackyTrack roll;

    fun int nextNote() {
        if (!roll.hasNext() && (skipWhenRemixing >= 0)) {
            remix();    
        }
        return roll.next();
    }

    fun int trackLength() {
        return roll.trackSize;
    }

    fun void remix() {
        if (sourceTrack.size() <= skipWhenRemixing) {
            return;
        }
        int added[0];
        string newTrack[0];
        
        for (skipWhenRemixing => int i; i < sourceTrack.size(); i++) {
            int randIndex;
            string randIndexName;
            do {
                Std.rand2(1, sourceTrack.size() - 1) => randIndex;
                "k-" + Std.itoa(randIndex) => randIndexName;
            } while (added.find(randIndexName) > 0);
            newTrack << sourceTrack[randIndex];
            true => added[randIndexName];
        }

        TrackyTrack.create(newTrack) @=> roll;
    }

    fun static Tracky create(int remixSkip, string track[]) {
        Tracky tr;
        track @=> tr.sourceTrack;
        remixSkip => tr.skipWhenRemixing;

        TrackyTrack.create(track) @=> tr.roll;

        return tr;
    }
    fun static Tracky create(string track[]) {
        return Tracky.create(1, track);
    }

    0 => static int NoteBlank;
    -1 => static int NoteRest;
}
