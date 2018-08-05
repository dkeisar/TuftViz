classdef TuftVizuu < matlab.apps.AppBase

    % Properties that correspond to TuftVizuucomponents
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        Menu                           matlab.ui.container.Menu
        NewMenu                        matlab.ui.container.Menu
        VideoformatssupportedDropDownLabel  matlab.ui.control.Label
        VideoformatssupportedDropDown  matlab.ui.control.DropDown
        VideofilesDropDownLabel        matlab.ui.control.Label
        VideofilesDropDown             matlab.ui.control.DropDown
        ImageButton                    matlab.ui.control.Button
        VideoButton                    matlab.ui.control.Button
        ChoosedatatypeLabel            matlab.ui.control.Label
        UseAnalyticaltoolsButton       matlab.ui.control.Button
        UseMachineLearningToolsButton  matlab.ui.control.Button
        ChoosedatatypeLabel_2          matlab.ui.control.Label
    end

    
    properties (Access = private)
        Image % Description
        OriginalImage
        OriginalVideo
        Part
        
    end

    properties (Access = public)
        ImageTuneStruct % Description
    end
    
    methods (Access = private)
        
        function video_format_choose(TuftVizuu)
            di=dir; count=2; videos(1)= string('choose...');
            for i=1:length(di)
                k=strfind(di(i).name,TuftVizuu.VideoformatssupportedDropDown.Value);
                if ~isempty(k)
                    videos(count)=string(di(i).name);
                    count=count+1;
                end
            end
            if exist('videos')
                if ~isempty(videos)
                    TuftVizuu.VideofilesDropDown.Items=videos;
                end
            end
            clear videos
        end
        
        
        function show_part_two(TuftVizuu)
            TuftVizuu.ImageButton.Visible='off';TuftVizuu.VideoButton.Visible='off';
            TuftVizuu.ChoosedatatypeLabel.Visible='off';
            TuftVizuu.ChoosedatatypeLabel_2.Visible = 'on';
            TuftVizuu.UseMachineLearningToolsButton.Visible = 'on';
            TuftVizuu.UseAnalyticaltoolsButton.Visible = 'on';
        end
        
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(TuftVizuu, part, ImageTuneStruct)
            try
                TuftVizuu.Part=part;
            end
            if ~exist('part')
                TuftVizuu.Part=1;
                s=VideoReader.getFileFormats;
                for i=1:length(s)
                    ms(i)=string(s(1,i).Extension);
                end
                TuftVizuu.VideoformatssupportedDropDown.Items=ms;
                TuftVizuu.VideofilesDropDown.Items = {'none'};
            elseif TuftVizuu.Part==2
%                 global imagetune;
%                 imagetune=ImageTuneStruct;
                 TuftVizuu.ImageTuneStruct=ImageTuneStruct;
                show_part_two(TuftVizuu)
            end
        end

        % Button pushed function: ImageButton
        function ImageButtonPushed(TuftVizuu, event)
            TuftVizuu.ImageButton.Visible='off';TuftVizuu.VideoButton.Visible='off';
            TuftVizuu.ChoosedatatypeLabel.Visible='off';
            TuftVizuu.Image.temp=uiimport('-file');
            a=string(fieldnames(TuftVizuu.Image.temp));
            if length(a)==1%jpg
                TuftVizuu.Image=getfield(TuftVizuu.Image.temp,a);
                TuftVizuu.OriginalImage = rgb2gray(TuftVizuu.Image);
            else %png
                index=getfield(TuftVizuu.Image.temp,a(1));
                map=getfield(TuftVizuu.Image.temp,a(2));
                TuftVizuu.Image = ind2rgb(index,map);
                TuftVizuu.OriginalImage = ind2gray(index,map);
            end
            ImageTune(TuftVizuu.Image,TuftVizuu.OriginalImage)
            delete(TuftVizuu.UIFigure)
        end

        % Button pushed function: VideoButton
        function VideoButtonPushed(TuftVizuu, event)
            TuftVizuu.ImageButton.Visible='off';TuftVizuu.VideoButton.Visible='off';
            TuftVizuu.ChoosedatatypeLabel.Visible='off';
            TuftVizuu.VideoformatssupportedDropDownLabel.Visible='on';
            TuftVizuu.VideoformatssupportedDropDown.Visible = 'on';
            TuftVizuu.VideofilesDropDownLabel.Visible = 'on';
            TuftVizuu.VideofilesDropDown.Visible = 'on';
            
        end

        % Value changed function: VideoformatssupportedDropDown
        function VideoformatssupportedDropDownValueChanged(TuftVizuu, event)
            VideoformatssupportedDropDownValue = TuftVizuu.VideoformatssupportedDropDown.Value;
            TuftVizuu.VideofilesDropDown.Items = {'none'};
            %detect which videos from the chosen format are in the file
            video_format_choose(TuftVizuu)
        end

        % Value changed function: VideofilesDropDown
        function VideofilesDropDownValueChanged(TuftVizuu, event)
            VideofilesDropDownValue = TuftVizuu.VideofilesDropDown.Value;
            
            if TuftVizuu.VideofilesDropDown.Value~= string('none')
                TuftVizuu.OriginalVideo=VideoReader(TuftVizuu.VideofilesDropDown.Value)
                TuftVizuu.Image = read(TuftVizuu.OriginalVideo, 1);
            end
            TuftVizuu.OriginalImage = rgb2gray(TuftVizuu.Image);
            ImageTune(TuftVizuu.Image,TuftVizuu.OriginalImage,TuftVizuu.OriginalVideo)
            delete(TuftVizuu.UIFigure)
        end

        % Menu selected function: NewMenu
        function NewMenuSelected(TuftVizuu, event)
            TuftVizuu;
        end

        % Button pushed function: UseMachineLearningToolsButton
        function UseMachineLearningToolsButtonPushed(TuftVizuu, event)
            noOfImages=5;
            Main_ML_Training(TuftVizuu.ImageTuneStruct,noOfImages)
        end
    end

    % TuftVizuuinitialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(TuftVizuu)

            % Create UIFigure
            TuftVizuu.UIFigure = uifigure;
            TuftVizuu.UIFigure.Color = [0.149 0.149 0.149];
            TuftVizuu.UIFigure.Position = [100 100 640 480];
            TuftVizuu.UIFigure.Name = 'UI Figure';

            % Create Menu
            TuftVizuu.Menu = uimenu(TuftVizuu.UIFigure);
            TuftVizuu.Menu.Text = 'Menu';

            % Create NewMenu
            TuftVizuu.NewMenu = uimenu(TuftVizuu.Menu);
            TuftVizuu.NewMenu.MenuSelectedFcn = createCallbackFcn(TuftVizuu, @NewMenuSelected, true);
            TuftVizuu.NewMenu.Text = 'New';

            % Create VideoformatssupportedDropDownLabel
            TuftVizuu.VideoformatssupportedDropDownLabel = uilabel(TuftVizuu.UIFigure);
            TuftVizuu.VideoformatssupportedDropDownLabel.HorizontalAlignment = 'center';
            TuftVizuu.VideoformatssupportedDropDownLabel.FontSize = 26;
            TuftVizuu.VideoformatssupportedDropDownLabel.FontColor = [1 1 1];
            TuftVizuu.VideoformatssupportedDropDownLabel.Visible = 'off';
            TuftVizuu.VideoformatssupportedDropDownLabel.Position = [186 333 291 31];
            TuftVizuu.VideoformatssupportedDropDownLabel.Text = 'Video formats supported';

            % Create VideoformatssupportedDropDown
            TuftVizuu.VideoformatssupportedDropDown = uidropdown(TuftVizuu.UIFigure);
            TuftVizuu.VideoformatssupportedDropDown.Items = {'1', 'Option 2', '2', 'Option 4'};
            TuftVizuu.VideoformatssupportedDropDown.ValueChangedFcn = createCallbackFcn(TuftVizuu, @VideoformatssupportedDropDownValueChanged, true);
            TuftVizuu.VideoformatssupportedDropDown.Visible = 'off';
            TuftVizuu.VideoformatssupportedDropDown.FontSize = 26;
            TuftVizuu.VideoformatssupportedDropDown.FontColor = [1 1 1];
            TuftVizuu.VideoformatssupportedDropDown.BackgroundColor = [0 0 0.502];
            TuftVizuu.VideoformatssupportedDropDown.Position = [250 280 163 33];
            TuftVizuu.VideoformatssupportedDropDown.Value = '1';

            % Create VideofilesDropDownLabel
            TuftVizuu.VideofilesDropDownLabel = uilabel(TuftVizuu.UIFigure);
            TuftVizuu.VideofilesDropDownLabel.HorizontalAlignment = 'center';
            TuftVizuu.VideofilesDropDownLabel.FontSize = 26;
            TuftVizuu.VideofilesDropDownLabel.FontColor = [1 1 1];
            TuftVizuu.VideofilesDropDownLabel.Visible = 'off';
            TuftVizuu.VideofilesDropDownLabel.Position = [269 201 125 31];
            TuftVizuu.VideofilesDropDownLabel.Text = 'Video files';

            % Create VideofilesDropDown
            TuftVizuu.VideofilesDropDown = uidropdown(TuftVizuu.UIFigure);
            TuftVizuu.VideofilesDropDown.ValueChangedFcn = createCallbackFcn(TuftVizuu, @VideofilesDropDownValueChanged, true);
            TuftVizuu.VideofilesDropDown.Visible = 'off';
            TuftVizuu.VideofilesDropDown.FontSize = 26;
            TuftVizuu.VideofilesDropDown.FontColor = [1 1 1];
            TuftVizuu.VideofilesDropDown.BackgroundColor = [0 0 0.502];
            TuftVizuu.VideofilesDropDown.Position = [236 149 191 33];

            % Create ImageButton
            TuftVizuu.ImageButton = uibutton(TuftVizuu.UIFigure, 'push');
            TuftVizuu.ImageButton.ButtonPushedFcn = createCallbackFcn(TuftVizuu, @ImageButtonPushed, true);
            TuftVizuu.ImageButton.BackgroundColor = [0 0 0.502];
            TuftVizuu.ImageButton.FontSize = 26;
            TuftVizuu.ImageButton.FontWeight = 'bold';
            TuftVizuu.ImageButton.FontColor = [1 1 1];
            TuftVizuu.ImageButton.Position = [154 220 126 42];
            TuftVizuu.ImageButton.Text = 'Image';

            % Create VideoButton
            TuftVizuu.VideoButton = uibutton(TuftVizuu.UIFigure, 'push');
            TuftVizuu.VideoButton.ButtonPushedFcn = createCallbackFcn(TuftVizuu, @VideoButtonPushed, true);
            TuftVizuu.VideoButton.BackgroundColor = [0 0 0.502];
            TuftVizuu.VideoButton.FontSize = 26;
            TuftVizuu.VideoButton.FontWeight = 'bold';
            TuftVizuu.VideoButton.FontColor = [1 1 1];
            TuftVizuu.VideoButton.Position = [375 220 126 42];
            TuftVizuu.VideoButton.Text = 'Video';

            % Create ChoosedatatypeLabel
            TuftVizuu.ChoosedatatypeLabel = uilabel(TuftVizuu.UIFigure);
            TuftVizuu.ChoosedatatypeLabel.HorizontalAlignment = 'center';
            TuftVizuu.ChoosedatatypeLabel.FontSize = 36;
            TuftVizuu.ChoosedatatypeLabel.FontColor = [1 1 1];
            TuftVizuu.ChoosedatatypeLabel.Position = [154 344 355 83];
            TuftVizuu.ChoosedatatypeLabel.Text = {'Choose the data type'; 'you want to work with'};

            % Create UseAnalyticaltoolsButton
            TuftVizuu.UseAnalyticaltoolsButton = uibutton(TuftVizuu.UIFigure, 'push');
            TuftVizuu.UseAnalyticaltoolsButton.BackgroundColor = [0 0 0.502];
            TuftVizuu.UseAnalyticaltoolsButton.FontSize = 28;
            TuftVizuu.UseAnalyticaltoolsButton.FontWeight = 'bold';
            TuftVizuu.UseAnalyticaltoolsButton.FontColor = [1 1 1];
            TuftVizuu.UseAnalyticaltoolsButton.Visible = 'off';
            TuftVizuu.UseAnalyticaltoolsButton.Position = [99 141 216 74];
            TuftVizuu.UseAnalyticaltoolsButton.Text = {'Use Analytical '; 'tools'};

            % Create UseMachineLearningToolsButton
            TuftVizuu.UseMachineLearningToolsButton = uibutton(TuftVizuu.UIFigure, 'push');
            TuftVizuu.UseMachineLearningToolsButton.ButtonPushedFcn = createCallbackFcn(TuftVizuu, @UseMachineLearningToolsButtonPushed, true);
            TuftVizuu.UseMachineLearningToolsButton.BackgroundColor = [0 0 0.502];
            TuftVizuu.UseMachineLearningToolsButton.FontSize = 28;
            TuftVizuu.UseMachineLearningToolsButton.FontWeight = 'bold';
            TuftVizuu.UseMachineLearningToolsButton.FontColor = [1 1 1];
            TuftVizuu.UseMachineLearningToolsButton.Visible = 'off';
            TuftVizuu.UseMachineLearningToolsButton.Position = [330 141 216 74];
            TuftVizuu.UseMachineLearningToolsButton.Text = {'Use Machine '; 'Learning Tools'};

            % Create ChoosedatatypeLabel_2
            TuftVizuu.ChoosedatatypeLabel_2 = uilabel(TuftVizuu.UIFigure);
            TuftVizuu.ChoosedatatypeLabel_2.HorizontalAlignment = 'center';
            TuftVizuu.ChoosedatatypeLabel_2.FontSize = 36;
            TuftVizuu.ChoosedatatypeLabel_2.FontColor = [1 1 1];
            TuftVizuu.ChoosedatatypeLabel_2.Visible = 'off';
            TuftVizuu.ChoosedatatypeLabel_2.Position = [121 263 422 83];
            TuftVizuu.ChoosedatatypeLabel_2.Text = {'Choose the analysis tools'; 'you want to work with'};
        end
    end

    methods (Access = public)

        % Construct TuftVizuu
        function TuftVizuu= TuftVizuu(varargin)

            % Create and configure components
            createComponents(TuftVizuu)

            % Register the TuftVizuuwith TuftVizuuDesigner
            registerApp(TuftVizuu, TuftVizuu.UIFigure)

            % Execute the startup function
            runStartupFcn(TuftVizuu, @(TuftVizuu)startupFcn(TuftVizuu, varargin{:}))

%             if nargout == 0
%                 clear TuftVizuu
%             end
        end

        % Code that executes before TuftVizuudeletion
        function delete(TuftVizuu)

            % Delete UIFigure when TuftVizuuis deleted
            delete(TuftVizuu.UIFigure)
        end
    end
end