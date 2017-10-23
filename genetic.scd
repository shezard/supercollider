(

// Params

var parentsLength = 8;
var genesLength = 8;
var scores = Array.new;
var score = 0;
var couples = Array.new;

// Funcs

var getValues = {
	arg n, weights;
	Array.series(n).collect({
		['A', 'B', 'C'].wchoose(weights);
	});
};

var getScore = {
	arg person;

	var score = 0;

	person.collect({
		arg gene;
		if(gene === 'A') {
			score = score + 2;
		};
		if(gene === 'B') {
			score = score + 1;
		};
	});

	score
};

// Initial weights

var weights = [10, 10, 10].normalizeSum;

// Initial parents

var parents;

~init = {
	parents= Array.series(parentsLength).collect({
		getValues.value(genesLength, weights);
	});

	"Initial Parents score".postln;
	parents.collect({
		arg parent;
		getScore.value(parent);
	}).postln;

	score = parents.collect({
		arg parent;
		getScore.value(parent);
	}).sum.postln;
};

~init.value();

~next = {
	arg n;

	n.do({
		// Scoring

		scores = parents.collect({
			arg parent;
			getScore.value(parent);
		}).normalizeSum;

		// Make couple

		parentsLength.do({
			var index = scores.windex;
			var parent = parents.removeAt(index);
			scores.removeAt(index);
			couples = couples.add(parent);
			couples;
		});

		// Make children

		(parentsLength / 2).do({
			arg index;
			var parentA = couples[index];
			var parentB = couples[index + 1];

			// Random split between A and B
			var midPoint = Array.series(genesLength).choose;

			// Split in the middle of A and B
			//var midPoint = (genesLength / 2 - 1).asInteger;

			var childrenA = parentA.copySeries(0, nil, midPoint) ++ parentB.copySeries(midPoint + 1, nil, genesLength);
			var childrenB = parentB.copySeries(0, nil, midPoint) ++ parentA.copySeries(midPoint + 1, nil, genesLength);

			// Random mutation
			if(rand(100) < 30) {
				"Mutating".postln;
				childrenA[Array.series(genesLength).choose] = ['A', 'B', 'C'].wchoose(weights);
			};

			parents = parents.add(childrenA);
			parents = parents.add(childrenB);
		});

		"New Parents score".postln;
		parents.collect({
			arg parent;
			getScore.value(parent);
		}).postln;

		parents.collect({
			arg parent;
			getScore.value(parent);
		}).sum.postln;

		// Cleanup

		scores = Array.new;
		couples = Array.new;

	});

	parents;
};

)

(
var freqs = Dictionary.new;
var attacks = Dictionary.new;
var sustains = Dictionary.new;
var releases = Dictionary.new;
var pans = Dictionary.new;

freqs.add('A' -> 60.midicps);
freqs.add('B' -> 64.midicps);
freqs.add('C' -> 67.midicps);

attacks.add('A' -> 1);
attacks.add('B' -> 0.1);
attacks.add('C' -> 2);

sustains.add('A' -> 2);
sustains.add('B' -> 1);
sustains.add('C' -> 0.5);

releases.add('A' -> 3);
releases.add('B' -> 1.5);
releases.add('C' -> 4.5);

pans.add('A' -> 0);
pans.add('B' -> 0.5);
pans.add('C' -> -0.5);

SynthDef(\sine, {
	arg freq = 440, attack = 1, sustain = 2, release = 3, pan = 0, amp = 1;

	var env = EnvGen.ar(Env.linen(attack, sustain, release, 0.6, \welch), doneAction: 2);

	var sig = SinOsc.ar(freq) * 0.005 * env * amp;

	sig = Pan2.ar(sig, pan);

	Out.ar(0, sig);
}).add;

SynthDef(\perc, {
	arg attack = 0.01, release = 1, amp = 1, freq = 1200;

	var env = EnvGen.ar(Env.perc(attack, release));

	var sig = SinOsc.ar(freq) * env * amp * 0.5;

	var fakeEnv = EnvGen.ar(Env.linen(0.01, 4, 0.01, 1), doneAction: 2);

	var delay = (sig
		+ DelayN.ar(sig, 0.33, Rand(0.25, 0.33), Rand(0.25, 0.5))
		+ DelayN.ar(sig, 0.66, Rand(0.5, 0.66), Rand(0.125, 0.25))
	) * fakeEnv;

	Out.ar(0, delay!2);
}).add;

~t = Task({
    loop {
		var val = ~next.value(1);

		var genes = val.choose;

		Synth(\sine, [
			\freq, freqs[genes[0]],
			\attack, attacks[genes[1]],
			\sustain, sustains[genes[2]],
			\release, releases[genes[3]],
			\pan, pans[genes[4]],
			\amp, ~mix1
		]);

		0.5.wait;

		Synth(\perc, [
			\attack, attacks[genes[5]] / 50,
			\release, releases[genes[6]] / 50,
			\amp, [sustains[genes[7]] / 5, 0].choose * ~mix2,
			\freq, freqs[genes[3]] * 2
		]);

		0.166.wait;

		Synth(\perc, [
			\attack, attacks[genes[5]] / 50,
			\release, releases[genes[6]] / 50,
			\amp, [sustains[genes[7]] / 5, 0].choose * ~mix3,
			\freq, freqs[genes[2]] * 3
		]);

		0.166.wait;

		Synth(\perc, [
			\attack, attacks[genes[5]] / 50,
			\release, releases[genes[6]] / 50,
			\amp, [sustains[genes[7]] / 5, 0].choose * ~mix4,
			\freq, freqs[genes[1]] * 5
		]);

		0.166.wait;


	};
});


// Additionnal global control for mixing

~mix1 = 1;
~mix2 = 1;
~mix3 = 1;
~mix4 = 1;

)

// Usage

~init.value();
~next.value(100);

~t.play;
~t.stop;

~mix4 = 1;