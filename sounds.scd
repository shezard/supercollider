(

~b0 = Buffer.read(s, "C:/Users/Thibaut.DOM-R4D/Music/Twin-Peaks-2017-The-Monica-Bellucci-dream.wav");

SynthDef(\vocal, {
	arg rate = 1, amp = 1, buf, start = 1, length = 1;
	var sig;

	var env = EnvGen.ar(Env.linen(0.01, length, 0.01), doneAction:2);

	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: start) * env;

	Out.ar(0, sig!2 * amp);
}).add;


SynthDef(\sineslow, {
	arg freq;

	var env = EnvGen.ar(Env.linen(rrand(0.01,0.1),0,rrand(10, 15),1, \sine));
	var sig = SinOsc.ar(rrand(freq, freq + 200)!2) * 0.05 * env;

	Out.ar(0, sig)
}).add;

SynthDef(\sinefast, {
	arg freq;

	var env = EnvGen.ar(Env.perc(0.01,0.5), doneAction: 2);
	var sig = SinOsc.ar(rrand(freq, freq + 20)!2) * 0.05 * env;

	sig = FreeVerb2.ar(sig[0], sig[1]);

	Out.ar(0, sig)
}).add;


~t = Task({
    loop {
		var note = Scale.melodicMinorDesc.degrees[0..3].choose;

		Synth(\sinefast, [
			\freq, (note + 72).midicps
		]);
		rrand(0.125, 0.133).wait;
	};
});

~u = Task({
	loop {
		var note = Scale.melodicMinorDesc.degrees[0..3].choose;

		Synth(\sinefast, [
			\freq, (note + 60).midicps
		]);
		rrand(0.250, 0.266).wait;
	};
});

~v = Task({
	loop {
		var note = Scale.melodicMinorDesc.degrees[0..3].choose;

		Synth(\vocal, [
			\buf, ~b0,
			\start, 3966592,
			\length, 2,
			\amp, 0.25,
			\rate, [-1, 1, 2, -2].choose;
		]);
		1.wait;
	};
});

)


~t.play(quant: TempoClock.default.beats);
~u.play(quant: TempoClock.default.beats);
~v.play(quant: TempoClock.default.beats);

~t.stop;
~u.stop;
~v.stop;

Scale.directory;
Tuning.directory;

~b0.numFrames;

Buffer