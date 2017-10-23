(
s.reboot;
Buffer.freeAll()
)

(

var seq = "dd";
var tree = List.new;

var tracksNumber = 3;

var isNested = false;

var bufferIndex = 0;
var buffers = Array.fill(tracksNumber, {List.new});

var buffersDict;
var expansionsDict;

// Prepare instruments

var instruments = Array.fill(tracksNumber, {List.new});
var instrumentsDict;

var speed = 6;//5;
var speeds = [4, 2, 1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128, 1/256];

var patternSpeeds = List.new;

// Buffers

buffersDict = Dictionary.new;

buffersDict.add(\k -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/bd/bd01.wav"));
buffersDict.add(\c -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/cp/cp01.wav"));
buffersDict.add(\s -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/sd/sd01.wav"));
buffersDict.add(\h -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/hh/hh01.wav"));
buffersDict.add(\i -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/hh/hh02.wav"));
buffersDict.add(\o -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/oh/oh01.wav"));
buffersDict.add(\j -> Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/oh/oh02.wav"));
buffersDict.add(\f -> Buffer.alloc(s, 100, 1));
buffersDict.add(\silence -> Buffer.alloc(s, 100, 1));

// Instruments

instrumentsDict = Dictionary.new;

instrumentsDict.add(\k -> \kick);

// Expansions
expansionsDict = Dictionary.new;

expansionsDict.add(\d -> {
	"k"
});


// Parsing

3.do({
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

// Nest structure

n = 0;

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

tree.postln;

// Handle buffers / durations

tree.do({
	arg item;

	if(item.class == Char) {
		if(item.asString == "+") {
			speed = speed + 1;
		};

		if(item.asString == "-") {
			speed = speed - 1;
		};

		if((item.asString != "-") && (item.asString != "+")) {
			var toFill = Array.series(tracksNumber - 1, 1);

			instruments[0].add(instrumentsDict[item.asSymbol]);

			toFill.do({
				arg index;
				instruments[index].add(instrumentsDict[\silence]);
			});

			patternSpeeds.add(speeds[speed]);
		}

	} {
		var toFill = Array.series(tracksNumber - item.size, item.size);

		item.do({
			arg item, index;

			if((item.asString != "-") && (item.asString != "+")) {
				instruments[index].add(instrumentsDict[item.asSymbol]);
			};
		});

		toFill.do({
			arg index;
			instruments[index].add(instrumentsDict[\silence]);
		});

		patternSpeeds.add(speeds[speed]);
	};
});

patternSpeeds.postln;

// Instruments

SynthDef(\kick, {
	arg buf = 0, rate = 1, amp = 1;
	var sig;

	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buffersDict[\k]) * rate, doneAction: 2);

	Out.ar(0, sig!2 * amp);
}).add;

// Patterns

tracksNumber.do({
	arg index;

	var pattern = "pattern" ++ index;

	if(buffers[index].array.size > 0) {
		Pdef(pattern.asSymbol, {
			Pbind(
				\instrument, instrumentsDict[index]
			)
		}).play;
	}
});

)
