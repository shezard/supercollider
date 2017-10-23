(
var t2;
var u2;
var v2;
var w2;
var x2;
var y2;
var z2;

~reverbBus = Bus.audio(s, 2);

~sourcesGroup = Group.new;
~fxGroup = Group.after(~sourcesGroup);

SynthDef(\kick, {
	arg amp = 1, t_trig;
	var env = EnvGen.ar(Env.perc(0.01, 0.25, amp), t_trig);
	var sig = SinOsc.ar(125) * env;
	Out.ar(0, [sig, sig]);
}).add;

SynthDef(\fm, {
	arg amp = 1, t_trig = 0, modFreq = 120, freq = 440;

	var modEnv = EnvGen.ar(Env.perc(0.01, 0.25, amp), t_trig);
	var sigEnv = EnvGen.ar(Env.perc(0.01, 0.5, amp), t_trig);
	var verbEnv = EnvGen.ar(Env.perc(0.1, 4, amp), t_trig);

	var mod = SinOsc.ar(modFreq) * modEnv;
	var sig = SinOsc.ar(freq * mod) * sigEnv;

	var verb = FreeVerb2.ar(sig, sig, room: 0.9, damp: 0.7, mul: 0.75) * verbEnv;

	Out.ar(0, verb);
}).add;

SynthDef(\hat, {
	arg amp = 0.125, t_trig = 0;

	var lfo = SinOsc.kr(0.1) * 0.25 + 0.25;

	var env = EnvGen.ar(Env.perc(0.01, lfo, amp), t_trig);

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

a = Synth(\kick, [\amp, 0.5], target: ~sourcesGroup);
b = Synth(\fm, [\amp, 0.5], target: ~sourcesGroup);
c = Synth(\hat, target: ~sourcesGroup);
d = Synth(\pad, [\out, ~reverbBus], target: ~sourcesGroup);
e = Synth(\hat2, target: ~sourcesGroup);
f = Synth(\wavy, target: ~sourcesGroup);

g = Synth(\verb, [\in, ~reverbBus], target: ~fxGroup);

t = TempoClock(1); // 60 bpm
u = TempoClock(2); // 120 bpm
v = TempoClock(4); // 240 bpm
w = TempoClock(1); // 60 bpm
x = TempoClock(4); // 240 bpm
y = TempoClock(0.5); // 30 bpm;

t.schedAbs(0, {
	a.set(\t_trig, 1);
	1
});
u.schedAbs(0, {
	b.set(\freq, [440, 880].choose);
	b.set(\modFreq, [120, 240, 460].choose);
	b.set(\t_trig, 1);
	1
});

v.schedAbs(2, {
	c.set(\t_trig, 1);
	[1,3,5].choose;
});

w.schedAbs(3, {
	d.set(\freq, [480, 720, 960].choose);
	d.set(\gate, [0, 1].choose);
	[3, 6].choose;
});

x.schedAbs(2.5, {
	e.set(\t_trig, 1);
	1.5
});

y.schedAbs(12, {
	f.set(\gate, [0, 1, 1].choose);
	f.set(\freq, [24, 24,26,27].choose.midicps);
	1
});
)
