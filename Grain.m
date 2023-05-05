classdef Grain
    properties
        width 
        window 
        lifespan
        isReverse
        soundData
        fs
        grainReverb
    end
    methods
        function obj = Grain(sound,window,isReverse)
            obj.width = length(sound);
            obj.soundData = sound;
            obj.window = window;
            obj.isReverse = isReverse;
            obj.lifespan = 1;
        end
        function g = play(obj)
            if obj.lifespan == 0
                g = zeros(obj.width,1);
                return;
            end
            winInstance = obj.window(round(obj.width));
            minLength = min(length(obj.soundData), length(winInstance));
            obj.soundData = obj.soundData(1:minLength,1);
            winInstance = winInstance(1:minLength,1);
            g = obj.soundData .* winInstance;
            if obj.isReverse
                g = flip(g);
            end
            
        end
    end
end


