{
	var wn = WhiteNoise.ar(SinOsc.kr(0.0125));
	var sn = SinOsc.ar(1200);

	Mix([wn, sn])
}.play;