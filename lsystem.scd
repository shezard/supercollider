(
s.reboot;
Buffer.freeAll()
)

(
var seq = "kkkk";

var buffers;
var buffersDict;
var durations;
var durationsDict;
var expansionsDict;

// Buffers
buffersDict = Dictionary.new;

buffersDict.add(\k -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/bd/bd01.wav"));
buffersDict.add(\c -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/cp/cp01.wav"));
buffersDict.add(\s -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/sd/sd01.wav"));

// Durations
durationsDict = Dictionary.new;

durationsDict.add(\k -> 1);
durationsDict.add(\c -> 0.5);
durationsDict.add(\s -> 0.1);


// Expansions
expansionsDict = Dictionary.new;

expansionsDict.add(\k -> "kc".scramble);
expansionsDict.add(\c -> "css".scramble);

// Mapping

2.do({
	seq = seq.separate.collect({
		arg letter;
		expansionsDict[letter.asSymbol];
	}).join();
});

seq.postln;

buffers = seq.separate.collect({
	arg letter;
	buffersDict[letter.asSymbol];
});

durations = seq.separate.collect({
	arg letter;
	durationsDict[letter.asSymbol];
});

durations.postln;

SynthDef(\sampler, {
	arg buf = 0, rate = 1, amp = 1;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2);
	Out.ar(0, sig!2 * amp);
}).add;

Pdef(\pattern, {
	Pbind(
		\instrument, \sampler,
		\buf, Pseq(buffers, inf),
		\dur, Pseq(durations, inf),
		\stretch, 1,
	)
}).play;
)