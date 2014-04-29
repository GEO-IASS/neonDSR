function varargout = labelerFUMI(varargin)
%outputStruct = labelerFUMI(HylidImage)
%This takes in a subImage and outputs a structure that contains the
%hyperspectral data given labels of the data. Clicking on a pixel gives a
%dialogue box asking for the label of the clicked on pixel. A red x
%signifies that the pixel has already been selected.

% LABELERFUMI MATLAB code for labelerFUMI.fig
%      LABELERFUMI, by itself, creates a new LABELERFUMI or raises the existing
%      singleton*.
%
%      H = LABELERFUMI returns the handle to a new LABELERFUMI or the handle to
%      the existing singleton*.
%
%      LABELERFUMI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELERFUMI.M with the given input arguments.
%
%      LABELERFUMI('Property','Value',...) creates a new LABELERFUMI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labelerFUMI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labelerFUMI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labelerFUMI

% Last Modified by GUIDE v2.5 13-Jun-2012 13:07:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelerFUMI_OpeningFcn, ...
                   'gui_OutputFcn',  @labelerFUMI_OutputFcn, ...
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


% --- Executes just before labelerFUMI is made visible.
function labelerFUMI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labelerFUMI (see VARARGIN)

% Choose default command line output for labelerFUMI
set(hObject,'toolbar','figure');
handles.output = hObject;
handles.outputStruct = [];


handles.HylidImage = varargin{1};
image(handles.HylidImage.RGB);

handles.struct.labels = [];
handles.struct.Data = [];
handles.points =[];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes labelerFUMI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = labelerFUMI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.outputStruct;
close(handles.figure1);



% --- Executes on button press in selectbutton.
function selectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get clicked on pixel

handles = do_select(handles);
guidata(hObject, handles);

function handles = do_select(handles)

axes(handles.axes1);
[x, y] = ginput(1);
col = min(max(1,round(x)),size(handles.HylidImage.Data, 2));
row = min(max(1,round(y)),size(handles.HylidImage.Data, 1));
v = axis;
image(handles.HylidImage.RGB);
axis(v);
hold on;
plot(handles.axes1,col,row,'wx');
hold off;

label = str2double(inputdlg('Enter the label for the selected pixel:','Select Label',1));
if(isfinite(label))
    handles.struct.labels = [handles.struct.labels label];
    handles.struct.Data = [handles.struct.Data squeeze(handles.HylidImage.Data(row,col,:))];
    handles.points = [handles.points;[row col]];

end
if(~isempty(handles.points))
    hold on;
    plot(handles.axes1,handles.points(:,2),handles.points(:,1),'rx');
    hold off;
end


% --- Executes on button press in finishbutton.
function finishbutton_Callback(hObject, eventdata, handles)
% hObject    handle to finishbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.struct.Data = double(handles.struct.Data);
handles.outputStruct = handles.struct;
guidata(hObject, handles);
uiresume(handles.figure1);


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
    handles = do_select(handles);
    guidata(hObject,handles);
end
