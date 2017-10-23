(
s.reboot;
Buffer.freeAll()
)

(
// Import external functions

var fn = "C:/Users/Thibaut.DOM-R4D/SC/func.scd".loadPaths[0];

//var seq = "(kx)kk(kxc)kk(kxs)+kx"; 4
//var seq = "--k(ks)+++kffkffkf---(ks)"; 4
//var seq = "(ko)hhh(kos)hhh+(ko)ff(kh)ff(kh)f-(kos)hhh"; 5
var seq = "kkkk";
var tree = List.new;
var tracksNumber = 3;

var loaded = fn[\loadSynth].value();

// Load instruments;

var instrumentIndex = 0;
var instruments = Array.fill(tracksNumber, {List.new});
var instrumentsDict = fn[\getInstruments].value();

// Prepare playback speeds

var speed = 5;
var speeds = [4, 2, 1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128, 1/256];
var patternSpeeds = List.new;

// Expansions
var expansionsDict = Dictionary.new;

expansionsDict.add(\k -> {
	"(kd)++(dh)ffif--"
});

// Expand sequence

seq = fn[\getExpanded].value(seq, expansionsDict, 3);

// Nest structure

tree = fn[\getTree].value(seq);

tree.postln;

// Handle instruments / durations

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

instruments.postln;
patternSpeeds.postln;

// Patterns

tracksNumber.do({
	arg index;

	var pattern = "pattern" ++ index;

	if(instruments[index].array.size > 0) {
		Pdef(pattern.asSymbol, {
			Pbind(
				\instrument, Pseq(instruments[index], inf),
				\dur, Pseq(patternSpeeds.array, inf),
				\stretch, 1.875,
			)
		}).play;
	}
});

)