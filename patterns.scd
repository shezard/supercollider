(
~reverbBus = Bus.audio(s, 2);

~sourcesGroup = Group.new;
~fxGroup = Group.after(~sourcesGroup);

SynthDef(\kick, {
	arg amp = 1;
	var env = EnvGen.ar(Env.perc(0.01, 0.25, amp), doneAction: 2);
	var sig = SinOsc.ar(125) * env;
	Out.ar(0, sig!2);
}).add;

SynthDef(\fm, {
	arg amp = 1, t_trig = 0, modFreq = 120, freq = 440;

	var modEnv = EnvGen.ar(Env.perc(0.01, 0.25, amp));
	var sigEnv = EnvGen.ar(Env.perc(0.01, 0.5, amp), doneAction: 2);

	var mod = SinOsc.ar(modFreq) * modEnv;
	var sig = SinOsc.ar(freq * mod) * sigEnv;

	Out.ar(0, sig);
}).add;

SynthDef(\hat, {
	arg amp = 0.125;

	var lfo = SinOsc.kr(0.1) * 0.25 + 0.25;

	var env = EnvGen.ar(Env.perc(0.01, lfo, amp), doneAction: 2);

	var sig = PinkNoise.ar() * env;

	Out.ar(0, [sig, sig]);
}).add;

SynthDef(\hat2, {
	arg amp = 0.125, t_trig = 0;

	var lfo = SinOsc.kr(0.1, phase: 0.5) * 0.25;

	var env = EnvGen.ar(Env.perc(0.01, lfo, amp), t_trig);

	var lfo2 = (SinOsc.kr(0.05) + 1) * 0.75 + 0.5;

	var sig = Crackle.ar(lfo2) * env;

	Out.ar(0, [sig, sig]);
}).add;

SynthDef(\pad, {
	arg gate = 0, freq = 480, out = 0;

	var env = EnvGen.ar(Env.adsr(2, 2, 0.5, 2), gate) * 0.1;

	var sig  = SinOsc.ar([freq, freq + 10]) * env;
	var sig2 = SinOsc.ar([freq + 280, freq + 290]) * env;
	var sig3 = SinOsc.ar([freq + 680, freq + 690]) * env;

	var pan = Pan2.ar(sig3, SinOsc.kr(3)) * 0.5;

	var mix = Mix.ar([sig, sig2, pan]);

	Out.ar(out, mix);
}).add;


SynthDef(\verb,{
	arg in, out = 0;
	var sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, room: 0.9, damp: 0.7, mul: 1);
	Out.ar(out, sig);
}).add;

SynthDef(\wavy, {
	arg gate = 0, freq = 40;

	var env = EnvGen.ar(Env.adsr(2,0,1,2), gate);

	var temp;
	var sum = 0;

	10.do({
		temp = VarSaw.ar(
			freq * {Rand(0.99,1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.0005, 0.05)}!2
		);

		sum = sum + temp;
	});

	sum = sum * 0.025 * env;
	Out.ar(0, sum);

}).add;

/*a = Synth(\kick, [\amp, 0.5], target: ~sourcesGroup);
b = Synth(\fm, [\amp, 0.5], target: ~sourcesGroup);
c = Synth(\hat, target: ~sourcesGroup);
d = Synth(\pad, [\out, ~reverbBus], target: ~sourcesGroup);
e = Synth(\hat2, target: ~sourcesGroup);
f = Synth(\wavy, target: ~sourcesGroup);*/

g = Synth(\verb, [\in, ~reverbBus], target: ~fxGroup);


Pdef(\pkick,
	Pbind(
		\instrument, \kick,
		\dur, Pseq([1/2], inf),
		\strech, 1.875,
		\group, ~sourcesGroup
	);
).play;

Pdef(\pfm,
	Pbind(
		\instrument, \fm,
		\dur , Pseq([1/1], inf),
		\freq, Prand([440, 880], inf),
		\modFreq, Prand([120, 240, 460], inf),
		\strech, 1.875,
		\group, ~sourcesGroup
	);
).play;

Pdef(\phat,
	Pbind(
		\instrument, \hat,
		\dur , Prand([1/4, 1/6, 1/2], inf),
		\strech, 1.875,
		\group, ~sourcesGroup
	);
).play;

Pdef(\ppad,
	Pbind(
		\instrument, \pad,
		\freq, Prand([480, 720, 960], inf),
		\dur , Prand([3, 6], inf),
		\strech, 1.875,
		\group, ~sourcesGroup,
		\out, ~reverbBus
	);
).play;

)