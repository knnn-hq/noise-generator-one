public class ArgParser
{
    int numArgs;
    string arguments[];

    static fun string[] split(string str, string sep, int max) {
        string res[];
        0 => int found;
        str => string curr;
        curr.rfind(sep) => int currInd;

        while (currInd >= 0 && (max < 0 || found < max)) {
            found++;
            res << curr.substring(currInd + 1, curr.length() - currInd - 1);
            curr.erase(currInd, curr.length() - currInd);
            curr.rfind(sep) => currInd;
        }

        return res;
    }
    static fun string[] split(string str, string sep) {
        return ArgParser.split(str, sep, -1);
    }
    string fun string[] findAll(string str, string[] needles) {
        string res[];

        for (0 => int i; i < needles.size(); i++) {
          str.find(needles[i]) => res[needles[i]];
        }
        return res;
    }

    fun void addArg(string label, string value) {
      value => arguments[label];
    }
    fun void addArg(string arg, int labelEnd, string value) {
      addArg(arg.substring(0, labelEnd), value);
    }
    fun void addArg(string arg, int labelEnd) {
      addArg(arg, labelEnd, arg.substring(labelEnd + 1, arg.length() - labelEnd));
    }

    fun void parseArgs(string[] args) {
        for (0 => int i; i < me.numArgs(); i++) {
            ArgParser.split(me.args(i), ",") => string[] currArgs;

            for (0 => int j; j < currArgs.size(); j++) {
                currArgs[j] => string currArg;
                ArgParser.findAll(currArg, "=", "-off", "-on") => string f[];

                if (f["="] >= 0) {
                    addArg(currArg, f["="]);
                } else if (f["-off"] >= 0) {
                    addArg(currArg, f["-off"], "false");
                } else if (f["-on"] >= 0){
                    addArg(currCarg, f["-on"], "true");
                } else {
                    addArg(currArg, "true");
                }
            }
        }
    }
}
