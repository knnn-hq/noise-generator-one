if( !me.args() ) {
    <<<"chuck looper.ck:<filename>:[rate]">>>
    me.exit();
}

me.arg(0) => string filename;
0.5 => float endRate;

if (me.numArgs() > 1) {
    me.arg(1) => endRate;
}

// the patch 
SndBuf buf => dac;

// load the file
filename => buf.read;

// time loop
while( true )
{
 //   0 => buf.pos;
    Math.random2f(.2,.5) => buf.gain;

    if (buf.rate >= endRate) {
        buf.rate * 0.99 => buf.rate;
    }
    100::ms => now;
}
