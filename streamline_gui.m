function varargout = streamline_gui(varargin)
% STREAMLINE_GUI MATLAB code for streamline_gui.fig
%      STREAMLINE_GUI, by itself, creates a new STREAMLINE_GUI or raises the existing
%      singleton*.
%
%      H = STREAMLINE_GUI returns the handle to a new STREAMLINE_GUI or the handle to
%      the existing singleton*.
%
%      STREAMLINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STREAMLINE_GUI.M with the given input arguments.
%
%      STREAMLINE_GUI('Property','Value',...) creates a new STREAMLINE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before streamline_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to streamline_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help streamline_gui

% Last Modified by GUIDE v2.5 31-Jul-2018 11:39:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @streamline_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @streamline_gui_OutputFcn, ...
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


% --- Executes just before streamline_gui is made visible.
function streamline_gui_OpeningFcn(hObject, ~, handles, ...
    tuftSet,CroppedMask,I,bw,WindAngle,graindata)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to streamline_gui (see VARARGIN)
handles.tuftSet=tuftSet;
handles.CroppedMask=CroppedMask;
handles.I=I;
handles.bw=bw;
handles.WindAngle=WindAngle;
handles.graindata=graindata;
% Choose default command line output for streamline_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes streamline_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = streamline_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% --- Executes on selection change in drawingStyle.
function drawingStyle_Callback(hObject, eventdata, handles)
% hObject    handle to drawingStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: contents = cellstr(get(hObject,'String')) returns drawingStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drawingStyle


% --- Executes during object creation, after setting all properties.
function drawingStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drawingStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showButton.
function showButton_Callback(hObject, eventdata, handles)
% hObject    handle to showButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% axes(handles.axes);
% clear?
if ~isfield(handles,'first')
    axes(handles.axes);
    imagesc((handles.bw))
    alpha 0.2
    handles.first=1;
end
global deletenPoints
if isfield(deletenPoints,'x')
    if length(deletenPoints.x)>0
    for i=1:length(deletenPoints.x)
        index=deletenPoints.thisimagetuft(i)
        handles.tuftSet(index).pixelX=0;
        handles.tuftSet(index).pixelY=0;
        handles.tuftSet(index).edgeRelatedrealAngle=0;
    end
    end
end
try
[x,y,u,v,X,Y,U,V,Z,Zind] = streamline_drawer_ML(handles.tuftSet,handles.CroppedMask,...
    handles.I,handles.bw,handles.WindAngle,handles.noOfRows.Value,...
    handles.distanceStreamlines.Value,handles.flipUp.Value,handles.flipSide.Value);

if handles.flipUp.Value==1
    V=-(V);
end
if handles.flipSide.Value==1
    U=-(U);
end

Val=handles.drawingStyle.Value;
if Val==1
   handles.axes=streamline(X,Y,U,V,Z(Zind,1),Z(Zind,2)); 
elseif Val==2
    if handles.arrowsButton.Value==1
        handles.axes=streamslice(U,V,handles.streamsliceSlider.Value,'cubic','arrows');
    else
        handles.axes=streamslice(U,V,handles.streamsliceSlider.Value,'cubic','noarrows');
    end
elseif Val==3
    dis=handles.quiverSlider.Value;
    Xind=1:dis:size(X,1);
    Yind=1:dis:size(X,2);
    imagesc(gca,handles.bw)
    hold on
    alpha 0.2
    v=-v; y=size(handles.bw,1)-y;
    if handles.tuftAreaList.Value==1
        handles.axes=quiver(handles.axes,x,y,u,v);
    else
        handles.axes=quiver(handles.axes,X(Xind,Yind),Y(Xind,Yind),U(Xind,Yind),V(Xind,Yind));

    end
    if handles.quiverWithArrows.Value==0
            handles.axes.ShowArrowHead="off";
        else
            handles.axes.ShowArrowHead="on";
        end
    hold off
end
 %% when animating quiver
% T = timer('TimerFcn',@(~,~)disp(''),'StartDelay',0.05);
% start(T)
% wait(T)


axis equal



end


% --- Executes on selection change in noOfRows.
function noOfRows_Callback(hObject, eventdata, handles)
% hObject    handle to noOfRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns noOfRows contents as cell array
%        contents{get(hObject,'Value')} returns selected item from noOfRows


% --- Executes during object creation, after setting all properties.
function noOfRows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noOfRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function distanceStreamlines_Callback(hObject, eventdata, handles)
% hObject    handle to distanceStreamlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Val=round(handles.distanceStreamlines.Value);
handles.distanceStreamlines.Value=Val;

handles.distanceNoText.String=string(round(Val));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function distanceStreamlines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceStreamlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function streamsliceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to streamsliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Val=handles.streamsliceSlider.Value;
handles.streamsliceSlider.Value=Val;
handles.streamsliceDensityText.String=string((Val));

% --- Executes during object creation, after setting all properties.
function streamsliceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to streamsliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in arrowsButton.
function arrowsButton_Callback(hObject, eventdata, handles)
% hObject    handle to arrowsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arrowsButton


% --- Executes on slider movement.
function quiverSlider_Callback(hObject, eventdata, handles)
% hObject    handle to quiverSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Val=round(handles.quiverSlider.Value);
handles.quiverSlider.Value=Val;

handles.quiverText.String=string(round(Val));


% --- Executes during object creation, after setting all properties.
function quiverSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quiverSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in tuftAreaList.
function tuftAreaList_Callback(hObject, eventdata, handles)
% hObject    handle to tuftAreaList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tuftAreaList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tuftAreaList


% --- Executes during object creation, after setting all properties.
function tuftAreaList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tuftAreaList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in flipUp.
function flipUp_Callback(hObject, eventdata, handles)
% hObject    handle to flipUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipUp



% --- Executes on button press in flipSide.
function flipSide_Callback(hObject, eventdata, handles)
% hObject    handle to flipSide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipSide



% --- Executes on button press in quiverWithArrows.
function quiverWithArrows_Callback(hObject, eventdata, handles)
% hObject    handle to quiverWithArrows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on quiverWithArrows and none of its controls.
function quiverWithArrows_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to quiverWithArrows (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deleteTufts.
function deleteTufts_Callback(hObject, eventdata, handles)
% hObject    handle to deleteTufts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global deletenPoints
for i=1:length(handles.tuftSet)
    pixelX(i)=handles.tuftSet(i).pixelX;
    pixelY(i)=handles.tuftSet(i).pixelY;
end
if ~isfield(deletenPoints,'x')
    deletenPoints.x=[];
    deletenPoints.y=[];
    deletenPoints.thisimagetuft=[];
end
[x_point,y_point] = getpts(handles.axes);
[h,l]=size(handles.bw);
for i=1:length(x_point)
        if x_point(i)>handles.axes.XLim(1) && x_point(i)<handles.axes.XLim(2)...
                && y_point(i)>handles.axes.YLim(1) && y_point(i)<handles.axes.YLim(2)
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[pixelX'*l pixelY'*h]));
            deletenPoints.x=[deletenPoints.x,pixelX(index)];
            deletenPoints.y=[deletenPoints.y,pixelY(index)];
            deletenPoints.thisimagetuft=[deletenPoints.thisimagetuft,index];
            rect=imrect(gca,handles.graindata(index).BoundingBox);
            setColor(rect,'Green');
        end
end
    