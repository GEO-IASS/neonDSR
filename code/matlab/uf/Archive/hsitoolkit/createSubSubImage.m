function varargout = createSubSubImage(varargin)

%[out] = createSubSubImage(HSIfilename, groundTruth)
%input:
%hsi:  structure containing hyperspectral subimage with ground truth
%
%output:
%out:  structure holding selected sub-image and contained relevant data (struct)

gui_Singleton = 1; 
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @createSubSubImage_OpeningFcn, ...
    'gui_OutputFcn',  @createSubSubImage_OutputFcn, ...
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

% --- Executes just before createSubSubImage is made visible.
function createSubSubImage_OpeningFcn(hObject, eventdata, handles, varargin)

set(hObject,'toolbar','figure');

hsi = varargin{1};

handles.RGBImage = hsi.RGB;
handles.groundTruth = hsi.groundTruth;

handles.hsi = hsi;    

% Choose default command line output for createSubSubImage
handles.output = hObject;
handles.out = [];
% Update handles structure
guidata(hObject, handles);
drawRGB( hObject, handles)
uiwait(handles.figure1);

function drawRGB( hObject, handles)

axes(handles.axes1);
imagesc( handles.hsi.Easting, handles.hsi.Northing, handles.RGBImage);
set(gca,'YDir','normal');
%Plot Targets
hold on;
plot(handles.groundTruth.Targets_UTMx, handles.groundTruth.Targets_UTMy, 'wx');
hold off;
handles.pointSet = 0;
guidata(hObject, handles)

% --- Outputs from this function are returned to the command line.
function varargout = createSubSubImage_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.out;
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
xCoords = (handles.hsi.Easting >= xMin & handles.hsi.Easting <= xMax);
yCoords = (handles.hsi.Northing >= yMin & handles.hsi.Northing <= yMax);

imagesc( handles.hsi.Easting(xCoords), handles.hsi.Northing(yCoords), handles.RGBImage(yCoords,xCoords,:));
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
%handles.out=enviread(handles.HSIfilename, 'samples', handles.xMin:handles.xMax, 'lines',handles.yMin:handles.yMax);
hsi = handles.hsi;
handles.out = struct();

handles.out.OrigPixelRow = handles.yMin;
handles.out.OrigPixelCol = handles.xMin;

handles.out.Data = hsi.Data(handles.yMin:handles.yMax, handles.xMin:handles.xMax, :);
handles.out.Easting = hsi.Easting(handles.xMin:handles.xMax);
handles.out.Northing = hsi.Northing(handles.yMin:handles.yMax);


for t=1:numel(handles.out.Easting)
    [Lat,Lon] = utm2deg(handles.out.Easting(t),handles.out.Northing(1),'16 R');
    handles.out.Lon(t) = Lon;
end
for t=1:numel(handles.out.Northing)
    [Lat,Lon] = utm2deg(handles.out.Easting(1),handles.out.Northing(t),'16 R');
    handles.out.Lat(t) = Lat;
end
count = 1;
for i=1:64
    if handles.groundTruth.Targets_UTMx(i) <= max(handles.out.Easting)...
            && handles.groundTruth.Targets_UTMx(i) >= min(handles.out.Easting)...
            && handles.groundTruth.Targets_UTMy(i) <= max(handles.out.Northing)...
            && handles.groundTruth.Targets_UTMy(i) >= min(handles.out.Northing)
        handles.out.groundTruth.Targets_UTMx(count) = handles.groundTruth.Targets_UTMx(i);
        handles.out.groundTruth.Targets_UTMy(count) = handles.groundTruth.Targets_UTMy(i);
        handles.out.groundTruth.Targets_Lat(count) = handles.groundTruth.Targets_Lat(i);
        handles.out.groundTruth.Targets_Lon(count) = handles.groundTruth.Targets_Lon(i);
        handles.out.groundTruth.Targets_ID{count} = handles.groundTruth.Targets_ID{i};
        handles.out.groundTruth.Targets_Size(count) = handles.groundTruth.Targets_Size(i);
        handles.out.groundTruth.Targets_Type{count} = handles.groundTruth.Targets_Type{i};
        handles.out.groundTruth.Targets_Elevated(count) = handles.groundTruth.Targets_Elevated(i);
        handles.out.groundTruth.Targets_HumanCat(count) = handles.groundTruth.Targets_HumanCat(i);
        handles.out.groundTruth.Targets_HumanConf(count) = handles.groundTruth.Targets_HumanConf(i);
        temp2=handles.out.Northing - round(handles.out.groundTruth.Targets_UTMy(count));
        handles.out.groundTruth.Targets_rowIndices(count) = find(temp2 == 0);
        temp2=handles.out.Easting - round(handles.out.groundTruth.Targets_UTMx(count));
        handles.out.groundTruth.Targets_colIndices(count) = find(temp2 == 0);
        count=count+1;
    end
    
end

handles.out.info = hsi.info;
handles.out.info.samples = numel(handles.xMin:handles.xMax);
handles.out.info.lines = numel(handles.yMin:handles.yMax);
handles.out.RGB = handles.RGBImage(handles.yMin:handles.yMax, handles.xMin:handles.xMax,:);

x_rg = handles.xMin:handles.xMax;
y_rg = handles.yMin:handles.yMax;

if isfield(hsi,'Lidar')
   for i=1:numel(hsi.Lidar)
      handles.out.Lidar{i} = struct();
      handles.out.Lidar{i}.x = hsi.Lidar{i}.x(x_rg);
      handles.out.Lidar{i}.y = hsi.Lidar{i}.y(y_rg);
      handles.out.Lidar{i}.z = hsi.Lidar{i}.z(y_rg,x_rg,:);
      handles.out.Lidar{i}.info = hsi.Lidar{i}.info;
   end    
end

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
