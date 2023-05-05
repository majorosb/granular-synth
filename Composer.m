classdef Composer
    properties
        sample
        sampleLength
        fs
        grains
        maxGrains
        buffer         %Might be needed for live playing
        bufferSize 
        buff_pos
        position
        position_live
        random_size
        sweepSpeed
        grainSpread
        out
    end
    
    methods 
        function obj = Composer(sample,maxGrains,bufferSize)
            
            %[obj.sample,obj.fs] = audioread(sample);
            afr = dsp.AudioFileReader(sample);
            obj.sample = zeros(afr.SampleRate,1);
            c = zeros(afr.SampleRate,1);
            while ~isDone(afr)
                audio = afr();
                temp_c = cat(1,c,audio(1:end,1));
                c = temp_c;
            end
            obj.sample = c;
            obj.fs = afr.SampleRate;
            release(afr);
            
            %soundsc(obj.sample,obj.fs);
            obj.sampleLength = length(obj.sample);
            obj.maxGrains = maxGrains;
            obj.grainSpread = 0.7;
            
            obj.position = 1;
            obj.buff_pos = 1;
            obj.sweepSpeed = 0.1;
            obj.random_size = 1;

            obj.bufferSize = bufferSize;
            obj.buffer = zeros(bufferSize,1);

            obj.grains = [];
            obj.out = [];
        end

        function obj = makeGrain(obj,grain,isLive)
            arguments
                obj Composer
                grain Grain
                isLive logical
            end
            if isLive
                audio = obj.buffer(1:end,1);
            else
                audio = obj.sample(1:end,1);
            end
            if obj.position < obj.random_size * obj.fs+1
                randpos = randi([obj.position ...
                    floor(obj.position+obj.random_size*obj.fs)]);
            else
                randpos = randi([floor(obj.position-obj.random_size*obj.fs) ...
                    floor(obj.position + obj.random_size*obj.fs)]);
            end

            if isLive
                if randpos+grain.width-1 > length(obj.buffer)
                    sound = obj.buffer(end-round(grain.width):end-1,1);
                else
                    sound = audio(randpos:randpos+round(grain.width)-1,1);
                end
            else
                if randpos+grain.width-1 > length(obj.sample)
                    sound = obj.sample(end-round(grain.width):end-1,1);
                else
                    sound = audio(randpos:randpos+round(grain.width)-1,1);
                end
            end
            grain.soundData = sound;
            obj.grains = [obj.grains,grain];
            obj.out = grain.play();
            return;
        end

        function playsound(obj,grain)
            obj = makeGrain(obj,grain,false);
            sound = obj.out;
            soundsc(sound,obj.fs)
        end

        function out_sound = playGrains(obj,semitone)
            out_sound = zeros(obj.fs,1);
            pos = 1;
            
            for grain = obj.grains
                
                grain_sound = grain.play();
                grain_sound = shiftPitch(grain_sound, semitone);
                if(pos + ceil(length(grain_sound)* ...
                        obj.grainSpread) > obj.fs)
                    pos = 1;
                end
                curr_pos = pos:pos+length(grain_sound)-1;
                out_sound(curr_pos+1) = grain_sound;
                pos = pos + ceil(length(grain_sound)*obj.grainSpread);
            end
        end


        function obj = generateGrains(obj,grain)
            obj.grains = [];
            for i=1:obj.maxGrains
                obj = obj.makeGrain(grain,false);
                obj.position = obj.position + ceil(obj.sweepSpeed * obj.fs);
                if obj.position > length(obj.sample)
                    obj.position = 1;
                end
            end
        end

        function obj = fill_buff(obj,in)
            remaining = obj.bufferSize - obj.buff_pos;
            if length(in) > remaining
                display(remaining);
                obj.buffer(obj.buff_pos:obj.buff_pos+remaining-1,1) = in(1:remaining,1);
                new_beg = length(in) - remaining;
                obj.buffer(1:new_beg+1,1) = in(remaining:end,1);
                obj.buff_pos = remaining;
            else
                obj.buffer(obj.buff_pos:obj.buff_pos + length(in(1:end,1))-1,1) = in(1:end,1);
                obj.buff_pos = obj.buff_pos + length(in)+1;
            end
        end
        function [obj,sound] = get_live_sound(obj,frame)
            if isempty(obj.out)
                sound = zeros(frame,1);
            else
                sound = obj.out(1:frame,1);
                obj.out = obj.out(frame:end,1);
            end
        end

        function obj = generateGrains_live(obj,grain)
            for i=1:obj.maxGrains
                obj = obj.makeGrain(grain,true);
                obj.position = obj.position + ceil(obj.sweepSpeed * obj.fs);
                if obj.position > length(obj.buffer)
                    obj.position = 1;
                end
            end
        end

    end
end
