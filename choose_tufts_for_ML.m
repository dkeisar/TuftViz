function varargout = choose_tufts_for_ML(varargin)
% CHOOSE_TUFTS_FOR_ML MATLAB code for choose_tufts_for_ML.fig
%      CHOOSE_TUFTS_FOR_ML, by itself, creates a new CHOOSE_TUFTS_FOR_ML or raises the existing
%      singleton*.
%
%      H = CHOOSE_TUFTS_FOR_ML returns the handle to a new CHOOSE_TUFTS_FOR_ML or the handle to
%      the existing singleton*.
%
%      CHOOSE_TUFTS_FOR_ML('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSE_TUFTS_FOR_ML.M with the given input arguments.
%
%      CHOOSE_TUFTS_FOR_ML('Property','Value',...) creates a new CHOOSE_TUFTS_FOR_ML or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choo?se_tufts_for_ML_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choose_tufts_for_ML_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help choose_tufts_for_ML

% Last Modified by GUIDE v2.5 02-Aug-2018 14:13:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @choose_tufts_for_ML_OpeningFcn, ...
    'gui_OutputFcn',  @choose_tufts_for_ML_OutputFcn, ...
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


% --- Executes just before choose_tufts_for_ML is made visible.
function choose_tufts_for_ML_OpeningFcn(hObject, ~, ...
    handles, bw,xcenter,ycenter,graindata)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choose_tufts_for_ML (see VARARGIN)
axes(handles.Image);
imshow(bw);
handles.bw=bw;
handles.xcenter=xcenter;
handles.ycenter=ycenter;
handles.graindata=graindata;
% Choose default command line output for choose_tufts_for_ML
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes choose_tufts_for_ML wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function choose_tufts_for_ML_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in un_attached_polygon_button.
function un_attached_polygon_button_Callback(~, ~, handles)
% hObject    handle to un_attached_polygon_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global val
fig=figure;
fig.Name='Choose the area of the polygon';
h=croping(handles.bw);
close
counter=1;
for i=1:length(handles.xcenter)
    if ~h(round(handles.ycenter(i)),round(handles.xcenter(i)))
        if isfield(val,'x')
            val.x=[val.x,handles.xcenter(i)];
            val.y=[val.y,handles.ycenter(i)];
            val.label=[val.label,0];
            val.box=[val.box;handles.graindata(i).BoundingBox];
            rect=imrect(gca,handles.graindata(i).BoundingBox);
            setColor(rect,'Red');
            val.tufts(length(val.x))=i;
            counter=counter+1;
        else
            val.x=handles.xcenter(i);
            val.y=handles.ycenter(i);
            val.label=0;
            val.tufts=i;
            val.box=handles.graindata(i).BoundingBox;
            rect=imrect(gca,handles.graindata(i).BoundingBox);
            setColor(rect,'Red');
            counter=counter+1;
        end
    end    
end


% --- Executes on button press in un_attached_tufts_button.
function un_attached_tufts_button_Callback(~, ~, handles)
% hObject    handle to un_attached_tufts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.backpanel.Title='Click on the relevent tufts, press enter to finish';
global val
[x_point,y_point] = getpts(handles.Image);
counter=1;
for i=1:length(x_point)
    if isfield(val,'x')
        if x_point(i)>handles.Image.XLim(1) && x_point(i)<handles.Image.XLim(2)...
                && y_point(i)>handles.Image.YLim(1) && y_point(i)<handles.Image.YLim(2)
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[handles.xcenter handles.ycenter]));
            val.x=[val.x,handles.xcenter(index)];
            val.y=[val.y,handles.ycenter(index)];
            val.label=[val.label,0];
            val.tufts(length(val.x))=index;
            val.box=[val.box;handles.graindata(index).BoundingBox];
            rect=imrect(gca,handles.graindata(index).BoundingBox);
            setColor(rect,'Red');
        end
    else
        val.box=handles.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[handles.xcenter handles.ycenter]));
        val.x=handles.xcenter(index);
        val.y=handles.ycenter(index);
        val.label=0;
        val.tufts=index;
        val.box=handles.graindata(index).BoundingBox;
        rect=imrect(gca,handles.graindata(index).BoundingBox);
        setColor(rect,'Red');
    end
    
end




% --- Executes on button press in attached_tufts_button.
function attached_tufts_button_Callback(~, ~, handles)
% hObject    handle to attached_tufts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.backpanel.Title='Click on the relevent tufts, press enter to finish';
global val
[x_point,y_point] = getpts(handles.Image);
counter=1;
for i=1:length(x_point)
    if isfield(val,'x')
        if x_point(i)>handles.Image.XLim(1) && x_point(i)<handles.Image.XLim(2)...
                && y_point(i)>handles.Image.YLim(1) && y_point(i)<handles.Image.YLim(2)
                        
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[handles.xcenter handles.ycenter]));
            val.x=[val.x,handles.xcenter(index)];
            val.y=[val.y,handles.ycenter(index)];
            val.label=[val.label,1];
            
            val.tufts(length(val.x))=index;
            val.box=[val.box;handles.graindata(index).BoundingBox];
            rect=imrect(gca,handles.graindata(index).BoundingBox);
            setColor(rect,'Blue');
        end
    else
        val.box=handles.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[handles.xcenter handles.ycenter]));
        val.x=handles.xcenter(index);
        val.y=handles.ycenter(index);
        val.label=1;
        val.tufts=index;
        val.box=handles.graindata(index).BoundingBox;
        rect=imrect(gca,handles.graindata(index).BoundingBox);
        setColor(rect,'Blue');
    end
    
end





% --- Executes on button press in attached_polygon_button.
function attached_polygon_button_Callback(~, ~, handles)
% hObject    handle to attached_polygon_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global val
fig=figure;
fig.Name='Choose the area of the polygon';
h=croping(handles.bw);
close
for i=1:length(handles.xcenter)
    if ~h(round(handles.ycenter(i)),round(handles.xcenter(i)))
        if isfield(val,'x')
            val.x=[val.x,handles.xcenter(i)];
            val.y=[val.y,handles.ycenter(i)];
            val.label=[val.label,1];
            val.box=[val.box;handles.graindata(i).BoundingBox];
            rect=imrect(gca,handles.graindata(i).BoundingBox);
            setColor(rect,'Blue');
            val.tufts(length(val.x))=i;
        else
            val.x=handles.xcenter(i);
            val.y=handles.ycenter(i);
            val.label=1;
            val.box=handles.graindata(i).BoundingBox;
            val.tufts=i;
            rect=imrect(gca,handles.graindata(i).BoundingBox);
            setColor(rect,'Blue');
        end
    end    
end

    
    
    
    % --- Executes on button press in pushbutton5.
    function pushbutton5_Callback(~, ~, ~)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    closereq


% --- Executes on button press in crosswind_tufts_button.
function crosswind_tufts_button_Callback(hObject, eventdata, handles)
% hObject    handle to crosswind_tufts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.backpanel.Title='Click on the relevent tufts, press enter to finish';
global val
[x_point,y_point] = getpts(handles.Image);
counter=1;
for i=1:length(x_point)
    if isfield(val,'x')
        if x_point(i)>handles.Image.XLim(1) && x_point(i)<handles.Image.XLim(2)...
                && y_point(i)>handles.Image.YLim(1) && y_point(i)<handles.Image.YLim(2)
                        
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[handles.xcenter handles.ycenter]));
            val.x=[val.x,handles.xcenter(index)];
            val.y=[val.y,handles.ycenter(index)];
            val.label=[val.label,0.5];
            
            val.tufts(length(val.x))=index;
            val.box=[val.box;handles.graindata(index).BoundingBox];
            rect=imrect(gca,handles.graindata(index).BoundingBox);
            setColor(rect,'Green');
        end
    else
        val.box=handles.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[handles.xcenter handles.ycenter]));
        val.x=handles.xcenter(index);
        val.y=handles.ycenter(index);
        val.label=0.5;
        val.tufts=index;
        val.box=handles.graindata(index).BoundingBox;
        rect=imrect(gca,handles.graindata(index).BoundingBox);
        setColor(rect,'Green');
    end
    
end


% --- Executes on button press in crosswind_polygon_button.
function crosswind_polygon_button_Callback(hObject, eventdata, handles)
% hObject    handle to crosswind_polygon_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global val
fig=figure;
fig.Name='Choose the area of the polygon';
h=croping(handles.bw);
close
for i=1:length(handles.xcenter)
    if ~h(round(handles.ycenter(i)),round(handles.xcenter(i)))
        if isfield(val,'x')
            val.x=[val.x,handles.xcenter(i)];
            val.y=[val.y,handles.ycenter(i)];
            val.label=[val.label,0.5];
            val.box=[val.box;handles.graindata(i).BoundingBox];
            rect=imrect(gca,handles.graindata(i).BoundingBox);
            setColor(rect,'Green');
            val.tufts(length(val.x))=i;
        else
            val.x=handles.xcenter(i);
            val.y=handles.ycenter(i);
            val.label=0.5;
            val.box=handles.graindata(i).BoundingBox;
            val.tufts=i;
            imrect(gca,handles.graindata(i).BoundingBox);
            rect=setColor(rect,'Green');
        end
    end    
end
