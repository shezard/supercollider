MIDIClient.init;

~mOut = MIDIOut.new(0);

(
var seed = 48;
var degrees, deg;
var length = Pseq([4, 3], inf).asStream;
var dur = length.next();
var bars = 25;
var quant = 16;
var notes = [];
var loop = [];
var pos = [];
var next = 0;
var patterns;

degrees = [];

//Building the MIDI values for the white keys

9.do({|i|
degrees = degrees++([0, 2, 4, 5, 7, 9, 11] + (12*i));
});

//Starting notes from the seed

deg = Pseq(degrees, inf, degrees.indexOf(seed)).asStream;


(bars * quant).do({|i|
  var note;

    if((i%quant == 0) && (notes != []),
    {
     loop = loop.add(notes);
     notes = [];
    });

    if((i%quant == next) && (pos.includes(next) == false),{
      notes = notes.add([deg.next(), dur/4]);
      pos = pos.add(next);
      next = (next + dur)%quant;
    });

    if ( (i%quant == next) && (pos.includes(next) == true),{
     dur = length.next();
     notes = notes.add([deg.next(), dur/4]);
     next = (next + dur)%quant;
    });

   });

  loop.do({|patt, i|
      patt.postln;
      patterns = patterns++([i * 4, Pbind(*[\type,\midi,\chan,0,
         \midiout,~mOut,
        [\midinote, \dur]: Pseq(patt, inf),
        \legato: 1,
            \amp: rrand(0.1,0.5)])]);
      });

  Ptpar(patterns, 1).trace.play;
)