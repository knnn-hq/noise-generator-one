/*
    PianoRoll.create(
        "> > > > | 5 > > > | > > 9 > | > > > > | 5 > > > | 9 > > >"
    ) @=> rollA;

    PianoRoll.create(
        "> > > > > | > > > X > | 4 > > > > | > > 5 > > | 5 > > > | 9 > > 1 > "
    ) @=> rollB;
*/
public class PianoRoll {
    0 => int position;
    0 => int trackSize;
    int track[0];

    fun void addCell(int cell) {
        track.size(trackSize + 1);
        cell => track[trackSize];
        trackSize++;
    }

    fun void parseTrack(string input) {
        StringTokenizer st;
        st.set(input);

        while (st.more()) {
            st.next() => string t;
            if (t == ">") {
                addCell(PianoRoll.CellContinue);
            } else if (t == "X") {
                addCell(PianoRoll.CellRest);
            } else {
                t.toInt() => int n;
                if (n > 0) {
                    addCell(n);
                }
            }
        }
    }

    fun int next() {
        track[position] => int n;
        (position + 1) % trackSize => position;

        return n;
    }

    fun void restart() {
        0 => position;
    }

     0 => static int CellContinue;
    -1 => static int CellRest;

    fun static PianoRoll create(string input) {
        PianoRoll pr;
        pr.parseTrack(input);

        return pr;
    }
}