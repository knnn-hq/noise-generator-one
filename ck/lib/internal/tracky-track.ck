//require("../stringer.ck")

public class TrackyTrack {
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
                    currBar << addCell(0);
                }
            } else if (c == '#') {
                currBar << addCell(-1);
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

