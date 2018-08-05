classdef TuftViztry < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        ChooseimagefileButton          matlab.ui.control.Button
        VideoformatssupportedDropDownLabel  matlab.ui.control.Label
        VideoformatssupportedDropDown  matlab.ui.control.DropDown
        VideofilesDropDownLabel        matlab.ui.control.Label
        VideofilesDropDown             matlab.ui.control.DropDown
        ImageButton                    matlab.ui.control.Button
        VideoButton                    matlab.ui.control.Button
        ChoosedatatypeLabel            matlab.ui.control.Label
    end


    properties (Access = private)
        Image % Description
        OriginalImage 
        OriginalVideo
        Part
    end

    methods (Access = private)
    
        function video_format_choose(app)
            di=dir; count=2; videos(1)= string('choose...');
            for i=1:length(di)
                k=strfind(di(i).name,app.VideoformatssupportedDropDown.Value);
                if ~isempty(k)
                    videos(count)=string(di(i).name);
                    count=count+1;
                end
            end
            if exist('videos')
                if ~isempty(videos)
                    app.VideofilesDropDown.Items=videos;
                end
            end
            clear videos
        end
        
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, part, ImageTuneStruct)
            try
                app.Part=part;
            end
            if ~exist('part')
                app.Part=1;
                s=VideoReader.getFileFormats;
                for i=1:length(s)
                    ms(i)=string(s(1,i).Extension);
                end
                app.VideoformatssupportedDropDown.Items=ms;
                app.VideofilesDropDown.Items = {'none'};
            elseif app.Part==2
                
            end
        end

        % Button pushed function: ImageButton
        function ImageButtonPushed(app, event)
            app.ImageButton.Visible='off';app.VideoButton.Visible='off';
            app.ChoosedatatypeLabel.Visible='off';
            app.ChooseimagefileButton.Visible='on';

        end

        % Button pushed function: VideoButton
        function VideoButtonPushed(app, event)
            app.ImageButton.Visible='off';app.VideoButton.Visible='off';
            app.ChoosedatatypeLabel.Visible='off';
            app.VideoformatssupportedDropDownLabel.Visible='on';
            app.VideoformatssupportedDropDown.Visible = 'on';
            app.VideofilesDropDownLabel.Visible = 'on';
            app.VideofilesDropDown.Visible = 'on';
            
        end

        % Button pushed function: ChooseimagefileButton
        function ChooseimagefileButtonPushed(app, event)
            app.Image.temp=uiimport('-file');
            a=string(fieldnames(app.Image.temp));
            if length(a)==1%jpg
                app.Image=getfield(app.Image.temp,a);
                app.OriginalImage = rgb2gray(app.Image);
            else %png
                index=getfield(app.Image.temp,a(1));
                map=getfield(app.Image.temp,a(2));
                app.Image = ind2rgb(index,map);
                app.OriginalImage = ind2gray(index,map);
            end
            ImageTune(app.Image,app.OriginalImage)
        end

        % Value changed function: VideoformatssupportedDropDown
        function VideoformatssupportedDropDownValueChanged(app, event)
            VideoformatssupportedDropDownValue = app.VideoformatssupportedDropDown.Value;
            app.VideofilesDropDown.Items = {'none'};
            %detect which videos from the chosen format are in the file
            video_format_choose(app)
        end

        % Value changed function: VideofilesDropDown
        function VideofilesDropDownValueChanged(app, event)
            VideofilesDropDownValue = app.VideofilesDropDown.Value;
            
            if app.VideofilesDropDown.Value~= string('none')
                app.OriginalVideo=VideoReader(app.VideofilesDropDown.Value)
                app.Image = read(app.OriginalVideo, 1);
            end
            app.OriginalImage = rgb2gray(app.Image);
            ImageTune(app.Image,app.OriginalImage,app.OriginalVideo)
            delete(fig);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create ChooseimagefileButton
            app.ChooseimagefileButton = uibutton(app.UIFigure, 'push');
            app.ChooseimagefileButton.ButtonPushedFcn = createCallbackFcn(app, @ChooseimagefileButtonPushed, true);
            app.ChooseimagefileButton.BackgroundColor = [0.302 0.8 0.8314];
            app.ChooseimagefileButton.FontSize = 16;
            app.ChooseimagefileButton.FontWeight = 'bold';
            app.ChooseimagefileButton.Visible = 'off';
            app.ChooseimagefileButton.Position = [241 367 152 26];
            app.ChooseimagefileButton.Text = 'Choose image file';

            % Create VideoformatssupportedDropDownLabel
            app.VideoformatssupportedDropDownLabel = uilabel(app.UIFigure);
            app.VideoformatssupportedDropDownLabel.BackgroundColor = [0.302 0.8 0.851];
            app.VideoformatssupportedDropDownLabel.HorizontalAlignment = 'right';
            app.VideoformatssupportedDropDownLabel.FontSize = 18;
            app.VideoformatssupportedDropDownLabel.Visible = 'off';
            app.VideoformatssupportedDropDownLabel.Position = [55 389 202 22];
            app.VideoformatssupportedDropDownLabel.Text = 'Video formats supported';

            % Create VideoformatssupportedDropDown
            app.VideoformatssupportedDropDown = uidropdown(app.UIFigure);
            app.VideoformatssupportedDropDown.Items = {'1', 'Option 2', '2', 'Option 4'};
            app.VideoformatssupportedDropDown.ValueChangedFcn = createCallbackFcn(app, @VideoformatssupportedDropDownValueChanged, true);
            app.VideoformatssupportedDropDown.Visible = 'off';
            app.VideoformatssupportedDropDown.FontSize = 18;
            app.VideoformatssupportedDropDown.BackgroundColor = [0.302 0.8 0.851];
            app.VideoformatssupportedDropDown.Position = [81 350 163 24];
            app.VideoformatssupportedDropDown.Value = '1';

            % Create VideofilesDropDownLabel
            app.VideofilesDropDownLabel = uilabel(app.UIFigure);
            app.VideofilesDropDownLabel.BackgroundColor = [0.302 0.8 0.851];
            app.VideofilesDropDownLabel.HorizontalAlignment = 'right';
            app.VideofilesDropDownLabel.FontSize = 18;
            app.VideofilesDropDownLabel.Visible = 'off';
            app.VideofilesDropDownLabel.Position = [460 389 88 22];
            app.VideofilesDropDownLabel.Text = 'Video files';

            % Create VideofilesDropDown
            app.VideofilesDropDown = uidropdown(app.UIFigure);
            app.VideofilesDropDown.ValueChangedFcn = createCallbackFcn(app, @VideofilesDropDownValueChanged, true);
            app.VideofilesDropDown.Visible = 'off';
            app.VideofilesDropDown.FontSize = 20;
            app.VideofilesDropDown.BackgroundColor = [0.302 0.8 0.851];
            app.VideofilesDropDown.Position = [408 349 191 26];

            % Create ImageButton
            app.ImageButton = uibutton(app.UIFigure, 'push');
            app.ImageButton.ButtonPushedFcn = createCallbackFcn(app, @ImageButtonPushed, true);
            app.ImageButton.BackgroundColor = [0.302 0.8 0.8314];
            app.ImageButton.FontSize = 16;
            app.ImageButton.Position = [151 359 126 42];
            app.ImageButton.Text = 'Image';

            % Create VideoButton
            app.VideoButton = uibutton(app.UIFigure, 'push');
            app.VideoButton.ButtonPushedFcn = createCallbackFcn(app, @VideoButtonPushed, true);
            app.VideoButton.BackgroundColor = [0.302 0.8 0.8314];
            app.VideoButton.FontSize = 16;
            app.VideoButton.Position = [376 359 126 42];
            app.VideoButton.Text = 'Video';

            % Create ChoosedatatypeLabel
            app.ChoosedatatypeLabel = uilabel(app.UIFigure);
            app.ChoosedatatypeLabel.FontSize = 16;
            app.ChoosedatatypeLabel.Position = [158 424 319 22];
            app.ChoosedatatypeLabel.Text = 'Choose the data type you want to work with';
        end
    end

    methods (Access = public)

        % Construct app
        function app = TuftViztry(varargin)

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end