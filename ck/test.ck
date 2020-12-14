StringTokenizer tok;
<<< tok >>>;
for( int i; i < me.args(); i++ )
{
    tok.set(me.arg(i));
    while (tok.more()) {
        <<< tok.next(), "" >>>;
    }
}
