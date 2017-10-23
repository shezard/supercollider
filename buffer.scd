(

d = Dictionary.new;

d.add(\kick -> PathName("C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/bd").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
}));


d.add(\hat -> PathName("C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/hh").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
}));

d.add(\ohat -> PathName("C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/oh").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
}));

d.add(\clap -> PathName("C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/cp").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
}));

SynthDef(\sampler, {
	arg buf = 0, rate = 1, amp = 1;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2);
	Out.ar(0, sig!2 * amp);
}).add;

SynthDef(\synth, {
	arg freq = 440, amp = 1;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01, 0.25), doneAction: 2);
	sig = SinOsc.ar(freq);
	Out.ar(0, sig!2 * amp * env);
}).add;

Pdef(
	\kick,
	Pbind(
		\instrument, \sampler,
		\strech, 1.875,
		\dur, Pseq([1/2], inf),
		\buf, Pseq([
			Pseq([d[\kick][0]], 1),
			Pseq([d[\kick][4]], 3)
		], inf),
		\rate, 1,
		\amp, 0.5
	)

).play;

Pdef(
	\hat1,
	Pbind(
		\instrument, \sampler,
		\strech, 1.875,
		\dur, Pseq([1.5/16, 2.5/16, 1/8, 3/8, 1/4], inf),
		\buf, Pseq(d[\hat], inf),
		\rate, 1,
		\amp, Pseq([0.15, 0.1], inf)
	)
).play;

Pdef(
	\hat2,
	Pbind(
		\instrument, \sampler,
		\strech, 1.875,
		\dur, Pseq([1/4], inf),
		\buf, Pseq(d[\ohat], inf),
		\rate, 1,
		\amp, Pseq([0.125, 0.045], inf)
	)
).play;

Pdef(
	\clap,
	Pbind(
		\instrument, \sampler,
		\strech, 1.875,
		\dur, Pseq([1.5/4], inf),
		\buf, Pseq(d[\clap], inf),
		\rate, 1,
		\amp, Pseq([0.125, 0.045], inf)
	)
).play;

Pdef(
	\psynth,
	Pbind(
		\instrument, \synth,
		\strech, 1.875,
		\dur, Pseq([1/4, 1/2, 1, 1/2], inf),
		\amp, Pseq([0.2, 0.1], inf),
		\freq, Pseq([60.midicps, 64.midicps], inf)
	)
).play;

)

Buffer.freeAll;
