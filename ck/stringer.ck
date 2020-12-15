public class Stringer {
    fun static string join(string strs[], string sep) {
        "" => string result;
        for (0 => int i; i < strs.size(); i++) {
            if (i > 0) {
                "," +=> result;
            }
            strs[i] +=> result;
        }
        return result;
    }

    fun static string[] split(string str, string sep, int max) {
        string res[0];
        0 => int found;
        str => string curr;
        curr.rfind(sep) => int currInd;

        while (currInd >= 0 && (max < 0 || found < max)) {
            found++;

            if (currInd < curr.length() - 1) {
                res << curr.substring(currInd + 1, curr.length() - currInd - 1);
            } else {
                res << "";
            }
            curr.erase(currInd, curr.length() - currInd);
            curr.rfind(sep) => currInd;
        }
        if (curr.length() > 0) {
            res << curr;
        }

        return res;
    }

    fun static string[] split(string str, string sep) {
        return Stringer.split(str, sep, -1);
    }

    fun static int contains(string source, string strtofind) {
        return source.find(strtofind) >= 0;
    }

    fun static int endsWith(string source, string suffix) {
        source.length() => int a;
        suffix.length() => int b;
        return (a >= b) && source.substring(a - b, b - 1) == suffix;
    }

    fun static int startsWith(string source, string prefix) {
        source.length() => int a;
        prefix.length() => int b;
        return (a >= b) && source.substring(0, b - 1) == prefix;
    }
}
