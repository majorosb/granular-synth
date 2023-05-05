classdef Granulator_plugin < audioPlugin
    
    properties

        Grain_window = Window.hamming
        Grain_width = 3
        Grain_spread = 1
        Grain_num = 5
        Sweep_speed = 0.1
        Random_size = 0.4
        filter = 100
        isReverse = false
        Pitch = 0
        sampleFrame
        out_temp
        in_temp
        fs
        c
        gr
        i = 0
        Gain = 0.5

    end
       
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',1,...
            'PluginName','Granulator',...
            'VendorName', '', ...
            'VendorVersion', '3.1.4', ...
            'UniqueId', '4pvx',...
            audioPluginParameter('Grain_num','DisplayName','Grains',...
            'Mapping',{'int',1 20},'Style','rotaryknob','Layout',[3 1]),...
            audioPluginParameter('Grain_spread','DisplayName','Spread',...
            'Mapping',{'lin',0.5 1.5},'Style','rotaryknob','Layout',[1 1]),...
            audioPluginParameter('Grain_width','DisplayName','Width',...
            'Mapping',{'lin', 1 20},'Style','rotaryknob','Layout',[1 2]),...
            audioPluginParameter('isReverse','DisplayName','Playback',...
            'Mapping',{'enum','Forward', 'Backward'},'Style','vtoggle','Layout',[3 2]), ...
            audioPluginParameter('Random_size','DisplayName','Scan size',...
            'Mapping',{'lin', 0.01 2},'Style','rotaryknob','Layout',[1 3]),...
             audioPluginParameter('Sweep_speed','DisplayName','Scan speed',...
            'Mapping',{'lin', 0 0.3},'Style','rotaryknob','Layout',[3 3]),...
            audioPluginParameter('Pitch','DisplayName','Pitch',...
            'Mapping',{'int', -5 5},'Style','rotaryknob','Layout',[5 1],'Label','semitone'), ...
             audioPluginParameter('Grain_window','DisplayName','Window Type',...
            'Mapping',{'enum','Hamming','Rect','Triangle','Gauss','Chebisev', ...
            'Flattop','Kaiser'},'Style','dropdown','Layout',[5 3]), ...
            audioPluginGridLayout('RowHeight', [100 100 100 100 100 20], ...
            'ColumnWidth', [100 100 100 100], 'Padding', [10 10 10 30]), ...
            'BackgroundImage', audiopluginexample.private.mwatlogo);
    end
    
    
    methods
        function obj = Granulator_plugin
            % Inicializalas
            fs = getSampleRate(obj);
            obj.fs = fs;
            obj.c = Composer('Samples\Pad.wav',obj.Grain_num,fs*8);
            obj.c.grainSpread = obj.Grain_spread;
            obj.c.buffer = zeros(fs,1);
            obj.c.sweepSpeed = 1;
            obj.c.random_size = 1.2;
            
            obj.gr = Grain(zeros(1025,1),@hamming ...
                                ,obj.isReverse);
            obj.gr.width  = fs/obj.Grain_width;

            obj.out_temp = [];
            obj.in_temp = [];
        end
        
        function out = process(obj, x)
            obj.i = length(x)+obj.i;
            
            obj.gr.width = obj.fs/obj.Grain_width;
            obj.gr.isReverse = obj.isReverse;
            obj.gr.window = obj.choose_win(obj.Grain_window);
                
            obj.c.maxGrains = obj.Grain_num;
            obj.c.grainSpread = obj.Grain_spread;
            obj.c.sweepSpeed = obj.Sweep_speed;
            obj.c.random_size = obj.Random_size;
            
            if obj.i > obj.fs-10000
                obj.c = obj.c.generateGrains(obj.gr);
                obj.out_temp = obj.c.playGrains(obj.Pitch);  
                obj.i = 0;
            end
            out = obj.playSound(length(x));
        end

        function o = playSound(obj,frame)
            if isempty(obj.out_temp)
                o = zeros(frame,1);
            else
                o = obj.out_temp(1:frame,1);
                obj.out_temp = obj.out_temp(frame:end,1);
            end
        end

        function win = choose_win(~,winIn)
            switch (winIn)
                case Window.hamming
                    win = @hamming;
                case Window.rectwin
                    win = @rectwin;
                case Window.triang
                    win = @triang;
                case Window.gausswin
                    win = @gausswin;
                case Window.chebwin
                    win = @chebwin;
                case Window.flattopwin
                    win = @flattopwin;
                case Window.kaiser
                    win = @kaiser;
                otherwise
                    win = @hamming;
            end
        end

    end
end
