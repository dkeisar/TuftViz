function varargout = choose_tufts_for_develop(varargin)
% choose_tufts_for_develop MATLAB code for choose_tufts_for_develop.fig
%      choose_tufts_for_develop, by itself, creates a new choose_tufts_for_develop or raises the existing
%      singleton*.
%
%      H = choose_tufts_for_develop returns the handle to a new choose_tufts_for_develop or the handle to
%      the existing singleton*.
%
%      choose_tufts_for_develop('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in choose_tufts_for_develop.M with the given input arguments.
%
%      choose_tufts_for_develop('Property','Value',...) creates a new choose_tufts_for_develop or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choo?se_tufts_for_ML_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choose_tufts_for_develop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help choose_tufts_for_develop

% Last Modified by GUIDE v2.5 03-Aug-2018 18:09:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @choose_tufts_for_develop_OpeningFcn, ...
    'gui_OutputFcn',  @choose_tufts_for_develop_OutputFcn, ...
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


% --- Executes just before choose_tufts_for_develop is made visible.
function choose_tufts_for_develop_OpeningFcn(hObject, ~, ...
    handles, bw,xcenter,ycenter,graindata,trainingmat,weightVector,CroppedMask,I)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choose_tufts_for_develop (see VARARGIN)
% [Q] = contourmap_drawer_ML(weightVector,trainingmat,CroppedMask,bw,1);
% axes(handles.Image);
% hold on
% contourf(Q,[0:0.01:1],'LineStyle','none');
% axis equal
%
% axes(handles.Image);
%
% imagesc(flipud(bw))
% alpha 0.2
% hold off

handles.bw=bw;
handles.CroppedMask=CroppedMask;
handles.xcenter=xcenter;
handles.ycenter=(size(bw,1)-ycenter);
handles.graindata=graindata;
handles.weightVector=weightVector;
handles.trainingmat=trainingmat;
global MLhandel;
if isfield(MLhandel,'selectedFeatures')
    handles.x_location_box.Value=MLhandel.selectedFeatures(1);
    handles.y_location_box.Value=MLhandel.selectedFeatures(2);
    handles.windRalatedAngle_box.Value=MLhandel.selectedFeatures(3);
    handles.straightness_box.Value=MLhandel.selectedFeatures(4);
    handles.edgeRelatedrealAngle_box.Value=MLhandel.selectedFeatures(5);
    handles.length_box.Value=MLhandel.selectedFeatures(6);
    handles.neighbors_box.Value=MLhandel.selectedFeatures(7);
else
    MLhandel.selectedFeatures=[0,0,1,1,1,1,1];
end
updateImagebutton_Callback(hObject, 1, handles);
% Choose default command line output for choose_tufts_for_develop
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes choose_tufts_for_develop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function choose_tufts_for_develop_OutputFcn(~, ~, handles)
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
            val.y=[val.y,size(handles.bw,1)-handles.ycenter(i)];
            val.label=[val.label,0];
            val.box=[val.box;handles.graindata(i).BoundingBox];
            rectan=[handles.graindata(i).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Red');
            val.tufts(length(val.x))=i;
            counter=counter+1;
        else
            val.x=handles.xcenter(i);
            val.y=size(handles.bw,1)-handles.ycenter(i);
            val.label=0;
            val.tufts=i;
            val.box=handles.graindata(i).BoundingBox;
            rectan=[handles.graindata(i).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
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
            val.y=[val.y,size(handles.bw,1)-handles.ycenter(index)];
            val.label=[val.label,0];
            val.tufts(length(val.x))=index;
            val.box=[val.box;handles.graindata(index).BoundingBox];
            rectan=[handles.graindata(index).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Red');
        end
    else
        val.box=handles.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[handles.xcenter handles.ycenter]));
        val.x=handles.xcenter(index);
        val.y=size(handles.bw,1)-handles.ycenter(index);
        val.label=0;
        val.tufts=index;
        val.box=handles.graindata(index).BoundingBox;
        rectan=[handles.graindata(index).BoundingBox];
        rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
        rect=imrect(gca,rectan);
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
            val.y=[val.y,size(handles.bw,1)-handles.ycenter(index)];
            val.label=[val.label,1];
            
            val.tufts(length(val.x))=index;
            val.box=[val.box;handles.graindata(index).BoundingBox];
            rectan=[handles.graindata(index).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Blue');
        end
    else
        val.box=handles.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[handles.xcenter handles.ycenter]));
        val.x=handles.xcenter(index);
        val.y=size(handles.bw,1)-handles.ycenter(index);
        val.label=1;
        val.tufts=index;
        val.box=handles.graindata(index).BoundingBox;
        rectan=[handles.graindata(index).BoundingBox];
        rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
        rect=imrect(gca,rectan);
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
            val.y=[val.y,size(handles.bw,1)-handles.ycenter(i)];
            val.label=[val.label,1];
            val.box=[val.box;handles.graindata(i).BoundingBox];
            rectan=[handles.graindata(i).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Blue');
            val.tufts(length(val.x))=i;
        else
            val.x=handles.xcenter(i);
            val.y=size(handles.bw,1)-handles.ycenter(i);
            val.label=1;
            val.box=handles.graindata(i).BoundingBox;
            val.tufts=i;
            rectan=[handles.graindata(i).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Blue');
        end
    end
end




% --- Executes on button press in finishButton.
function finishButton_Callback(~, ~, ~)
% hObject    handle to finishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateImagebutton_Callback(hObject, eventdata, handles)
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
            val.y=[val.y,size(handles.bw,1)-handles.ycenter(index)];
            val.label=[val.label,0.5];
            
            val.tufts(length(val.x))=index;
            val.box=[val.box;handles.graindata(index).BoundingBox];
            rectan=[handles.graindata(index).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         -rectan(4);
            rect=imrect(gca,rectan);
            setColor(rect,'Green');
        end
    else
        val.box=handles.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[handles.xcenter handles.ycenter]));
        val.x=handles.xcenter(index);
        val.y=size(handles.bw,1)-handles.ycenter(index);
        val.label=0.5;
        val.tufts=index;
        val.box=handles.graindata(index).BoundingBox;
        rectan=[handles.graindata(index).BoundingBox];
        rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         -rectan(4);
        rect=imrect(gca,rectan);
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
            val.y=[val.y,size(handles.bw,1)-handles.ycenter(i)];
            val.label=[val.label,0.5];
            val.box=[val.box;handles.graindata(i).BoundingBox];
            rectan=[handles.graindata(i).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Green');
            val.tufts(length(val.x))=i;
        else
            val.x=handles.xcenter(i);
            val.y=size(handles.bw,1)-handles.ycenter(i);
            val.label=0.5;
            val.box=handles.graindata(i).BoundingBox;
            val.tufts=i;
            rectan=[handles.graindata(i).BoundingBox];
            rectan(2)=size(handles.bw,1)-rectan(2)-rectan(4)         ;
            rect=imrect(gca,rectan);
            setColor(rect,'Green');
        end
    end
end


% --- Executes on button press in x_location_box.
function x_location_box_Callback(hObject, eventdata, handles)
% hObject    handle to x_location_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)


% --- Executes on button press in y_location_box.
function y_location_box_Callback(hObject, eventdata, handles)
% hObject    handle to y_location_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)


% --- Executes on button press in straightness_box.
function straightness_box_Callback(hObject, eventdata, handles)
% hObject    handle to straightness_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)


% --- Executes on button press in edgeRelatedrealAngle_box.
function edgeRelatedrealAngle_box_Callback(hObject, eventdata, handles)
% hObject    handle to edgeRelatedrealAngle_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)


% --- Executes on button press in length_box.
function length_box_Callback(hObject, eventdata, handles)
% hObject    handle to length_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)


% --- Executes on button press in neighbors_box.
function neighbors_box_Callback(hObject, eventdata, handles)
% hObject    handle to neighbors_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)



% --- Executes on button press in windRalatedAngle_box.
function windRalatedAngle_box_Callback(hObject, eventdata, handles)
% hObject    handle to windRalatedAngle_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateFeatureSelection_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of windRalatedAngle_box

function updateFeatureSelection_Callback(hObject, eventdata, handles)
global MLhandel
MLhandel.selectedFeatures=[handles.x_location_box.Value,...
    handles.y_location_box.Value,handles.windRalatedAngle_box.Value,...
    handles.straightness_box.Value,handles.edgeRelatedrealAngle_box.Value,...
    handles.length_box.Value,handles.neighbors_box.Value];



% --- Executes on button press in updateImagebutton.
function updateImagebutton_Callback(hObject, eventdata, handles)
% hObject    handle to updateImagebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = uifigure;
d = uiprogressdlg(f,'Title','Computing',...
    'Indeterminate','on');
global MLhandel;
counter=1;
for i=1:length(MLhandel.selectedFeatures)
    if MLhandel.selectedFeatures(i)==1
        selectedFeaturevector(counter)=i;
        counter=counter+1;
    end
end
weightVector=mean(MLhandel.weightVectors);
updatedWeightVector = fmin_adam(@(weightVector)labelingMSEGradients...
    (weightVector, MLhandel.tuftVectors(:,selectedFeaturevector), MLhandel.labels(:,2)), ...
    weightVector(selectedFeaturevector)', 0.01);
updatedWeightVector=updatedWeightVector';
counter=1;
for i=1:length(MLhandel.selectedFeatures)
    if MLhandel.selectedFeatures(i)==1
        uupdatedWeightVector(i)=updatedWeightVector(counter);
        counter=counter+1;
    else
        uupdatedWeightVector(i)=0;
    end
end
uupdatedWeightVector(i+1:i+3)=0;
tuftLabels=handles.trainingmat*(uupdatedWeightVector');
    [Q] = contourmap_drawer_ML(handles.trainingmat,tuftLabels...
        ,handles.CroppedMask,handles.bw,1);
MLhandel.WeightVector=uupdatedWeightVector;

axes(handles.Image);
hold on
contourf(Q,[0:0.1:1],'LineStyle','none');
axis equal

axes(handles.Image);
imagesc(flipud(handles.bw));
alpha 0.2
hold off
close(f);

