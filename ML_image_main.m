function varargout = ML_image_main(varargin)
% ML_IMAGE_MAIN MATLAB code for ML_image_main.fig
%      ML_IMAGE_MAIN, by itself, creates a new ML_IMAGE_MAIN or raises the existing
%      singleton*.
%
%      H = ML_IMAGE_MAIN returns the handle to a new ML_IMAGE_MAIN or the handle to
%      the existing singleton*.
%
%      ML_IMAGE_MAIN('CALLBACK',hObject,eventData,ML,...) calls the local
%      function named CALLBACK in ML_IMAGE_MAIN.M with the given input arguments.
%
%      ML_IMAGE_MAIN('Property','Value',...) creates a new ML_IMAGE_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ML_image_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ML_image_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIML

% Edit the above text to modify the response to help ML_image_main

% Last Modified by GUIDE v2.5 23-Jul-2018 14:24:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ML_image_main_OpeningFcn, ...
                   'gui_OutputFcn',  @ML_image_main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ML_image_main is made visible.
function ML_image_main_OpeningFcn(hObject, eventdata, ML, imageTune)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% ML    structure with ML and user data (see GUIDATA)
% imageTune   command line arguments to ML_image_main (see VARARGIN)
ML.imageTune=imageTune;

% Choose default command line output for ML_image_main
ML.output = hObject;

% Update ML structure
guidata(hObject, ML);

% UIWAIT makes ML_image_main wait for user response (see UIRESUME)
% uiwait(ML.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ML_image_main_OutputFcn(hObject, eventdata, ML) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% ML    structure with ML and user data (see GUIDATA)

% Get default command line output from ML structure
varargout{1} = ML.output;


% --- Executes on button press in trainbutton.
function trainbutton_Callback(hObject, eventdata, ML)
% hObject    handle to trainbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% ML    structure with ML and user data (see GUIDATA)

%if first time than 3 times, each other time, only once
global MLhandel
if isfield(MLhandel,'first')
    [weightVectors,miniweightVectors,tuftVectors]=Main_ML_Training(ML.imageTune,1,...
        MLhandel.weightVectors,MLhandel.miniweightVectors,MLhandel.tuftVectors);
else
    [weightVectors,miniweightVectors,tuftVectors]=Main_ML_Training(ML.imageTune,3);
    MLhandel.first=1;
    ML.developbutton.Enable='on';
    ML.testbutton.Enable='on';
    ML.cantext.Visible='on';
end
MLhandel.weightVectors=weightVectors;
MLhandel.miniweightVectors=miniweightVectors;
MLhandel.tuftVectors=tuftVectors;


% --- Executes on button press in developbutton.
function developbutton_Callback(hObject, eventdata, ML)
% hObject    handle to developbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% ML    structure with ML and user data (see GUIDATA)
global MLhandel
[weightVectors,miniweightVectors,tuftVectors]=Main_ML_develop...
    (ML.imageTune,MLhandel.weightVectors,MLhandel.miniweightVectors...
    ,MLhandel.tuftVectors);
MLhandel.weightVectors=weightVectors;
MLhandel.miniweightVectors=miniweightVectors;
MLhandel.tuftVectors=tuftVectors;



% --- Executes on button press in testbutton.
function testbutton_Callback(hObject, eventdata, ML)
% hObject    handle to testbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% ML    structure with ML and user data (see GUIDATA)
