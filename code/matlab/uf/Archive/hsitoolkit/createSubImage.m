function varargout = createSubImage(varargin)

%[outputStruct] = createSubImage(HSIfilename, groundTruth)
%input:
%HSIfilename:  filename of the envi file containing hyperspectral data
%(note:  envi header file and RGB file must have same name and be in the
%same directory as the envi file containing the hyperspectral data) (text)
%groundTruth:  structure containing needed ground truth information(struct)
%
%output:
%outputStruct:  structure holding selected sub-image and contained relevant data (struct)

gui_Singleton = 1; 
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @createSubImage_OpeningFcn, ...
    'gui_OutputFcn',  @createSubImage_OutputFcn, ...
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

% --- Executes just before createSubImage is made visible.
function createSubImage_OpeningFcn(hObject, eventdata, handles, varargin)

set(hObject,'toolbar','figure');
handles.HSIfilename = varargin{1};
RGBFile = [handles.HSIfilename, '_RGB'];
load( RGBFile);

%Read UTM's from HDR file
HDRFile = [handles.HSIfilename, '.hdr']; 
HDRInfo = read_envihdr(HDRFile);
handles.UTM = makeGeoLocation(HDRInfo);

handles.RGBImage = RGBImage;
handles.groundTruth = varargin{2};
% Choose default command line output for createSubImage
handles.output = hObject;
handles.outputStruct = [];
% Update handles structure
guidata(hObject, handles);
drawRGB( hObject, handles)
uiwait(handles.figure1);

function drawRGB( hObject, handles)
axes(handles.axes1);
imagesc( handles.UTM.x, handles.UTM.y, handles.RGBImage);
set(gca,'YDir','normal');
%Plot Targets
hold on;
plot(handles.groundTruth.Targets_UTMx, handles.groundTruth.Targets_UTMy, 'wx');
hold off;
handles.pointSet = 0;
guidata(hObject, handles)

% --- Outputs from this function are returned to the command line.
function varargout = createSubImage_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.outputStruct;
close(handles.figure1);
delete(hObject);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

[x,y] = ginput(2);

xMin = round(min(x));
xMax = round(max(x));
yMin = round(min(y));
yMax = round(max(y));
axes(handles.axes1);
xCoords = (handles.UTM.x >= xMin & handles.UTM.x <= xMax);
yCoords = (handles.UTM.y >= yMin & handles.UTM.y <= yMax);

imagesc( handles.UTM.x(xCoords), handles.UTM.y(yCoords), handles.RGBImage(yCoords,xCoords,:));
set(gca,'YDir', 'normal');
hold on;
plot(handles.groundTruth.Targets_UTMx, handles.groundTruth.Targets_UTMy, 'wx');
hold off;


handles.xMin = find(xCoords,1, 'first');
handles.xMax = find(xCoords,1, 'last');
handles.yMin = find(yCoords,1, 'first');
handles.yMax = find(yCoords,1, 'last');
handles.pointSet = 1;
set(handles.pushbutton2,'enable', 'on')
set(handles.pushbutton3,'enable', 'on')
set(handles.pushbutton1,'enable', 'off')
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
fprintf('Sub-Image selected, preparing structure...');
handles.outputStruct=enviread(handles.HSIfilename, 'samples', handles.xMin:handles.xMax, 'lines',handles.yMin:handles.yMax);
handles.outputStruct.OrigPixelRow = handles.yMin;
handles.outputStruct.OrigPixelCol = handles.xMin;
handles.outputStruct.Data = handles.outputStruct.z;
handles.outputStruct = rmfield(handles.outputStruct, 'z');
handles.outputStruct.Easting = handles.outputStruct.x;
handles.outputStruct.Northing = handles.outputStruct.y;
handles.outputStruct = rmfield(handles.outputStruct, 'x');
handles.outputStruct = rmfield(handles.outputStruct, 'y');
for t=1:numel(handles.outputStruct.Easting)
    [Lat,Lon] = utm2deg(handles.outputStruct.Easting(t),handles.outputStruct.Northing(1),'16 R');
    handles.outputStruct.Lon(t) = Lon;
end
for t=1:numel(handles.outputStruct.Northing)
    [Lat,Lon] = utm2deg(handles.outputStruct.Easting(1),handles.outputStruct.Northing(t),'16 R');
    handles.outputStruct.Lat(t) = Lat;
end
count = 1;
for i=1:64
    if handles.groundTruth.Targets_UTMx(i) <= max(handles.outputStruct.Easting)...
            && handles.groundTruth.Targets_UTMx(i) >= min(handles.outputStruct.Easting)...
            && handles.groundTruth.Targets_UTMy(i) <= max(handles.outputStruct.Northing)...
            && handles.groundTruth.Targets_UTMy(i) >= min(handles.outputStruct.Northing)
        handles.outputStruct.groundTruth.Targets_UTMx(count) = handles.groundTruth.Targets_UTMx(i);
        handles.outputStruct.groundTruth.Targets_UTMy(count) = handles.groundTruth.Targets_UTMy(i);
        handles.outputStruct.groundTruth.Targets_Lat(count) = handles.groundTruth.Targets_Lat(i);
        handles.outputStruct.groundTruth.Targets_Lon(count) = handles.groundTruth.Targets_Lon(i);
        handles.outputStruct.groundTruth.Targets_ID{count} = handles.groundTruth.Targets_ID{i};
        handles.outputStruct.groundTruth.Targets_Size(count) = handles.groundTruth.Targets_Size(i);
        handles.outputStruct.groundTruth.Targets_Type{count} = handles.groundTruth.Targets_Type{i};
        handles.outputStruct.groundTruth.Targets_Elevated(count) = handles.groundTruth.Targets_Elevated(i);
        handles.outputStruct.groundTruth.Targets_HumanCat(count) = handles.groundTruth.Targets_HumanCat(i);
        handles.outputStruct.groundTruth.Targets_HumanConf(count) = handles.groundTruth.Targets_HumanConf(i);
        temp2=handles.outputStruct.Northing - round(handles.outputStruct.groundTruth.Targets_UTMy(count));
        handles.outputStruct.groundTruth.Targets_rowIndices(count) = find(temp2 == 0);
        temp2=handles.outputStruct.Easting - round(handles.outputStruct.groundTruth.Targets_UTMx(count));
        handles.outputStruct.groundTruth.Targets_colIndices(count) = find(temp2 == 0);
        count=count+1;
    end
    
end

handles.outputStruct.info.samples = numel(handles.xMin:handles.xMax);
handles.outputStruct.info.lines = numel(handles.yMin:handles.yMax);
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'header_offset');
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'file_type');
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'data_type');
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'interleave');
handles.outputStruct.info.sensor_type = 'HSI';
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'byte_order');
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'coordinate_system_string');
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'fwhm');
handles.outputStruct.info = rmfield(handles.outputStruct.info, 'hdrname');
handles.outputStruct.info.original_file_name = handles.HSIfilename;
handles.outputStruct.info.map_info = rmfield(handles.outputStruct.info.map_info, 'image_coords');
handles.outputStruct.info.map_info = rmfield(handles.outputStruct.info.map_info, 'mapx');
handles.outputStruct.info.map_info = rmfield(handles.outputStruct.info.map_info, 'mapy');
handles.outputStruct.RGB = handles.RGBImage(handles.yMin:handles.yMax, handles.xMin:handles.xMax,:);
fprintf('...Sub-Image structure created!\n');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
drawRGB( hObject, handles)
set(handles.pushbutton2,'enable', 'off')
set(handles.pushbutton3,'enable', 'off')
set(handles.pushbutton1,'enable', 'on')

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);

% --- Copied from enviread. TODO : Make a seperate function file?
function I=makeGeoLocation(info)
% Make geo-location vectors
if isfield(info, 'map_info')
    if isfield(info.map_info,'mapx') && isfield(info.map_info,'mapy')
        xi = info.map_info.image_coords(1);
        yi = info.map_info.image_coords(2);
        xm = info.map_info.mapx;
        ym = info.map_info.mapy;
        %adjust points to corner (1.5,1.5)
        if yi > 1.5
            ym =  ym + ((yi*info.map_info.dy)-info.map_info.dy);
        end
        if xi > 1.5
            xm = xm - ((xi*info.map_info.dy)-info.map_info.dx);
        end
        
        I.x= xm + ((0:info.samples-1).*info.map_info.dx);
        I.y = ym - ((0:info.lines-1).*info.map_info.dy);
    end
end
