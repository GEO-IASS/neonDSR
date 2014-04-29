function varargout = visualizer(varargin)
% Syntax: visualizer(HylidImage)
% Visualizer: Displays a subImage and with 5x5 red rectangles around each
%   target. The visualizer also plots the hyperspectral data and plots two
%   3d scatter plots, one using PCA and one using Dimension Reduction. The
%   points used in the plots are the selected point and all points within a
%   box that is centered around the selected pixel and has a radius of the
%   Ring Size value.
% input- HylidImage: structure output from createSubImage


% VISUALIZER MATLAB code for visualizer.fig
%      VISUALIZER, by itself, creates a new VISUALIZER or raises the existing
%      singleton*.
%
%      H = VISUALIZER returns the handle to a new VISUALIZER or the handle to
%      the existing singleton*.
%
%      VISUALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZER.M with the given input arguments.
%
%      VISUALIZER('Property','Value',...) creates a new VISUALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visualizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visualizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualizer

% Last Modified by GUIDE v2.5 13-Jun-2012 12:29:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualizer_OpeningFcn, ...
                   'gui_OutputFcn',  @visualizer_OutputFcn, ...
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


% --- Executes just before visualizer is made visible.
function visualizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualizer (see VARARGIN)

% Choose default command line output for visualizer
handles.output = hObject;

handles.HylidImage = varargin{1};
axes(handles.imageaxes);
image(handles.HylidImage.RGB);
for i=1:length(handles.HylidImage.groundTruth.Targets_rowIndices)
    rectangle('Position',[handles.HylidImage.groundTruth.Targets_colIndices(i)-2,handles.HylidImage.groundTruth.Targets_rowIndices(i)-2,4,4],'EdgeColor','r');
end
handles.ringSize = 1;
% Update handles structure
guidata(hObject, handles);






% --- Outputs from this function are returned to the command line.
function varargout = visualizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

%get new ring size
ringSize = str2double(get(hObject,'String'));
if (isnan(ringSize) || ringSize<0)
    set(hObject, 'String', handles.ringSize);
    ringSize = handles.ringSize;
    errordlg('Input must be a number greater than or equal to 0','Error');
end
handles.ringSize = ringSize;

guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in selectbutton.
function selectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

do_select(handles);


function do_select(handles)

%get clicked on pixel
[x, y] = ginput(1);
col = min(max(1,round(x)),size(handles.HylidImage.Data, 2));
row = min(max(1,round(y)),size(handles.HylidImage.Data, 1));
axes(handles.imageaxes);
v = axis;
image(handles.HylidImage.RGB);
for i=1:length(handles.HylidImage.groundTruth.Targets_rowIndices)
    rectangle('Position',[handles.HylidImage.groundTruth.Targets_colIndices(i)-2,handles.HylidImage.groundTruth.Targets_rowIndices(i)-2,4,4],'EdgeColor','r');
end
axis(v);
hold on;
plot(handles.imageaxes,col,row,'wx');
hold off;

window = shiftdim(handles.HylidImage.Data(row,col,:),1);
if(row ~= 1)
    Neigh = handles.HylidImage.Data(max(1,row-handles.ringSize):row-1,...
        max(1,col-handles.ringSize):min(size(handles.HylidImage.Data,2),col+handles.ringSize),:);
    window = [window; reshape(Neigh,size(Neigh,1)*size(Neigh,2),size(Neigh,3))];
end
if(row ~= size(handles.HylidImage.Data,1))
    Neigh = handles.HylidImage.Data(row+1:min(size(handles.HylidImage.Data,1),row+handles.ringSize),...
        max(1,col-handles.ringSize):min(size(handles.HylidImage.Data,2),col+handles.ringSize),:);
    window = [window; reshape(Neigh,size(Neigh,1)*size(Neigh,2),size(Neigh,3))];
end
if(col ~= 1)
    Neigh = handles.HylidImage.Data(row,max(1,col-handles.ringSize):col-1,:);
    window = [window; reshape(Neigh,size(Neigh,1)*size(Neigh,2),size(Neigh,3))];
end
if (col~=size(handles.HylidImage.Data,2))
    Neigh = handles.HylidImage.Data(row,col+1:min(col+handles.ringSize, size(handles.HylidImage.Data,2)),:);
    window = [window; reshape(Neigh,size(Neigh,1)*size(Neigh,2),size(Neigh,3))];
end

% plot spectra
axes(handles.plotaxes);
plot(handles.plotaxes,handles.HylidImage.info.wavelength, window','g');
hold(handles.plotaxes,'on');
plot(handles.plotaxes,handles.HylidImage.info.wavelength, window(1,:),'b');
hold(handles.plotaxes,'off');
xlabel(strcat('Wavelength(',handles.HylidImage.info.wavelength_units,')'));
ylim([min(min(window(:)),0) max(max(window(:)),1)]);

% do pca
[~, score] = princomp(window);

% plot pca'd
axes(handles.pcaaxes);
scatter3(score(2:end,1),score(2:end,2),score(2:end,3),'g','filled','SizeData', 75);
hold(handles.pcaaxes,'on');
scatter3(score(1,1),score(1,2),score(1,3),'b', 'filled', 'SizeData',75);
hold(handles.pcaaxes,'off');
xlabel('One');
ylabel('Two');
zlabel('Three');

% do dimension reduction
smallImage.MeasuredData = reshape(window,1,size(window,1),size(window,2));
smallImage.info  = handles.HylidImage.info;
dimParameters.numBands = 3;
dimParameters.type = 'complete'; %Type of Hierarchy
dimParameters.showH = 0; %Set to 1 to show clustering, 0 otherwise
dimParameters.NumCenters = 255; %Number of centers used in computing KL-divergence
dimReducedstruct = dimReduction(smallImage,dimParameters);
axes(handles.dimReductionaxes);

% plot hierarchical dimension reduced
scatter3(dimReducedstruct.MeasuredData(1,2:end,1),dimReducedstruct.MeasuredData(1,2:end,2),...
    dimReducedstruct.MeasuredData(1,2:end,3),'g','filled','SizeData', 75);
hold(handles.dimReductionaxes,'on');
scatter3(dimReducedstruct.MeasuredData(1,1,1),dimReducedstruct.MeasuredData(1,1,2),dimReducedstruct.MeasuredData(1,1,3),'b', 'filled', 'SizeData',75);
hold(handles.dimReductionaxes,'off');
xlabel('One');
ylabel('Two');
zlabel('Three');


% --- Executes on button press in closebutton.
function closebutton_Callback(hObject, eventdata, handles)
% hObject    handle to closebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

char = eventdata.Character;

if lower(char) == 's'
    do_select(handles);
end
    
