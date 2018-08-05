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

% Last Modified by GUIDE v2.5 31-Jul-2018 15:57:03

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
    handles,I,bw,graindata)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_grid_for_clustering (see VARARGIN)
axes(handles.Image);
imagesc((bw))
alpha 0.2
hold off

handles.bw=bw;
handles.graindata=graindata;
% Choose default command line output for create_grid_for_clustering
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_grid_for_clustering wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
global clusterGrid;
fig=figure;
fig.Name='Choose the area of the polygon';
H=croping(handles.bw);
close
counter=1;
color=rand(1,3)
[h,l]=size(handles.bw)
if isfield(clusterGrid,'rowNo')
    clusterGrid.rowNo=clusterGrid.rowNo+1;
else
    clusterGrid.rowNo=1;
end
handles.rowNoText.String=string(clusterGrid.rowNo+1);
for i=1:length(handles.graindata)
    pixelX(i)=handles.graindata(i).Centroid(1);
    pixelY(i)=handles.graindata(i).Centroid(2);
end
for i=1:length(handles.graindata)
    if ~H(round(pixelY(i)),round(pixelX(i)))
        clusterGrid.gridindex(counter,clusterGrid.rowNo)=i;
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
global clusterGrid;
clusterGrid=[];


% --- Executes on button press in deleteSegmentedButton.
function deleteSegmentedButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSegmentedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global clusterGrid
for i=1:length(handles.graindata)
    pixelX(i)=handles.graindata(i).Centroid(1);
    pixelY(i)=handles.graindata(i).Centroid(2);
end
if ~isfield(clusterGrid,'deletedtuft')
    clusterGrid.deletedtuft=[];
end
[x_point,y_point] = getpts(handles.Image);
[h,l]=size(handles.bw);
for i=1:length(x_point)
        if x_point(i)>handles.Image.XLim(1) && x_point(i)<handles.Image.XLim(2)...
                && y_point(i)>handles.Image.YLim(1) && y_point(i)<handles.Image.YLim(2)
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[  pixelX' pixelY']));
            clusterGrid.deletedtuft=[clusterGrid.deletedtuft,index];
            
            for j=1:size(clusterGrid.gridindex,1)
                for k=1:size(clusterGrid.gridindex,2)
                    if clusterGrid.gridindex(j,k)==index;
                        clusterGrid.gridindex(j,k)=0;
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
