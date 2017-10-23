(
var stretch = 0.9;

d = Dictionary.new;

d.add(\kick -> PathName("C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/bd").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
}));

d.add(\clap -> PathName("C:/Users/Thibaut.DOM-R4D/Music/BPB Cassette 909/cassette 1/cp").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
}));

SynthDef(\bpfsaw, {
	arg atk = 2, sus = 0, rel = 3, c1 = 1, c2 = (-1), detune = 0.2, pan = 0,
	cfhzmin = 0.1, cfhzmax = 0.3,
	lsf = 200, ldb = 0,
	freq = 500, cfmin = 500, cfmax = 2000, rqmin = 0.1, rqmax = 0.2, amp = 1, out = 0;
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2,
	);

	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\sampler, {
	arg buf = 0, rate = 1, amp = 1;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2);
	Out.ar(0, sig!2 * amp);
}).add;

~chords = Pbind(
	\instrument, \bpfsaw,
	\dur, 1/4,
	\stretch, stretch,
	\midinote, Pseq([
		Pseq([40, 42, 47], 8),
		Pseq([40, 42, 48], 8),
		Pseq([40, 42, 47], 8),
		Pseq([40, 41, 49], 8),
	], inf),
	\detune, 0.08,
	\cfmin, 100,
	\cfmax, 1450,
	\atk, 0.01,
    \rel, 2,
	\lbd, 2,
	\amp, 0.75,
	\out, 0,
).play;

~chords2 = Pbind(
	\instrument, \bpfsaw,
	\dur, 4,
	\stretch, stretch,
	\midinote, Pseq([
		Pseq([40, 42, 47] - 12, 8),
		Pseq([40, 42, 48] - 12, 8),
	], inf),
	\detune, 0.01,
	\cfmin, 100,
	\cfmax, 1450,
	\atk, 4,
    \rel, 8,
	\lbd, 2,
	\amp, 0.75,
	\out, 0,
).play;

~kick = Pbind(
	\instrument, \sampler,
	\dur, 1/4,
	\stretch, stretch,
	\buf, Pseq([
		Pseq([d[\kick][0]], 8),
		Pxrand(d[\kick], 8),
	], inf),
	\amp, Pseq([0.75, 0, 0.5, 0, 0.5, 0, 0.5, 0.05], inf),
).play;


~clap = Pbind(
	\instrument, \sampler,
	\dur, Pseq([
		Pseq([1.5/8, 2.5/8], 8),
		Pseq([1/4], 8)
	], inf),
	\stretch, stretch,
	\buf, Pseq(d[\clap], inf),
	\rate, Pseq([0.75, 0.5], inf),
	\amp, Pseq([0, 0, 0.75, 0.15, 0, 0, 0.5, 0, 0, 0, 0.5, 0.15, 0, 0, 0.5, 0] * 0.25, inf),
).play;

~clap2 = Pbind(
	\instrument, \sampler,
	\dur, Pseq([1/2], inf),
	\stretch, stretch,
	\buf, Pseq(d[\clap], inf),
	\rate, Pseq([0.05, 0.1], inf),
	\amp, Pseq([1] * 0.25, inf),
).play;

)

s.boot;