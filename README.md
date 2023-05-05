# granular-synth
This is a synchron granular implementation, but bear in mind it was just to joke around with the Matlab audio bench and never meant to be a full fledged synth. 
I mainly borrowed ideas from the Tasty Chips Electronics GR-1 granular synth.
In order to run this you need to install the Audio Toolbox Matlab library.

You can test the synth with simply running Test_granular_plugin.m.
Alternatively you can run it with Matlab's audio test bench.
```
plugin = Granulator_plugin;
audioTestBench(plugin);
```
If you want to change the sample that you granulate, you can by modifying the `Granulator_plugin.m` at line 64.
```
obj.c = Composer('Samples\MySample.wav',obj.Grain_num,fs*8);
```



