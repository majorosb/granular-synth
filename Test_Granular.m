%c = Composer('vcv/Sine_wave.002.wav',10,1);
c = Composer(['Samples/Pad.wav'],20,44100);
%c = Composer('Samples/Pad.wav',20,1);
%c = Composer('fixed.wav',30,1);
% windows: @flattopwin @gausswin @barthannwi @chebwin @tukeywin @rectwin
% @kaiser works pretty well
gr = Grain([],@hamming ...
    ,false);
gr.width = c.fs/5;
c.grainSpread = 0.8;
c.sweepSpeed = 0.01;
c.random_size = 1.2;
out = c.playGrains(0);
disp(out);
reverb = reverberator();
sound = [];
[s,ccs] = audioread('Samples/Pad.wav');
s = s(1:end,1);
for i=1:6
    c = c.generateGrains(gr);
    out = c.playGrains(0);
    sound = [sound;out];
end


%reverb(out);




%soundsc(sound,c.fs);