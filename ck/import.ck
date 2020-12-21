me.dir() => string cwd;

// Import libs
Machine.add(cwd + "lib/stringer.ck");
Machine.add(cwd + "lib/tracky.ck");
Machine.add(cwd + "lib/tunafish.ck");

// Import chugens and chubgraphs:
Machine.add(cwd + "chugens/aging-tape.ck");
Machine.add(cwd + "chugens/percy.ck");

<<< "Imported libs @", cwd >>>;
