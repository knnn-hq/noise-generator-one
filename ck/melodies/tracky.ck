/*
    PianoRoll.create(
        "> > > > | 5 > > > | > > 9 > | > > > > | 5 > > > | 9 > > >"
    ) @=> rollA;

    PianoRoll.create(
        "> > > > > | > > > X > | 4 > > > > | > > 5 > > | 5 > > > | 9 > > 1 > "
    ) @=> rollB;
*/
class TrackyTrack {
    0 => int position;
    0 => int trackSize;
    int track[0];

    fun int addCell(int cell) {
        track.size(trackSize + 1);
        cell => track[trackSize];
        trackSize++;
        return cell;
    }

    fun void parseTrack(string input) {
        int lastBar[0];
        int currBar[0];
        StringTokenizer st;

        st.set(input);

        while (st.more()) {
            st.next() => string t;
            t.charAt(0) => int c;

            if (c == '|') {
                int newCurrBar[0];
                currBar @=> lastBar;
                newCurrBar @=> currBar;
            } else if (c == '%') {
                for (0 => int i; i < lastBar.size(); i++) {
                    addCell(lastBar[i]);
                }
                lastBar @=> currBar;
            } else if (c == '>') {
                for (0 => int i; i < t.length(); i++) {
                    currBar << addCell(Tracky.NoteBlank);
                }
            } else if (c == '#') {
                currBar << addCell(Tracky.NoteRest);
            } else if (c >= '0' && c <= '9') {
                currBar << addCell(t.toInt());
            } else if (c >= 'a' && c <= 'z') {
                currBar << addCell(c - 'a' + 10); 
            }  
        }
    }

    fun int next() {
        track[position] => int n;

        (position + 1) % trackSize => position;

        return n;
    }

    fun int hasNext() {
        return position < trackSize;
    }

    fun void restart() {
        0 => position;
    }

    fun static TrackyTrack create(string input) {
        TrackyTrack pr;
        pr.parseTrack(input);
        pr.restart();

        return pr;
    }
    fun static TrackyTrack create(string inputs[]) {
        Stringer.join(inputs, " | ") => string input;

        return TrackyTrack.create(input);
    }
}

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
