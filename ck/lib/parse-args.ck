public class ArgParser {
    Arg arguments[0];

    public void add(string arg) {
        Stringer.split(arg, ",") @=> string args[];

        for (0 => int i; i < args.size(); i++) {
            Arg.parse(args[i]) @=> Arg a;
            a @=> arguments[a.key];
        }
    }

    public void init(Shred sh) {
        for (0 => int i; i < sh.args(); i++) {
            add(sh.arg(i));
        }
    }

    public int isSet(string key) {
        return arguments.find(key) != 0;
    }

    public int checkFlag(string key, int defaultValue) {
        if (!isSet(key)) {
            return defaultValue;
        }
        return !arguments[key].isFlagOff();
    }

    public int checkFlag(string key) {
        return checkFlag(key, true);
    }

    public string get(string key, string default) {
        if (isSet(key)) {
            return arguments[key].getValue(default);
        }
        return default;
    }

    public string get(string key) {
        return get(key, key);
    }

    public int get(string key, int default) {
        get(key) => string val;
        if (val == key) {
            return default;
        }
        return Std.atoi(val);
    }

    public float get(string key, float default) {
        get(key) => string val;
        if (val == key) {
            return default;
        }
        return Std.atof(val);
    }

}
