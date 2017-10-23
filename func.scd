(
var func = Dictionary.new;

var buffersDict = Dictionary.new;

buffersDict.add(\kick -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/bd/bd01.wav"));
buffersDict.add(\clap -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/cp/cp01.wav"));
buffersDict.add(\snare -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/sd/sd01.wav"));
buffersDict.add(\chh -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/hh/hh01.wav"));
buffersDict.add(\chh2 -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/hh/hh02.wav"));
buffersDict.add(\ohh -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/oh/oh01.wav"));
buffersDict.add(\ohh2 -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/oh/oh02.wav"));
//buffersDict.add(\f -> Buffer.alloc(s, 100, 1));
buffersDict.add(\silence -> Buffer.alloc(s, 100, 1));

buffersDict;

func.add(\loadSynth -> {

	// Sampler

	[\kick, \clap, \snare, \chh, \chh2, \ohh, \ohh2, \silence].do({
		arg symb;

		SynthDef(symb, {
			arg rate = 1, amp = 1;
			var sig, buf = buffersDict[symb];

			sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2);

			Out.ar(0, sig!2 * amp);
		}).add;
	});

	//Silence

	SynthDef(\silence, {
			arg rate = 1, amp = 1;
			var sig, buf = buffersDict[\silence];

			sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2);

			Out.ar(0, sig!2 * amp);
		}).add;

	// Sine

	SynthDef(\sine, {
		var sig, freq = Rand(1250, 2060);

		var env = EnvGen.ar(Env.perc(0.01, Rand(0.05, 0.125)), doneAction: 2);

		sig = SinOsc.ar(XLine.kr(freq, freq + 5000, 0.1)) * env * 0.125;

		sig = Pan2.ar(sig, LFNoise0.ar(50).range(-1, 1));

		Out.ar(0, sig);
	}).add;

});

func.add(\getInstruments -> {
	var instrumentsDict = Dictionary.new;

	instrumentsDict.add(\d -> \sine);
	instrumentsDict.add(\k -> \kick);
	instrumentsDict.add(\c -> \clap);
	instrumentsDict.add(\s -> \snare);
	instrumentsDict.add(\h -> \chh);
	instrumentsDict.add(\i -> \chh2);
	instrumentsDict.add(\o -> \ohh);
	instrumentsDict.add(\j -> \ohh2);
	instrumentsDict.add(\f -> \silence);
	instrumentsDict.add(\silence -> \silence);

	instrumentsDict;
});

func.add(\getExpanded -> {
	arg seq, expansionsDict, n = 3;

	n.do({
		seq = seq.separate.collect({
			arg letter;
			block { |break|
				var nextValue = expansionsDict[letter.asSymbol].value;
				if(nextValue.isNil) { // If not in expansionsDict, leave the letter alone
					break.value(letter);
				};
				break.value(nextValue);
			}
		}).join();

		seq.postln;
	});

	seq;
});

func.add(\getTree -> {
	arg seq;

	var n = 0;
	var isNested = false;
	var tree = List.new;

	seq.do({
		arg letter, index;

		if(letter.asString == "(") {
			n = tree.size;
			isNested = true;
			tree.add(List.new);
		};

		if(letter.asString == ")") {
			isNested = false;
		};

		if((letter.asString != "(") && (letter.asString != ")")) {
			if(isNested == false) {
				tree.add(letter);
			} {
				tree.at(n).add(letter);
			};
		};
	});

	tree;
});

func;
)