ArgParser arg;
arg.init(me);

if (!arg.isSet("filename")) {
    <<< "Usage:" >>>;
    <<< "\tchuck looper.ck:<load=filename>[,rate=0.5][,gain=0.6][,res=100]" >>>;

    me.exit();
}

arg.get("load") => string filename;
arg.get("rate", 0.5) => float endRate;
arg.get("gain", 0.6) => float gain;
arg.get("res", 100) => float res;


// the patch 
SndBuf buf => dac;

// load the file
filename => buf.read;
gain => buf.gain;

// time loop
while (true) {
    if (buf.rate >= endRate) {
        buf.rate * 0.99 => buf.rate;
    }
    res::ms => now;
}
