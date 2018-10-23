function varargout = create_grid_for_clustering(varargin)
% create_grid_for_clustering MATLAB code for create_grid_for_clustering.fig
%      create_grid_for_clustering, by itself, creates a new create_grid_for_clustering or raises the existing
%      singleton*.
%
%      H = create_grid_for_clustering returns the handle to a new create_grid_for_clustering or the handle to
%      the existing singleton*.
%
%      create_grid_for_clustering('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in create_grid_for_clustering.M with the given input arguments.
%
%      create_grid_for_clustering('Property','Value',...) creates a new create_grid_for_clustering or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choo?se_tufts_for_ML_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_grid_for_clustering_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_grid_for_clustering

% Last Modified by GUIDE v2.5 09-Oct-2018 17:53:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @create_grid_for_clustering_OpeningFcn, ...
    'gui_OutputFcn',  @create_grid_for_clustering_OutputFcn, ...
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


% --- Executes just before create_grid_for_clustering is made visible.
function create_grid_for_clustering_OpeningFcn(hObject, ~, ...
    handles,I,bw,labeled,imageTune,flag)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_grid_for_clustering (see VARARGIN)
axes(handles.Image);
imagesc((bw))
alpha 0.2
hold off
handles.labeled=labeled;
graindata = regionprops(labeled,'basic');
handles.NoOfMaxClusters_Slider.Max=length(graindata)/3;
handles.bw=bw;
handles.graindata=graindata;
handles.flag=flag;
handles.CroppedMask=imageTune.CroppedMask;
handles.I=I;
handles.imageTune=imageTune;
global MLhandel
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
% Choose default command line output for create_grid_for_clustering
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_grid_for_clustering wait for user response (see UIRESUME)
% uiwait(handles.create_grid_for_clustering);


% --- Outputs from this function are returned to the command line.
function create_grid_for_clustering_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in polygonButton.
function polygonButton_Callback(~, ~, handles)
% hObject    handle to polygonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global MLhandel;
fig=figure;
fig.Name='Choose the area of the polygon';
H=croping(handles.bw);
close
counter=1;
color=rand(1,3)
[h,l]=size(handles.bw)
if isfield(MLhandel,'noOfCurrentRowInTheGrid')
    MLhandel.noOfCurrentRowInTheGrid=MLhandel.noOfCurrentRowInTheGrid+1;
else
    MLhandel.noOfCurrentRowInTheGrid=1;
end
handles.rowNoText.String=string(MLhandel.noOfCurrentRowInTheGrid+1);
for i=1:length(handles.graindata)
    pixelX(i)=handles.graindata(i).Centroid(1);
    pixelY(i)=handles.graindata(i).Centroid(2);
end
for i=1:length(handles.graindata)
    if ~H(round(pixelY(i)),round(pixelX(i)))
        MLhandel.gridindex(counter,MLhandel.noOfCurrentRowInTheGrid)=i;
        MLhandel.gridindexX(counter,MLhandel.noOfCurrentRowInTheGrid)=pixelX(i);
        MLhandel.gridindexY(counter,MLhandel.noOfCurrentRowInTheGrid)=pixelY(i);
        rect=imrect(gca,[handles.graindata(i).BoundingBox]);
        setColor(rect,[color]);
        counter=counter+1;
    end
end







% --- Executes on button press in deleteGridButton.
function deleteGridButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteGridButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global MLhandel;
MLhandel=[];


% --- Executes on button press in deleteSegmentedButton.
function deleteSegmentedButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSegmentedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global MLhandel
for i=1:length(handles.graindata)
    pixelX(i)=handles.graindata(i).Centroid(1);
    pixelY(i)=handles.graindata(i).Centroid(2);
end
if ~isfield(MLhandel,'deletedtuft')
    MLhandel.deletedtuft=[];
end
[x_point,y_point] = getpts(handles.Image);
[h,l]=size(handles.bw);
for i=1:length(x_point)
    if x_point(i)>handles.Image.XLim(1) && x_point(i)<handles.Image.XLim(2)...
            && y_point(i)>handles.Image.YLim(1) && y_point(i)<handles.Image.YLim(2)
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[  pixelX' pixelY']));
        MLhandel.deletedtuft=[MLhandel.deletedtuft,index];
        
        for j=1:size(MLhandel.gridindex,1)
            for k=1:size(MLhandel.gridindex,2)
                if MLhandel.gridindex(j,k)==index;
                    MLhandel.gridindex(j,k)=0;
                    MLhandel.gridindexX(j,k)=0;
                    MLhandel.gridindexY(j,k)=0;
                end
            end
        end
        rect=imrect(gca,handles.graindata(index).BoundingBox);
        setColor(rect,[0 0 0]);
    end
end


% --- Executes on button press in finishButton.
function finishButton_Callback(hObject, eventdata, handles)
% hObject    handle to finishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close gcf


% --- Executes on slider movement.
function NoOfMaxClusters_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to NoOfMaxClusters_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.noOfMaxClusters.String=round(get(hObject,'Value'));
global MLhandel
MLhandel.noMaxCluster=handles.noOfMaxClusters.String;





% --- Executes during object creation, after setting all properties.
function NoOfMaxClusters_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoOfMaxClusters_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function minTuftsInACluster_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to minTuftsInACluster_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.minTuftsInACluster_text.String=round(get(hObject,'Value'));
handles.NoOfMaxClusters_Slider.Max=round(min(length(handles.graindata)/3,...
    length(handles.graindata)/(get(hObject,'Value'))));
handles.NoOfMaxClusters_Slider.Value=...
    round(min(handles.NoOfMaxClusters_Slider.Max,handles.NoOfMaxClusters_Slider.Value));
global MLhandel
MLhandel.minNumInCluster=handles.minTuftsInACluster_text.String;



% --- Executes during object creation, after setting all properties.
function minTuftsInACluster_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minTuftsInACluster_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
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
if handles.flag
    for i=1:length(MLhandel.selectedFeatures)
        if MLhandel.selectedFeatures(i)==1
            selectedFeaturevector(counter)=i;
            counter=counter+1;
        end
    end
    updatedWeightVector = fmin_adam(@(weightVector)labelingMSEGradients...
        (weightVector, MLhandel.tuftVectors(:,selectedFeaturevector), MLhandel.labels(:,2)), ...
        handles.weightVector(:,selectedFeaturevector)', 0.01);
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
else
    [trainingSet,tuftLabels] = clusterStepOne(handles.bw,handles.labeled,handles.I,handles.imageTune,handles.flag);
    [Q] = contourmap_drawer_ML(trainingSet,tuftLabels...
        ,handles.CroppedMask,handles.bw,1);
end
axes(handles.Image);
hold on
contourf(Q,[0:0.1:1],'LineStyle','none');
axis equal

axes(handles.Image);
imagesc(flipud(handles.bw));
alpha 0.2
hold off
close(f);





% --- Executes on button press in newRandImage_button.
function newRandImage_button_Callback(hObject, eventdata, handles)
% hObject    handle to newRandImage_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 create_grid_for_clustering_OpeningFcn(hObject, eventdata, ...
    handles,I,bw,labeled,CroppedMask,flag)
 updateImagebutton_Callback(hObject, eventdata, handles)
