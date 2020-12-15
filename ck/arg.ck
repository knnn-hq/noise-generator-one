public class Arg {
    string key;
    "" => string value;
    0  => int state;

    fun string getValue(string default) { 
        if (hasValue()) {
            return value; 
        }
        return default;
    }
    fun string getValue() {
        return getValue(key);
    }
    fun int isFlagOff()  { 
        return (state & Arg.StateFlagOff);
    }
    fun int hasValue() {
        return (state & Arg.StateValueSet);
    }

    /**
     * Static
     */
     /// States:
    0 => static int StateDefault;
    1 => static int StateFlagOff;
    2 => static int StateValueSet;
    
    fun static int isValid(string input) {
        return input.length() > 0;
    }

    fun static Arg create(string k, string v, int s) {
        Arg a;
        k.lower() => a.key;
        v => a.value;
        s => a.state;

        return a;
    }
    fun static Arg create(string k, int s) {
        return Arg.create(k, k, s);
    }

    fun static Arg parse(string input) {
        0 => int s;
        input.trim() => string inp;

        if (inp.length() >= 2 && inp.find("=") > 0) {
            Stringer.split(inp, "=", 2) @=> string parts[];
            return Arg.create(parts[1], parts[0], s | Arg.StateValueSet);
        } else if (inp.charAt(0) == '+' || inp.charAt(0) == '-') {
            if (inp.charAt(0) == '-') {
                Arg.StateFlagOff |=> s;
            }
            inp.erase(0, 1);
        }
        return Arg.create(inp,s);
    }
}
