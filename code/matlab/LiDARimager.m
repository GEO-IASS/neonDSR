function LiDARimager(functioncall)
%hillshade generation includes portions of a script found on Matlab Central
%Link: http://www.mathworks.ch/matlabcentral/fileexchange/14863
%nansumOZ and nanmeanOZ are essentially Matlab functions with the same
%name, as provided with the statistics toolbox; to have LiDARimager
%operating without any additional toolboxes, these two functions were
%included here
%UTM to DD and DD to UTM conversion were found on the internet (see link);
%projection is hard-wired to WGS84.
%Link: http://www.uwgb.edu/dutchs/usefuldata/utmformulas.htm

    if (nargin >= 1)
        switch functioncall
            case 'quit'
                answer = questdlg('Really quit LiDARimager?','','Yes','No','No');
                if (strcmp (answer, 'Yes'));
                    delete(gcbf);
                end
            case 'About';                   About;   
            case 'LoadFile';                LoadFile;
            case 'SurfDEM';                 SurfDEM;
            case 'Azimuth';                 Azimuth;
            case 'Zenith';                  Zenith;
            case 'Z_factor';                Z_factor;   
            case 'SaveF';                   SaveF;
            case 'GetCoordinates';          GetCoordinates;
            case 'MakeKMZFile';             MakeKMZFile;
            case 'UTMzones';                UTMzones;
            case 'GetGeoCoordinates';       GetGeoCoordinates;
            case 'ViewAzi';                 ViewAzi;
            case 'ViewZen';                 ViewZen;
            case 'ViewZfact';               ViewZfact;
            case 'ChangeViewAngle';         ChangeViewAngle;
            case 'nanmeanOZ';               nanmeanOZ;
            case 'nansumOZ';                nansumOZ;
            case 'ContNumbaz';              ContNumbaz;
            case 'TranspA';                 TranspA;
            case 'TranspB';                 TranspB;      
            case 'DrapeA';                  DrapeA;
            case 'DrapeB';                  DrapeB;   
            case 'MakeDrape';               MakeDrape;
            otherwise
                error('Unrecognized function call.');
        end 
    else
        mainfig = create_gui;
        set(mainfig,'Visible','on');
        drawnow;
    end
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------    
%--------------------------------------------------------------------------             
    function LiDARimagerFig = FigHandle
        LiDARimagerFig = findobj(allchild(0),'Tag','LiDARimagerFigure');     
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------                    
    function LiDARimagerFig = create_gui

        LiDARimagerFig = figure('Position',[20 50 800 350],'CloseRequestFcn', ...
                         'LiDARimager quit','Resize','off','menubar','none',...
                         'NumberTitle','off','Name','LiDARimager', ...
                         'Color',[0.65 0.65 0.65],'Colormap',gray(256),'Tag','LiDARimagerFigure');
    
        create_menus(LiDARimagerFig);
        set_initialvalues(LiDARimagerFig);
        create_guiobjects(LiDARimagerFig);       
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------     
    function set_initialvalues(LiDARimagerFig)  
        
        parameters.loadname        = ''; % name of the xyz data set I want to load
        parameters.savename        = ''; % name of the xyz data set I want to load
        %initial values
        parameters.fileextension   = 1;
        parameters.saveextension   = 1;
        parameters.DefaultAzi      = 315;
        parameters.DefaultZni      = 20;
        parameters.DefaultZfct     = 1;
        parameters.UsedAzimuth     = 315;
        parameters.UsedZenith      = 20;
        parameters.Z_factor        = 1;
        %empty values
        parameters.Easting         = [];
        parameters.Northing        = [];
        parameters.Hillshadmap     = [];
        parameters.Slopemap        = [];
        parameters.Aspectmap       = [];
        parameters.cellsize        = [];
        parameters.Realcellsize    = [];
        parameters.ViewAzimuthbox  = [];
        parameters.ViewZenithbox   = [];
        parameters.ViewZfactbox    = [];
        parameters.ViewQuickbox    = [];
        
        parameters.dElev_dx        = [];
        parameters.dElev_dy        = [];
        %boxes
        parameters.loadnamebox     = [];
        parameters.savenamebox     = [];
        parameters.filetypebox     = [];
        parameters.savetypebox     = [];
        parameters.ElevPlotBox     = [];
        parameters.HshdPlotBox     = [];
        parameters.SlopePlotBox    = [];
        parameters.AspectPlotBox   = [];
        parameters.hemisphtypebox  = [];
        parameters.GridSwitchbox   = [];
        parameters.Quickdrawbox    = [];
        parameters.DrapeAbox       = [];
        parameters.DrapeBbox       = [];
        parameters.DrapChkBox      = [];
        parameters.ColMapAbox      = [];
        parameters.ColMapBbox      = [];
        parameters.ColMaps         = {' gray', ' 1/gray', ' bone',' 1/bone',' jet',' hsv',' topo',' cool',' hot',' spring',' summer',' autumn',' winter'};
        parameters.TopoCols        = [ 18  54  36; 20  57  39; 23  61  42; 25  64  45; 28  68  48; 30  71  50; 32  75  54; 35  78  56;...
                                       37  82  59; 40  85  62; 42  88  65; 44  92  68; 47  96  71; 49  99  74; 52 103  77; 54 106  80;...
                                       56 109  83; 59 113  86; 69 120  87; 78 127  87; 88 134  88; 97 141  89;107 148  90;117 155  91;...
                                      126 162  92;136 169  92;145 176  93;155 183  94;164 190  95;174 197  95;184 204  96;193 211  97;...
                                      203 218  98;212 225  99;222 232  99;232 239 100;241 246 101;251 253 102;244 244 100;237 234  98;...
                                      231 225  97;224 216  95;217 206  93;210 197  91;203 188  90;196 179  88;190 169  86;183 160  84;...
                                      176 150  83;169 141  81;162 132  79;156 123  77;149 113  76;142 104  74;135  95  72;129  85  70;...
                                      122  76  69;115  67  67;138  98  98;161 130 130;185 161 161;208 192 192;232 224 224;255 255 255];
        parameters.TopoCols        = parameters.TopoCols./255;
        parameters.AllColorMaps    = [colormap(gray(64));flipud(colormap(gray(64)));colormap(bone(64));flipud(colormap(bone(64)));colormap(jet(64));colormap(hsv(64));parameters.TopoCols;colormap(cool(64));colormap(hot(64));colormap(spring(64));colormap(summer(64));colormap(autumn(64));colormap(winter(64))];
        %figure handles

        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');
        set(LiDARimagerFig,'UserData',parameters);        
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------          
    function create_menus(LiDARimagerFig)

        uimenu('parent',LiDARimagerFig,'label','&About','Callback','LiDARimager About');       
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------          
    function About

        figA = figure('Position',[100 500 300 200],'Resize','off','NumberTitle',...
                         'off','Name','About LiDARimager','Color',[0.8 0.8 0.8],...
                         'menubar','none');
                     
        uicontrol('Parent',figA,'Style','text','String','LiDARimager',...
                  'Position',[30 150 250 30],'BackgroundColor',[0.8 0.8 0.8],...
                  'FontSize',12,'FontWeight','bold','HorizontalAlignment','center');
        uicontrol('Parent',figA,'Style','text','String',' A tool to visualize LiDAR data and create *.jpg files, *.kmz files, and cropped *.asc files', ...
                  'BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'Position',[30 70 250 80], ...
                  'FontWeight','bold','HorizontalAlignment','center');
        uicontrol('Parent',figA,'Style','text','String','written by Olaf Zielke',...
                  'Position',[30 60 250 20],'BackgroundColor', [0.8 0.8 0.8],'FontSize',10,...
                  'HorizontalAlignment','center');
        uicontrol('Parent',figA,'Style','text','String','Arizona State University',...
                  'Position',[30 40 250 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10,...
                  'HorizontalAlignment','center');
        uicontrol('Parent',figA,'Style','text','String','(C) 2010','Position',[30 20 250 20],...
                  'BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'HorizontalAlignment','center');
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------
    function create_guiobjects(LiDARimagerFig)
        parameters = get(LiDARimagerFig,'UserData');
%--------------------------------------------------------------------------               
% the frames: % the frames
        uicontrol('parent',LiDARimagerFig,'Style','frame','Position',[20,185,555,90],'BackgroundColor',[0.6 0.7 0.6]);     
        uicontrol('parent',LiDARimagerFig,'Style','frame','Position',[300,280,490,65],'BackgroundColor',[0.7 0.6 0.6]);     
        uicontrol('parent',LiDARimagerFig,'Style','frame','Position',[20,15,770,50],'BackgroundColor',[0.6 0.6 0.7]); 
        uicontrol('parent',LiDARimagerFig,'Style','frame','Position',[580,75,210,200],'BackgroundColor',[0.7 0.6 0.6]);  
        uicontrol('parent',LiDARimagerFig,'Style','frame','Position',[365,115,210,65],'BackgroundColor',[0.7 0.6 0.6]);
        uicontrol('parent',LiDARimagerFig,'Style','frame','Position',[20,115,330,65],'BackgroundColor',[0.7 0.6 0.6]);  
%-------------------------------------------------------------------------
% now the popupmenus:
        parameters.filetypebox   = uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',10,'Position',[300 204 125 20],'value', parameters.fileextension,...
                                             'backgroundcolor',[0.85 0.85 0.85],'String',{' .asc (ARC grid)' ' .asc (ASCII grid)'});   
        parameters.savetypebox   = uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',10,'Position',[570 32 60 20],'value', parameters.saveextension,...
                                             'backgroundcolor',[0.85 0.85 0.85],'String',{' .jpg' ' .kmz' ' .asc (ARC grid)'});   
       
        parameters.hemisphtypebox= uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',10,'Position',[270 32 40 20],'value', 1,...
                                             'backgroundcolor',[0.85 0.85 0.85],'String',{' N' ' S'});   
       
        parameters.HshdPlotBox   = uicontrol('parent',LiDARimagerFig,'Style','checkbox','String','Hillshade plot:','FontSize',11,...
                                             'Position',[590,245,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',1);          
        parameters.SlopePlotBox  = uicontrol('parent',LiDARimagerFig,'Style','checkbox','String','Slope plot','FontSize',11,...
                                             'Position',[590,110,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',0);          
        parameters.AspectPlotBox = uicontrol('parent',LiDARimagerFig,'Style','checkbox','String','Aspect plot','FontSize',11,...
                                             'Position',[590,80,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',0);          
        parameters.ElevPlotBox   = uicontrol('parent',LiDARimagerFig,'Style','checkbox','String','Elevation','FontSize',11,...
                                             'Position',[590,140,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',0);          

                                         
                                         
        parameters.ContPlotBox    = uicontrol('parent',LiDARimagerFig,'Style','checkbox','String','Overlay with contours','FontSize',11,...
                                             'Position',[405,152,160,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',0);          
          
         
                                         
        parameters.smoothingbox  = uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',10,'Position',[240 240 40 20],'value', 1,...
                                             'backgroundcolor',[0.85 0.85 0.85],'String',{' 0' ' 3' ' 5' ' 7' ' 9' ' 11' ' 13' ' 15' ' 17' ' 19'});                 
        
        parameters.Quickdrawbox  = uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',10,'Position',[500 240 70 20],'value', 1,...
                                             'backgroundcolor',[0.85 0.85 0.85],'String',{' None' ' 2-Quick' ' 3-Quick' ' 4-Quick' ' 5-Quick'});                 
        
        parameters.GridSwitchbox = uicontrol('parent',LiDARimagerFig,'style','checkbox','Fontsize',10,'Position',[710 80 70 20],'value', 0,...
                                             'backgroundcolor',[0.7 0.6 0.6],'String','Plot Grid');             
%--------------------------------------------------------------------------
% the buttons:        
        uicontrol('parent',LiDARimagerFig,'style','pushbutton','Fontsize',12,'Position',[435 197 135 30],...
                   'String','1.) Load DEM','callback','LiDARimager LoadFile');   
        uicontrol('parent',LiDARimagerFig,'style','pushbutton','Fontsize',12,'Position',[250 75 200 30],...
                   'String','2.) Plot DEM','callback','LiDARimager SurfDEM');    
        uicontrol('parent',LiDARimagerFig,'style','pushbutton','Fontsize',12,'Position',[640 25 140 30],...
                   'String','3.) Save images','callback','LiDARimager SaveF');            
%--------------------------------------------------------------------------       
% the edit fields:
        parameters.loadnamebox     = uicontrol('parent',LiDARimagerFig,'Style','edit','String',parameters.loadname,'FontSize',10,...
                                               'Position',[140,202,150,20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
        parameters.savenamebox     = uicontrol('parent',LiDARimagerFig,'Style','edit','String',parameters.savename,'FontSize',10,...
                                               'Position',[410,30,150,20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
        parameters.UTMzonebox      = uicontrol('parent',LiDARimagerFig,'Style','edit','String',11,'FontSize',10,...
                                               'Position',[120,30,35,20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'Callback','LiDARimager UTMzones');
       
        parameters.UsedAzimuthBox  = uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[730,210,50,20],...
                                               'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'String',parameters.DefaultAzi,'Callback','LiDARimager Azimuth');        
        parameters.UsedZenithBox   = uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[730,185,50,20],...
                                               'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'String',parameters.DefaultZni,'Callback','LiDARimager Zenith');                   
        parameters.UsedZ_FactorBox = uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[730,160,50,20],...
                                               'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'String',parameters.DefaultZfct,'Callback','LiDARimager Z_factor');
                                           
        parameters.ContIntvBox     = uicontrol('parent',LiDARimagerFig,'Style','edit','String','1','FontSize',11,...
                                             'Position',[370,125,50,20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'callback', 'LiDARimager ContNumbaz');          
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Contour inverval (m)','FontSize',11,...
                                             'Position',[430,125,140,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);          
           
         
                                         
        uicontrol('parent',LiDARimagerFig,'Style','text','String','View Azimuth:','FontSize',11,...
                  'Position',[30,150,92,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);                                                                       
        parameters.ViewAzimuthbox  =uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[120,152,30,20],...
                                               'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'String',0,'Callback','LiDARimager ViewAzi');             
        uicontrol('parent',LiDARimagerFig,'Style','text','String','View Zenith:','FontSize',11,...
                  'Position',[190,150,92,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);                                                                  
        parameters.ViewZenithbox  =uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[275,152,30,20],...
                                               'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'String',90,'Callback','LiDARimager ViewZen'); 
        uicontrol('parent',LiDARimagerFig,'Style','text','String','View Z-factor:','FontSize',11,...
                  'Position',[30,120,90,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);                                                                  
        parameters.ViewZfactbox  =uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[125,122,30,20],...
                                               'HorizontalAlignment','right','BackgroundColor',[1 1 1],...
                                               'String',1,'Callback','LiDARimager ViewZfact');                                    
                                           
                                           
        parameters.ViewQuickbox = uicontrol('parent',LiDARimagerFig,'Style','checkbox','String','3D-Clean','FontSize',11,...
                                             'Position',[190,122,90,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',0);          
%--------------------------------------------------------------------------       
% the text field:   
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Moving average (box-car) over','FontSize',11,...
                  'Position',[30,235,200,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.7 0.6]);
        uicontrol('parent',LiDARimagerFig,'Style','text','String','grid points.','FontSize',11,...
                  'Position',[290,235,70,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.7 0.6]);
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Quick draw:','FontSize',11,...
                  'Position',[410,235,90,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.7 0.6]);
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Input file name:','FontSize',11,...
                  'Position',[30,200,100,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.7 0.6]);
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Save name:','FontSize',11,...
                  'Position',[330,30,80,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.6 0.7]);
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Azimuth:','FontSize',11,...
                  'Position',[615,210,80,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Zenith:','FontSize',11,...
                  'Position',[615,185,80,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);                            
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Z-factor:','FontSize',11,...
                  'Position',[615,160,80,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);    
              
        uicontrol('parent',LiDARimagerFig,'Style','text','String','UTM zone:','FontSize',11,...
                  'Position',[30,30,80,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.6 0.7]);    
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Hemisphere:','FontSize',11,...
                  'Position',[175,30,95,20],'HorizontalAlignment','left','BackgroundColor',[0.6 0.6 0.7]);  
        
              
        parameters.DrapChkBox   = uicontrol('parent',LiDARimagerFig,'Style','checkbox','FontSize',11,'Callback', 'LiDARimager MakeDrape',...
                                             'Position',[302,316,20,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6],'value',0);       
        uicontrol('parent',LiDARimagerFig,'Style','text','String','Drape','FontSize',11,...
                  'Position',[320,315,40,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);  
        parameters.DrapeAbox= uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',11,'Position',[370 320 90 20],'value', 3,...
                                        'backgroundcolor',[0.85 0.85 0.85],'String',{' Hillshade' ' Elevation' ' Slope' ' Aspect'},'Callback', 'LiDARimager DrapeA');        
        uicontrol('parent',LiDARimagerFig,'Style','text','String','with transperency','FontSize',11,...
                  'Position',[465,315,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);  
        parameters.TranspAbox  =uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[590,315,30,20],'String',0.5,'Callback','LiDARimager TranspA');        
        uicontrol('parent',LiDARimagerFig,'Style','text','String','& colormap','FontSize',11,...
                  'Position',[625,315,80,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);  
        parameters.ColMapAbox= uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',11,'Position',[710 320 75 20],'value', 3,...
                                        'backgroundcolor',[0.85 0.85 0.85],'String',parameters.ColMaps,'Value',5);        
        
        uicontrol('parent',LiDARimagerFig,'Style','text','String','over','FontSize',11,...
                  'Position',[330,285,30,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);       
        parameters.DrapeBbox= uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',11,'Position',[370 290 90 20],'value', 1,...
                                        'backgroundcolor',[0.85 0.85 0.85],'String',{' Hillshade' ' Elevation' ' Slope' ' Aspect'},'Callback', 'LiDARimager DrapeB');
        uicontrol('parent',LiDARimagerFig,'Style','text','String','with transperency','FontSize',11,...
                  'Position',[465,285,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]); 
        parameters.TranspBbox  =uicontrol('parent',LiDARimagerFig,'Style','edit','FontSize',10,'Position',[590,285,30,20],'String',1,'Callback','LiDARimager TranspB');        
        uicontrol('parent',LiDARimagerFig,'Style','text','String','& colormap','FontSize',11,...
                  'Position',[625,285,120,20],'HorizontalAlignment','left','BackgroundColor',[0.7 0.6 0.6]);  
        parameters.ColMapBbox= uicontrol('parent',LiDARimagerFig,'style','popupmenu','Fontsize',11,'Position',[710 290 75 20],'value', 3,...
                                        'backgroundcolor',[0.85 0.85 0.85],'String',parameters.ColMaps,'Value',1);           
                          
        
       set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');      
%--------------------------------------------------------------------------  
%--------------------------------------------------------------------------       
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------        
    function Azimuth
        LiDARimagerFig       = FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        
        value1        = str2double(get(parameters.UsedAzimuthBox,'string')); 

        if isnan(value1)||(value1 <0)||(value1 >360)
            errordlg('Entered value not valid -Enter a number. Make sure it is an angle between 0 and 360 degrees.');
            set(parameters.UsedAzimuthBox,'string',parameters.DefaultAzi); 
            parameters.UsedAzimuth = parameters.DefaultAzi;
        end     
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');        
%------------------------------------------------------------------
    function Zenith
        LiDARimagerFig       = FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.UsedZenithBox,'string')); 

        if isnan(value1)||(value1 <=0)||(value1 >90)
            errordlg('Entered value not valid -Enter a number. Make sure it is an angle between 0 and 90 degrees.');
            set(parameters.UsedZenithBox,'string',parameters.DefaultZni); 
            parameters.UsedZenith = parameters.DefaultZni;
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');    
%------------------------------------------------------------------
    function Z_factor
        LiDARimagerFig       = FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        
        value1        = str2double(get(parameters.UsedZ_FactorBox,'string')); 

        if isnan(value1)||(value1 ==0)
            errordlg('Entered value not valid -Enter a number. Make sure it is a non-zero number');
            set(parameters.UsedZ_FactorBox,'string',parameters.DefaultZfct); 
            parameters.UsedZ_factor = parameters.DefaultZfct;
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');  
%------------------------------------------------------------------
    function ViewZen
        LiDARimagerFig       = FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.ViewZenithbox,'string')); 
        if isnan(value1)||(value1<0)||(value1>90)
            errordlg('Entered value not valid -Enter a number. Make sure it is a number between 0 and 90');
            set(parameters.ViewZenithbox,'string',90); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');  
%------------------------------------------------------------------            
    function ViewAzi
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.ViewAzimuthbox,'string')); 

        if isnan(value1)||(value1<0)||(value1>360)
            errordlg('Entered value not valid -Enter a number. Make sure it is a number between 0 and 360');
            set(parameters.ViewAzimuthbox,'string',0); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');  
%--------------------------------------------------------------------------        
    function ViewZfact
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.ViewZfactbox,'string')); 

        if isnan(value1)||(value1<=0)
            errordlg('Entered value not valid -Enter a number. Make sure it is a number between 0 and 360');
            set(parameters.ViewZfactbox,'string',1); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');      
%--------------------------------------------------------------------------        
    function TranspA
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.TranspAbox,'string')); 

        if isnan(value1)||(value1<=0)||(value1>1)
            errordlg('Entered value not valid -Enter a number. Make sure it is a number between >0 and <=1');
            set(parameters.TranspAbox,'string',0.5); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');    
%--------------------------------------------------------------------------        
    function TranspB
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.TranspBbox,'string')); 

        if isnan(value1)||(value1<=0)||(value1>1)
            errordlg('Entered value not valid -Enter a number. Make sure it is a number between >0 and <=1');
            set(parameters.TranspBbox,'string',1); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');             
%--------------------------------------------------------------------------        
    function DrapeA
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = get(parameters.DrapeAbox,'value'); 
        if     value1 == 1
            set(parameters.HshdPlotBox,'value',1);
        elseif value1 == 2
            set(parameters.ElevPlotBox,'value',1);
        elseif value1 == 3
            set(parameters.SlopePlotBox,'value',1);
        elseif value1 == 4
            set(parameters.AspectPlotBox,'value',1);
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback'); 
%------------------------------------------------------------------      
    function DrapeB
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = get(parameters.DrapeBbox,'value'); 
        if     value1 == 1
            set(parameters.HshdPlotBox,'value',1);
        elseif value1 == 2
            set(parameters.ElevPlotBox,'value',1);
        elseif value1 == 3
            set(parameters.SlopePlotBox,'value',1);
        elseif value1 == 4
            set(parameters.AspectPlotBox,'value',1);
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback'); 
 %------------------------------------------------------------------      
    function MakeDrape 
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = get(parameters.DrapChkBox,'value'); 
        if (value1 == 1),            DrapeA;            DrapeB;        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback'); 
%------------------------------------------------------------------        
    function UTMzones
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.UTMzonebox,'string')); 

        if isnan(value1)||(value1 <=0)
            errordlg('Entered value not valid -Enter a number. Make sure it is a non-zero number');
            set(parameters.UTMzonebox,'string',11); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');  
%------------------------------------------------------------------   
    function ContNumbaz
        LiDARimagerFig= FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        value1        = str2double(get(parameters.ContIntvBox,'string')); 

        if isnan(value1)||(value1 <=0)
            errordlg('Entered value not valid -Enter a number. Make sure it is a non-zero number');
            set(parameters.ContIntvBox,'string',1); 
        end   
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');                   
%--------------------------------------------------------------------------         
    function LoadFile
        LiDARimagerFig       = FigHandle;
        parameters    = get(LiDARimagerFig,'UserData'); 
        filetype      = get(parameters.filetypebox,'Value');
        extension     = '.asc';
        filename      = get(parameters.loadnamebox,'String');
        filename1     = strcat(filename,extension); 
        fid           = fopen(filename1,'r');
        QuickDrawstep = get(parameters.Quickdrawbox,'value');
        if (fid == -1)
            errordlg('The entered filename has not been found. Make sure that the file is in the same folder as the GUI. Change filename and/or make sure that the file has the correct ending.');
            return;
        end
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx          
        parameters.Elevation   = [];
        parameters.dElev_dx    = [];
        parameters.dElev_dy    = [];
        parameters.Aspectmap   = [];
        parameters.Slopemap    = [];
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx          
        if (filetype == 2)
            %---------------------
            firstline    = fgetl(fid);      northval     = str2double(firstline(8:length(firstline))); %#ok<NASGU>
            secondline   = fgetl(fid);      yllcorner    = str2double(secondline(8:length(secondline)));
            thirddline   = fgetl(fid);      eastval      = str2double(thirddline(7:length(thirddline)));
            fourthline   = fgetl(fid);      xllcorner    = str2double(fourthline(7:length(fourthline)));
            fifthline    = fgetl(fid);      nrows        = str2double(fifthline(7:length(fifthline)));
            sixthline    = fgetl(fid);      ncols        = str2double(sixthline(7:length(sixthline)));         
            
            nrows2       = ceil(nrows/QuickDrawstep);
            ncols2       = ceil(ncols/QuickDrawstep);
            Elevation    = zeros(nrows2,ncols2)+NaN;
            PosiCounter  = 0;
            for run = 1 : nrows
               if round(run/QuickDrawstep)*QuickDrawstep == run %read every other line
                   PosiCounter              = PosiCounter+1; 
                   ElevLine                 = sscanf(fgetl(fid),'%f');
                   Elevation(PosiCounter,:) = ElevLine((1:QuickDrawstep:ncols),1);
               else
                   ElevLine                 = fgetl(fid);
               end
            end   
            cellsize                = (eastval-xllcorner)/ncols2;
            parameters.Realcellsize = (eastval-xllcorner)/ncols;
            NODATA_value = -9999;
            %---------------------
        elseif (filetype == 1)
            %---------------------
            firstline    = fgetl(fid);      ncols        = str2double(firstline(7:length(firstline)));
            secondline   = fgetl(fid);      nrows        = str2double(secondline(7:length(secondline)));
            thirddline   = fgetl(fid);      xllcorner    = str2double(thirddline(11:length(thirddline)));
            fourthline   = fgetl(fid);      yllcorner    = str2double(fourthline(11:length(fourthline)));
            fifthline    = fgetl(fid);      cellsize     = str2double(fifthline(10:length(fifthline)));
            sixthline    = fgetl(fid);      NODATA_value = str2double(sixthline(14:length(sixthline)));        
            
            nrows2       = ceil(nrows/QuickDrawstep);
            ncols2       = ceil(ncols/QuickDrawstep);
            Elevation    = zeros(nrows2,ncols2)+NaN;
            PosiCounter  = 0;
            for run = 1 : nrows
               if round(run/QuickDrawstep)*QuickDrawstep == run %read every other line
                   PosiCounter              = PosiCounter+1; 
                   ElevLine                 = sscanf(fgetl(fid),'%f');
                   Elevation(PosiCounter,:) = ElevLine((1:QuickDrawstep:ncols),1);
               else
                   ElevLine                 = fgetl(fid);
               end
            end 
            parameters.Realcellsize = cellsize;
            cellsize                = cellsize*QuickDrawstep;
            
        end
        fclose(fid);
        %------------------------------------------------------------------
        Elevation(Elevation(:,:)==NODATA_value) = NaN;
        if parameters.Realcellsize < 0.01
            disp('Cell size:');
            disp(parameters.Realcellsize);
            disp('Value uncharacteristically low, suggesting imported data are in geographic coordinates. Will be translated to UTM coordinates, using the UTM zone and hemishpere, specified in the GUI.');
            
            [xllcorner1,yllcorner1] = GetGeoCoordinates(xllcorner,yllcorner);
            [xllcorner2,yllcorner2] = GetGeoCoordinates(xllcorner+1,yllcorner+1);
            parameters.Realcellsize = (parameters.Realcellsize *(xllcorner2-xllcorner1) +parameters.Realcellsize*(yllcorner2-yllcorner1))/2;
            cellsize                = (cellsize *(xllcorner2-xllcorner1) +cellsize*(yllcorner2-yllcorner1))/2;
            disp('Projected Easting of lower left corner:');
            disp(xllcorner1);
            disp('Projected Northing of lower left corner:');
            disp(yllcorner1);   
            disp('Cell size of data set im meter:');
            disp(parameters.Realcellsize);
        else
            disp('Cell size of data set im meter:');
            disp(parameters.Realcellsize);
            xllcorner1 = xllcorner;
            yllcorner1 = yllcorner;
        end
        Easting    = xllcorner1:cellsize:(xllcorner1+(ncols2-1)*cellsize);      Northing   = yllcorner1:cellsize:(yllcorner1+(nrows2-1)*cellsize);    
        Elevation  = flipud(Elevation);                                         NewElev    = Elevation;
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        smoothvalue = get(parameters.smoothingbox,'value');
        for runE = 1 : ncols2-1
            for runN = 1 : nrows2-1
                if smoothvalue > 1
                    shiftval=smoothvalue -1;
                    if ((runE >=1+shiftval)&&(runE <=ncols2-1-shiftval)) && ((runN >=1+shiftval)&&(runN <=nrows2-1-shiftval))
                        NewElev(runN,runE) = nanmeanOZ(nanmeanOZ(Elevation((runN-shiftval):(runN+shiftval),(runE-shiftval):(runE+shiftval))));          
                    end 
                else
                    if ((runE>=5)&&(runE<ncols2-4))&&((runN>=5)&&(runN<nrows2-4))
                        if isnan(Elevation(runN,runE)),      NewElev(runN,runE) = nanmeanOZ(nanmeanOZ(Elevation((runN-4):(runN+4),(runE-4):(runE+4))));      end
                    end
                end 
            end
        end
                
        Elevation = NewElev;
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        dx = abs(Easting(2) -Easting(1));  % get cell spacing in x and y direction
        dy = abs(Northing(2)-Northing(1)); % from coordinate vectors
            
        [dElev_dx, dElev_dy]   = gradient(Elevation,dx,dy);
        parameters.Easting     = Easting;
        parameters.Northing    = Northing;
        parameters.Elevation   = Elevation;
        parameters.dElev_dx    = dElev_dx;
        parameters.dElev_dy    = dElev_dy;
        parameters.Aspectmap   = zeros(nrows2,ncols2);
        parameters.Slopemap    = zeros(nrows2,ncols2);
        parameters.cellsize    = cellsize;
        clear Easting Northing Elevation NewElev dElev_dx dElev_dy cellsize
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');    
        % mach hier die berrecung fuer slope und so
        % habe beide delta werte -hab dann also drei punkte
        for runE = 1 : ncols2-1
            for runN = 1 : nrows2-1
                v1        = [cos(atan(4*parameters.dElev_dx(runN,runE))), 0, sin(atan(4*parameters.dElev_dx(runN,runE)))];
                v2        = [0, cos(atan(4*parameters.dElev_dy(runN,runE))), sin(atan(4*parameters.dElev_dy(runN,runE)))];
                norm_vect = [(v1(1,2)*v2(1,3)-v1(1,3)*v2(1,2)),(v1(1,3)*v2(1,1)-v1(1,1)*v2(1,3)),(v1(1,1)*v2(1,2)-v1(1,2)*v2(1,1))];
                %now use the norm_vect to get strike and dip
                plunge_radians = asin(norm_vect(1,3));
                trend_radians  = atan2(norm_vect(1,2),norm_vect(1,1));
                if (trend_radians < 0),         trend_radians = trend_radians+2*pi;     end
                if (plunge_radians >0),
                    plunge_radians = plunge_radians.*-1;
                    trend_radians = trend_radians+pi/2;
                    if (trend_radians >2*pi),   trend_radians = trend_radians-2*pi;     end
                end
                parameters.Slopemap(runN,runE)  = (plunge_radians)*180/pi +90;
                parameters.Aspectmap(runN,runE) = (trend_radians)*180/pi;  
            end
        end

        disp('Cell size of imported DEM in meter:');disp(parameters.cellsize);
        msgbox('Data import completed');
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');
%-------------------------------------------------------------------------- 
    function SurfDEM
        LiDARimagerFig = FigHandle;
        parameters     = get(LiDARimagerFig,'UserData'); 
        Easting        = parameters.Easting;
        Northing       = parameters.Northing;
        if ((length(Northing)+length(Easting))==0)
            errordlg('DEM has not been loaded successfully. Cannot plot data before loaded.');
            return;  
        end
        %...........................
        HshdSwitch = get(parameters.HshdPlotBox,'value');
        ElevSwitch = get(parameters.ElevPlotBox,'value');
        AsptSwitch = get(parameters.AspectPlotBox,'value');
        SlopSwitch = get(parameters.SlopePlotBox,'value');
        ContSwitch = get(parameters.ContPlotBox,'value');
        DrapSwitch = get(parameters.DrapChkBox,'value');
        ContInterv = str2double(get(parameters.ContIntvBox,'string'));
        ViewAzi    = str2double(get(parameters.ViewAzimuthbox,'String'));
        ViewZen    = str2double(get(parameters.ViewZenithbox,'String'));
        maxElev    = max(max(parameters.Elevation));
        minElev    = min(min(parameters.Elevation));
        TranspA    = str2double(get(parameters.TranspAbox,'string'));
        TranspB    = str2double(get(parameters.TranspBbox,'string'));
        DrapeA     = get(parameters.DrapeAbox,'value');
        DrapeB     = get(parameters.DrapeBbox,'value');
        ColMapA    = get(parameters.ColMapAbox,'value');
        ColMapB    = get(parameters.ColMapBbox,'value');
        TheseCols  = [parameters.AllColorMaps(((ColMapA-1)*64+1):(ColMapA*64),:);parameters.AllColorMaps(((ColMapB-1)*64+1):(ColMapB*64),:)];
        %.............................................................. 

        if HshdSwitch == 1 % then I plot the hillshade
            figure(99);    
            clf; hold on;
            plot(Easting(1,1),Northing(1,1), 'b.');
            xlabel('Easting'); ylabel('Northing');
            axis equal; title('Surface hillshade plot');

            CurrentAzimuth = str2double(get(parameters.UsedAzimuthBox,'String'));
            CurrentZenith  = str2double(get(parameters.UsedZenithBox,'String'));
            CurrentZ_fact  = str2double(get(parameters.UsedZ_FactorBox,'String'));
            CurrentAzimuth = CurrentAzimuth-90; %convert to mathematic unit 
            CurrentAzimuth(CurrentAzimuth>=360) = CurrentAzimuth-360;
            CurrentAzimuth = CurrentAzimuth.*(pi/180); %  convert to radians
            %lighting altitude
            CurrentZenith  = (90-CurrentZenith) * (pi/180); % convert to zenith angle in radians
            [asp,grad]     = cart2pol(parameters.dElev_dy,parameters.dElev_dx); % convert to carthesian coordinates
            grad           = atan(CurrentZ_fact*grad); %steepest slope
            % convert asp
            asp(asp<pi)    = asp(asp<pi)+(pi/2);
            asp(asp<0)     = asp(asp<0)+(2*pi);
            Hillshds       =  255.0*( (cos(CurrentZenith).*cos(grad) ) + ( sin(CurrentZenith).*sin(grad).*cos(CurrentAzimuth-asp)) ); % ESRIs algorithm
            Hillshds(Hillshds<0)=0; % set hillshade values to min of 0.
            clear asp grad;
            parameters.Hillshadmap = Hillshds; %required for back-slip later on
            clear Hillshds;
            set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');

            imagesc(Easting,Northing,parameters.Hillshadmap);
            colormap('gray');

            value1 = get(parameters.GridSwitchbox,'value');
            if value1 == 1
                a = gca;
                set(a,'Layer','top','XGrid','on','YGrid','on','GridLineStyle','--','LineWidth',1);
            end
            parameters.HshdSwitch = 1;

           if  ContSwitch == 1  
                BlahMatrix = parameters.Elevation -minElev;
                rescale    = (maxElev-minElev)/255;
                BlahMatrix  = BlahMatrix.*rescale;
                Contnumber = round((maxElev-minElev)/ContInterv);      
                disp('maximum elevation of initialized data set:');disp(maxElev);
                disp('minimum elevation of initialized data set:');disp(minElev);
                contour(Easting,Northing,BlahMatrix,Contnumber,'LineColor','black','linewidth',0.5);
                clear BlahMatrix;
           end  
        end
        %///////////////////////////    
        %here comes plot of other components
        if AsptSwitch == 1 % then I plot the aspect
            figure(103);    
            clf; hold on;
            plot(Easting(1,1),Northing(1,1), 'b.');
            xlabel('Easting'); ylabel('Northing');title('Surface aspect plot');

            axis equal;
            imagesc(Easting,Northing,parameters.Aspectmap); 
            colormap('hsv');
            value1 = get(parameters.GridSwitchbox,'value');
            if value1 == 1
                a = gca;
                set(a,'Layer','top','XGrid','on','YGrid','on','GridLineStyle','--','LineWidth',1);
            end
            if  ContSwitch == 1  
                BlahMatrix = parameters.Elevation -minElev;
                rescale    = (maxElev-minElev)/255;
                BlahMatrix  = BlahMatrix.*rescale;
                Contnumber = round((maxElev-minElev)/ContInterv);      
                disp('maximum elevation of initialized data set:');disp(maxElev);
                disp('minimum elevation of initialized data set:');disp(minElev);
                contour(Easting,Northing,BlahMatrix,Contnumber,'LineColor','black','linewidth',0.5);
                clear BlahMatrix;
           end  
        end
        if SlopSwitch == 1 % then I plot the aspect
            figure(109);    
            clf; hold on;
            plot(Easting(1,1),Northing(1,1), 'b.');
            xlabel('Easting'); ylabel('Northing');title('Surface slope plot');

            axis equal;
            imagesc(Easting,Northing,parameters.Slopemap); 
            colormap('jet');
            %blah = flipud(colormap('gray'));
            %colormap(blah);
            value1 = get(parameters.GridSwitchbox,'value');
            if value1 == 1
                a = gca;
                set(a,'Layer','top','XGrid','on','YGrid','on','GridLineStyle','--','LineWidth',1);
            end
            if  ContSwitch == 1  
                BlahMatrix = parameters.Elevation -minElev;
                rescale    = (maxElev-minElev)/255;
                BlahMatrix  = BlahMatrix.*rescale;
                Contnumber = round((maxElev-minElev)/ContInterv);      
                disp('maximum elevation of initialized data set:');disp(maxElev);
                disp('minimum elevation of initialized data set:');disp(minElev);
                contour(Easting,Northing,BlahMatrix,Contnumber,'LineColor','black','linewidth',0.5);
                clear BlahMatrix;
           end  
        end
        if ElevSwitch == 1
            figure(107);    
            clf; hold on;
            plot(Easting(1,1),Northing(1,1), 'b.');
            xlabel('Easting'); ylabel('Northing');title('Surface elevation plot');

            axis equal;
            imagesc(Easting,Northing,parameters.Elevation);  
            colormap('jet');
            value1 = get(parameters.GridSwitchbox,'value');
            if value1 == 1
                a = gca;
                set(a,'Layer','top','XGrid','on','YGrid','on','GridLineStyle','--','LineWidth',1);
            end
            if  ContSwitch == 1  
                Contnumber = round((maxElev-minElev)/ContInterv);      
                disp('maximum elevation of initialized data set:');disp(maxElev);
                disp('minimum elevation of initialized data set:');disp(minElev);
                contour(Easting,Northing,parameters.Elevation,Contnumber,'LineColor','black','linewidth',0.5);
           end  
        end
        if (HshdSwitch == 0) &&(ElevSwitch == 0)&&(AsptSwitch == 0) &&(SlopSwitch == 0)&&(ContSwitch == 1)
            figure (109);
            clf; hold on;axis equal;
            plot(Easting(1,1),Northing(1,1), 'b.');
            xlabel('Easting'); ylabel('Northing');title('Contour plot of Elevation');
             Contnumber = round((maxElev-minElev)/ContInterv);      
                disp('maximum elevation of initialized data set:');disp(maxElev);
                disp('minimum elevation of initialized data set:');disp(minElev);
                contour(Easting,Northing,parameters.Elevation,Contnumber,'LineColor','black','linewidth',0.5);
        end
        if DrapSwitch == 1
            figure(123); clf; hold on; axis equal
            plot(Easting(1,1),Northing(1,1), 'b.');
            xlabel('Easting'); ylabel('Northing');
            if     (DrapeA == 1) && (DrapeB == 1), title('Hillshade plot drapped over hillshade plot');
            elseif (DrapeA == 1) && (DrapeB == 2), title('Hillshade plot drapped over elevation plot');
            elseif (DrapeA == 1) && (DrapeB == 3), title('Hillshade plot drapped over slope plot');
            elseif (DrapeA == 1) && (DrapeB == 4), title('Hillshade plot drapped over aspect plot');
            elseif (DrapeA == 2) && (DrapeB == 1), title('Elevation plot drapped over hillshade plot');    
            elseif (DrapeA == 2) && (DrapeB == 2), title('Elevation plot drapped over elevation plot');
            elseif (DrapeA == 2) && (DrapeB == 3), title('Elevation plot drapped over slope plot');
            elseif (DrapeA == 2) && (DrapeB == 4), title('Elevation plot drapped over aspect plot');
            elseif (DrapeA == 3) && (DrapeB == 1), title('Slope plot drapped over hillshade plot');    
            elseif (DrapeA == 3) && (DrapeB == 2), title('Slope plot drapped over elevation plot');
            elseif (DrapeA == 3) && (DrapeB == 3), title('Slope plot drapped over slope plot');
            elseif (DrapeA == 3) && (DrapeB == 4), title('Slope plot drapped over aspect plot');
            elseif (DrapeA == 4) && (DrapeB == 1), title('Aspect plot drapped over hillshade plot');    
            elseif (DrapeA == 4) && (DrapeB == 2), title('Aspect plot drapped over elevation plot');
            elseif (DrapeA == 4) && (DrapeB == 3), title('Aspect plot drapped over slope plot');
            elseif (DrapeA == 4) && (DrapeB == 4), title('Aspect plot drapped over aspect plot');
            end
            colormap(TheseCols);
            %I should do the colormapping before! also von min-max zu;
            %also das problem ist das aendern der colormaps
            %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            if     (DrapeB == 1), Map = parameters.Hillshadmap;
            elseif (DrapeB == 2), Map = parameters.Elevation;   
            elseif (DrapeB == 3), Map = parameters.Slopemap;  
            elseif (DrapeB == 4), Map = parameters.Aspectmap;  
            end 
            maxVal   = max(Map(:));    minVal = min(Map(:));
            ScaledColB = round(((Map-minVal)./(maxVal-minVal)).*63)+65;
            ScaledColB(ScaledColB(:,:)<65)=65;    ScaledColB(ScaledColB(:,:)>128)=128;
            imagesc(Easting,Northing,ScaledColB,'AlphaData',TranspB);

            if     (DrapeA == 1), Map = parameters.Hillshadmap;
            elseif (DrapeA == 2), Map = parameters.Elevation;   
            elseif (DrapeA == 3), Map = parameters.Slopemap;  
            elseif (DrapeA == 4), Map = parameters.Aspectmap;  
            end 
            maxVal   = max(Map(:));    minVal = min(Map(:));
            ScaledColA = round(((Map-minVal)./(maxVal-minVal)).*63)+1;
            ScaledColA(ScaledColA(:,:)<1)=1;    ScaledColA(ScaledColA(:,:)>54)=64;
            imagesc(Easting,Northing,ScaledColA,'AlphaData',TranspA);
            caxis([min(ScaledColA(:)) max(ScaledColB(:))]);
            %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            value1 = get(parameters.GridSwitchbox,'value');
            if value1 == 1
                a = gca;
                set(a,'Layer','top','XGrid','on','YGrid','on','GridLineStyle','--','LineWidth',1);
            end
            if  ContSwitch == 1  
                BlahMatrix = parameters.Elevation -minElev;
                rescale    = (maxElev-minElev)/255;
                BlahMatrix  = BlahMatrix.*rescale;
                Contnumber = round((maxElev-minElev)/ContInterv);      
                disp('maximum elevation of initialized data set:');disp(maxElev);
                disp('minimum elevation of initialized data set:');disp(minElev);
                contour(Easting,Northing,BlahMatrix,Contnumber,'LineColor','black','linewidth',0.5);
                clear BlahMatrix;
            end  
        end 
        
        if ((ViewZen ~= 90)||(ViewAzi ~=0)&&(ViewAzi ~=360)),       ChangeViewAngle;        end
        
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');
%--------------------------------------------------------------------------
    function SaveF
        LiDARimagerFig    = FigHandle;
        parameters = get(LiDARimagerFig,'UserData'); 
        
        SaveType   = get(parameters.savetypebox,'value');
        SaveName   = get(parameters.savenamebox,'string');
        HshdSwitch = get(parameters.HshdPlotBox,'value');
        ElevSwitch = get(parameters.ElevPlotBox,'value');
        AsptSwitch = get(parameters.AspectPlotBox,'value');
        SlopSwitch = get(parameters.SlopePlotBox,'value');
        DrapSwitch = get(parameters.DrapChkBox,'value');
        UTMZone    = str2double(get(parameters.UTMzonebox,'string'));
        UTMHemi    = get(parameters.hemisphtypebox,'value');
        %..............................................................      
        if HshdSwitch == 1
            figure(201);
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                close(gcf);
            else
                 if SaveType == 1
                    filename = strcat(SaveName,'_Hillshade_Oblique.jpg');
                    print ('-f201', '-r300', '-djpeg', filename); 
                 end
            end
            figure(99)
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                close(gcf);
                disp('Hillshade plot not saved -only open hillshade plots can be saved');
            else
                if SaveType == 1
                    filename = strcat(SaveName,'_Hillshade.jpg');
                    print ('-f99', '-r300', '-djpeg', filename); 
                elseif SaveType == 2
                    Eastings  = xlim;%zeros(1,2);
                    Northings = ylim;%zeros(1,2);
                    if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
                    if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end
                    if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
                    if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
                    ncols          = length(parameters.Easting);
                    nrows          = length(parameters.Northing);
                    
                     relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                     relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                     relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                     relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                     filename2      = strcat(SaveName,'_Hillshade.png');
                     
                     Eastings       = [parameters.Easting(relativeEast1), parameters.Easting(relativeEast2)];
                     Northings      = [parameters.Northing(relativeNorth1), parameters.Northing(relativeNorth2)];
                     [South,West]   = GetCoordinates(Eastings(1,1),Northings(1,1),UTMZone,UTMHemi);
                     [North,East]   = GetCoordinates(Eastings(1,2),Northings(1,2),UTMZone,UTMHemi);   
                    
                    cutImage = flipud((parameters.Hillshadmap(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2))./255);
                    imwrite(cutImage,filename2,'png');
                    %------------------------------------------------------
                    MakeKMZFile(East,West,North,South,filename2);
                elseif SaveType == 3
                       QuickDrawstep = get(parameters.Quickdrawbox,'value');
                       Eastings  = zeros(1,2);
                       Northings = zeros(1,2);
                       Elevation = parameters.Elevation;
                       if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
                       if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end

                       if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
                       if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
                       %have to determine %1)ncols,2)nrows,3)xllcorner,4)yllcorner,5)cellsize,6)NODATA_value data%4.3f;
                       factor         = parameters.cellsize/parameters.Realcellsize;
                       ncols          = length(parameters.Easting)*factor;
                       nrows          = length(parameters.Northing)*factor;
                           
                       xllcorner      = Eastings(1,1);
                       yllcorner      = Northings(1,1);
                       NO_DATA_value  = -9999;

                       relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                       relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                       relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                       relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                       ncols2         = relativeEast2  -relativeEast1  +1;
                       nrows2         = relativeNorth2 -relativeNorth1 +1;
                       if (ncols2~=ncols)&&(nrows2~=nrows) %when I actually zoomed...
                           if (QuickDrawstep > 1)
                              relativeN2 =  floor(((min(Northings)- max(parameters.Northing))/(min(parameters.Northing) -max(parameters.Northing)))*nrows);
                              relativeN1 = 1+ceil(((max(Northings)- max(parameters.Northing))/(min(parameters.Northing) -max(parameters.Northing)))*nrows);
                              Elevation     = zeros(nrows2,ncols2) +NaN;
                              poscounter    = 0;
                              extension     = '.asc';
                              filename      = get(parameters.loadnamebox,'String');
                              filename1     = strcat(filename,extension); 
                              fid2           = fopen(filename1,'r');
                              if (fid2 == -1)
                                  errordlg('The entered filename has not been found. Make sure that the file is in the same folder as the GUI. Change filename and/or make sure that the file has the correct ending.');
                                  return;
                              end
                              for run = 1:6,      throwawayLine = fgetl(fid2);       end %#ok<NASGU>
                              for run1 = 1:nrows
                                  if (run1 <relativeN1)||(run1 >relativeN2)
                                    throwawayLine            = fgetl(fid2);
                                  else
                                    poscounter               = poscounter +1;
                                    ElevLine                 = sscanf(fgetl(fid2),'%f'); 
                                    Elevation(poscounter,:)  = ElevLine(relativeEast1:relativeEast2,1);
                                  end
                              end  
                              fclose(fid2);
                           end
                           filename4  = strcat(SaveName,'.asc');
                           fid        = fopen(filename4,'w');
                           if (fid == -1)
                                errordlg('The entered file name was not successfully opened for writing');
                                return;
                           end
                           fprintf(fid,'ncols %4.0f \n',ncols2);
                           fprintf(fid,'nrows %4.0f \n',nrows2);
                           fprintf(fid,'xllcorner %8.2f \n',xllcorner);
                           fprintf(fid,'yllcorner %8.2f \n',yllcorner);
                           fprintf(fid,'cellsize %2.6f \n',parameters.Realcellsize);
                           fprintf(fid,'NO_DATA_value -9999 \n');
                           %-----------------------------------------------
                           if (QuickDrawstep == 1)
                           
                               for run2 = relativeNorth2:-1:relativeNorth1
                                    for run1 = relativeEast1:relativeEast2
                                        if isnan(Elevation(run2,run1))
                                            fprintf(fid,'-9999 ');
                                        else
                                            fprintf(fid,'%4.3f ',Elevation(run2,run1));
                                        end
                                    end
                                    fprintf(fid,'\n');
                               end
                           %-----------------------------------------------
                           elseif (QuickDrawstep > 1)
                               for run2 = 1:nrows2
                                    for run1 = 1:ncols2
                                        if isnan(Elevation(run2,run1))
                                            fprintf(fid,'-9999 ');
                                        else
                                            fprintf(fid,'%4.3f ',Elevation(run2,run1));
                                        end
                                    end
                                    fprintf(fid,'\n');
                               end
                           end
                           fclose(fid);
                           %-----------------------------------------------
                       end
                end
            end
        end
        %///////////////////////////    
        %here comes plot of other components
        if AsptSwitch == 1 % then I plot the aspect
            figure(203);
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                close(gcf);
            else
                 if SaveType == 1
                    filename = strcat(SaveName,'_Aspect_Oblique.jpg');
                    print ('-f203', '-r300', '-djpeg', filename); 
                 end
            end
            figure(103)
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                disp('Surface normal trend plot not saved -only open plots can be saved');
                close(gcf);
            else
                if SaveType == 1
                    filename = strcat(SaveName,'_Aspect.jpg');
                    print ('-f103', '-r300', '-djpeg', filename); 
                elseif SaveType == 2
                   
                    Eastings  = xlim;%zeros(1,2);
                    Northings = ylim;%zeros(1,2);
                    if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
                    if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end
                    if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
                    if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
                    ncols          = length(parameters.Easting);
                    nrows          = length(parameters.Northing);
                    
                     relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                     relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                     relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                     relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                     filename2      = strcat(SaveName,'_Trend.png');
                     
                     Eastings       = [parameters.Easting(relativeEast1), parameters.Easting(relativeEast2)];
                     Northings      = [parameters.Northing(relativeNorth1), parameters.Northing(relativeNorth2)];
                     [South,West]   = GetCoordinates(Eastings(1,1),Northings(1,1),UTMZone,UTMHemi);
                     [North,East]   = GetCoordinates(Eastings(1,2),Northings(1,2),UTMZone,UTMHemi);   
                    
                    cutImage = flipud((parameters.Aspectmap(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2)));
                    cutImage = cutImage -min(min(cutImage));
                   
                    cutImage = round((cutImage./max(max(cutImage)).*63));
                    [nor,eas]= size(cutImage);
                    cutImage2= cat(3,NaN(nor,eas),NaN(nor,eas),NaN(nor,eas));
                    map      = colormap;
                    for run1 = 1:nor
                        for run2 = 1:eas
                            currVal = cutImage(run1,run2)+1;
                            if ~isnan(currVal)
                            R = map(currVal,1); G = map(currVal,2); B = map(currVal,3);
                            cutImage2(run1,run2,1) = R;
                            cutImage2(run1,run2,2) = G;
                            cutImage2(run1,run2,3) = B;
                            end
                        end
                    end
                    imwrite(cutImage2,filename2,'png');
                    %------------------------------------------------------
                    MakeKMZFile(East,West,North,South,filename2);
                elseif SaveType == 3
                   if ElevSwitch ~= 1
                       errordlg('Cannot save zoom of elevation data. -First plot elevation and zoom to desired area');
                       return;
                   end
                end
            end
        end
        if SlopSwitch == 1 % then I plot the aspect
            figure(204); blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                close(gcf);
            else
                 if SaveType == 1
                    filename = strcat(SaveName,'_Slope_Oblique.jpg');
                    print ('-f204', '-r300', '-djpeg', filename); 
                 end
            end
            figure(109);
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                disp('Surface normal plunge plot not saved -only open plots can be saved');
                close(gcf);
            else
                if SaveType == 1
                    filename = strcat(SaveName,'_Slope.jpg');
                    print ('-f109', '-r300', '-djpeg', filename); 
                elseif SaveType == 2
                    Eastings  = xlim;%zeros(1,2);
                    Northings = ylim;%zeros(1,2);
                    if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
                    if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end
                    if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
                    if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
                    ncols          = length(parameters.Easting);
                    nrows          = length(parameters.Northing);
                    
                    relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                    relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                    relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                    relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                    filename2      = strcat(SaveName,'_Plunge.png');
                     
                    Eastings       = [parameters.Easting(relativeEast1), parameters.Easting(relativeEast2)];
                    Northings      = [parameters.Northing(relativeNorth1), parameters.Northing(relativeNorth2)];
                    [South,West]   = GetCoordinates(Eastings(1,1),Northings(1,1),UTMZone,UTMHemi);
                    [North,East]   = GetCoordinates(Eastings(1,2),Northings(1,2),UTMZone,UTMHemi);   
                    
                    cutImage = flipud((parameters.Slopemap(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2)));
                    cutImage = cutImage -min(min(cutImage));
                   
                    cutImage = round((cutImage./max(max(cutImage)).*63));
                    [nor,eas]= size(cutImage);
                    cutImage2= cat(3,NaN(nor,eas),NaN(nor,eas),NaN(nor,eas));
                    map      = colormap;
                    for run1 = 1:nor
                        for run2 = 1:eas
                            currVal = cutImage(run1,run2)+1;
                            if ~isnan(currVal)
                            R = map(currVal,1); G = map(currVal,2); B = map(currVal,3);
                            cutImage2(run1,run2,1) = R;
                            cutImage2(run1,run2,2) = G;
                            cutImage2(run1,run2,3) = B;
                            end
                        end
                    end
                    imwrite(cutImage2,filename2,'png');
                    %------------------------------------------------------
                    MakeKMZFile(East,West,North,South,filename2);
                elseif SaveType == 3
                   if ElevSwitch ~= 1
                       errordlg('Cannot save zoom of elevation data. -First plot elevation and zoom to desired area');
                       return;
                   end
                end
            end
        end
        if ElevSwitch == 1
            figure(202);
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                close(gcf);
            else
                 if SaveType == 1
                    filename = strcat(SaveName,'_Elevation_Oblique.jpg');
                    print ('-f202', '-r300', '-djpeg', filename); 
                 end
            end
            figure(107);
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1)
                disp('Elevation plot not saved -only open plots can be saved');
                close(gcf);
            else
                if SaveType == 1
                    filename = strcat(SaveName,'_Elevation.jpg');
                    print ('-f107', '-r300', '-djpeg', filename); 
                elseif SaveType == 2
                    Eastings  = xlim;%zeros(1,2);
                    Northings = ylim;%zeros(1,2);
                    if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
                    if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end
                    if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
                    if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
                    ncols          = length(parameters.Easting);
                    nrows          = length(parameters.Northing);
                    relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                    relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                    relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                    relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                    filename2      = strcat(SaveName,'_Elevation.png');
                    Eastings       = [parameters.Easting(relativeEast1), parameters.Easting(relativeEast2)];
                    Northings      = [parameters.Northing(relativeNorth1), parameters.Northing(relativeNorth2)];
                    [South,West]   = GetCoordinates(Eastings(1,1),Northings(1,1),UTMZone,UTMHemi);
                    [North,East]   = GetCoordinates(Eastings(1,2),Northings(1,2),UTMZone,UTMHemi);   
                    
                    cutImage = flipud((parameters.Elevation(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2)));
                    cutImage = cutImage -min(min(cutImage));
                   
                    cutImage = round((cutImage./max(max(cutImage)).*63));
                    [nor,eas]= size(cutImage);
                    cutImage2= cat(3,NaN(nor,eas),NaN(nor,eas),NaN(nor,eas));
                    map      = colormap;
                    for run1 = 1:nor
                        for run2 = 1:eas
                            currVal = cutImage(run1,run2)+1;
                            if ~isnan(currVal)
                            R = map(currVal,1); G = map(currVal,2); B = map(currVal,3);
                            cutImage2(run1,run2,1) = R;
                            cutImage2(run1,run2,2) = G;
                            cutImage2(run1,run2,3) = B;
                            end
                        end
                    end
                    imwrite(cutImage2,filename2,'png');
                    %------------------------------------------------------
                    MakeKMZFile(East,West,North,South,filename2);
                elseif SaveType == 3
                   if ElevSwitch ~= 1
                       errordlg('Cannot save zoom of elevation data. -First plot elevation and zoom to desired area');
                       return;
                   end
                end
            end
        end
        %------------------------------------------------------------------
        if DrapSwitch == 1
            figure(223);
            blatest = xlim;
            if (blatest(1,1) == 0)&&(blatest(1,2)==1), close(gcf);
            else
                 if (SaveType == 1), filename = strcat(SaveName,'_Drape_Oblique.jpg');  print ('-f223', '-r300', '-djpeg', filename); end
            end
            figure(123);         blatest = xlim;
            if ((blatest(1,1) == 0)&&(blatest(1,2)==1)),    disp('Surface normal trend plot not saved -only open plots can be saved');                close(gcf);
            else
                if     (SaveType == 1),     filename = strcat(SaveName,'_Drape.jpg'); print ('-f123', '-r300', '-djpeg', filename); 
                elseif (SaveType == 2),    
                    Eastings  = xlim;%zeros(1,2);
                    Northings = ylim;%zeros(1,2);
                    if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
                    if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end
                    if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
                    if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
                    ncols          = length(parameters.Easting);
                    nrows          = length(parameters.Northing);
                    relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                    relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
                    relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                    relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
                    Eastings       = [parameters.Easting(relativeEast1), parameters.Easting(relativeEast2)];
                    Northings      = [parameters.Northing(relativeNorth1), parameters.Northing(relativeNorth2)];
                    [South,West]   = GetCoordinates(Eastings(1,1),Northings(1,1),UTMZone,UTMHemi);
                    [North,East]   = GetCoordinates(Eastings(1,2),Northings(1,2),UTMZone,UTMHemi);   
                    
                    filename2      = strcat(SaveName,'_Drape.png');
                    cutImage  = getframe(gca); cutImage2 = cutImage.cdata;
                    imwrite(cutImage2,filename2,'png');
                    MakeKMZFile(East,West,North,South,filename2);
                    
                elseif (SaveType == 3),     if (ElevSwitch ~= 1),      errordlg('Cannot save zoom of elevation data. -First plot elevation and zoom to desired area');   return;    end
                end
            end
        end
        set(LiDARimagerFig,'UserData',parameters,'HandleVisibility','callback');
        msgbox(' Data saved to folder');
%------------------------------------------------------------------
    function [latitude,longitude] = GetCoordinates(Easting,Northing,Zone,Hemi)
   
   sa       = 6378137.000000 ; sb = 6356752.314245;
  
   e        = sqrt(1-(sb^2/sa^2));
   e2strich = e^2/(1-e^2);
   k0       = 0.9996;
   long0    = Zone*6 -183;
   
   X        = 500000 -Easting;
   
   if Hemi == 2
       Y = 10000000 -Northing;
   else
       Y = Northing;
   end
   
   M        = Y/k0;
   mu       = M/(sa*(1-e^2/4 -3*e^4/64 -5*e^6/256));
   e1       = (1-sqrt(1-e^2))/(1+sqrt(1-e^2));
   
   J1       = (3*e1/2 -27*e1^3/32);
   J2       = (21*e1^2/16 -55*e1^4/32);
   J3       = (151*e1^3/96);
   J4       = (1097*e1^4/512);
   fp       = mu +J1*sin(2*mu) +J2*sin(4*mu) +J3*sin(6*mu) +J4*sin(8*mu);
   
   C1       = e2strich*cos(fp)^2;
   T1       = tan(fp)^2;
   R1       = (sa*(1-e^2))/(1-e^2*sin(fp)^2)^1.5;
   N1       = sa/sqrt(1-e^2*sin(fp)^2);
   D        = X/(N1*k0);
   
   Q1       = N1*tan(fp)/R1;
   Q2       = D^2/2;
   Q3       = (5 +3*T1 +10*C1 -4*C1^2 -9*e2strich)*D^4/24;
   Q4       = (61 +90*T1 +298*C1 +45*T1^2 -3*C1^2 -252*e2strich)*D^6/720;
   
   Q5       = D;
   Q6       = (1 +2*T1 +C1)*D^3/6;
   Q7       = (5-2*C1 +28*T1 -3*C1^2 +8*e2strich +24*T1^2)*D^5/120;
      
   latitude = (fp -Q1*(Q2 -Q3 +Q4))*180/pi;
   longitude= long0 -((Q5 -Q6 +Q7)/cos(fp))*180/pi;
    %from: 
    function [Easting,Northing] = GetGeoCoordinates(Longitude, Latitude)   
        
        lat    = Latitude*pi/180;
        sa     = 6378137.000000 ; sb = 6356752.314245;
        n      = (sa-sb)/(sa+sb);
        k0     = 0.9996;
        long0  = (round(((Longitude+177)/354)*60) +1)*6 -183;
        
        e      = sqrt(1-sb^2/sa^2);
        e2st   = e^2/(1-e^2);
        roh    = sa*(1-e^2)/(1-e^2*sin(Latitude)^2)^1.5;
        nu     = sa/sqrt(1-e^2*sin(Latitude)^2);
        p      = Longitude*pi/180 - long0*pi/180;
        
        S      = sa*((1-e^2/4 - 3*e^4/64 - 5*e^6/256)*lat -(3*e^2/8 + 3*e^4/32 + 45*e^6/1024)*sin(2*lat)+... 
                   + (15*e^4/256 + 45*e^6/1024)*sin(4*lat)-(35*e^6/3072)*sin(6*lat)); 
        
        K1     = S*k0;
        K2     = k0*nu*sin(2*lat)/4;
        K3     =(k0*nu*sin(lat)*cos(lat)^3/24)*(5-tan(lat)^2 + 9*e2st*cos(lat)^2 + 4*e2st^2*cos(lat)^4);
        K4     = k0*nu*cos(lat);
        K5     =(k0*nu*cos(lat)^3/6)*(1 - tan(lat)^2 + e2st*cos(lat)^2);
       
               
        Northing = K1 +K2*p^2 +K3*p^4;
        Easting  = (K4*p +K5*p^3) +500000;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
    function MakeKMZFile(East,West,North,South,filename2)
        LiDARimagerFig    = FigHandle;
        parameters = get(LiDARimagerFig,'UserData'); 
        SaveName   = get(parameters.savenamebox,'string');
        
        fid  = fopen('doc.kml','w');
        if (fid == -1)
            errordlg('The entered filename 1 has not been found. Change filename.');
            return;
        end
        
        [SaveName2,rest] = strtok(filename2,'.');
        
        fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?> \n');
        fprintf(fid, '<kml xmlns="http://earth.google.com/kml/2.2"> \n');
        fprintf(fid, '<Document> \n');
        fprintf(fid, '<name>%s</name> \n',SaveName2);
        fprintf(fid, '<GroundOverlay> \n');
        fprintf(fid, '<drawOrder>1000</drawOrder> \n');
        fprintf(fid, '<Icon> \n');
        fprintf(fid, '<href>%s</href> \n',filename2);
        fprintf(fid, '</Icon> \n');
        fprintf(fid, '<LatLonBox> \n');
        fprintf(fid, '<north>%3.7f</north> \n',North);
        fprintf(fid, '<south>%3.7f</south> \n',South);
        fprintf(fid, '<east>%3.7f</east> \n',East);
        fprintf(fid, '<west>%3.7f</west> \n',West);
        fprintf(fid, '</LatLonBox> \n');
        fprintf(fid, '</GroundOverlay> \n');
        fprintf(fid, '</Document> \n');
        fprintf(fid, '</kml> \n');
        
        fclose(fid);
        
        zip(SaveName2,{filename2,'doc.kml'});
        %now I have to make a batchfile to rename the file and to delete
        %the temp data; then I can do the same thing for the other plots
        %should be done in about 1hr
        fid      = fopen('MakeKMZ.bat','w');
        fprintf(fid,'del %s.kmz \n',SaveName2);
        fprintf(fid,'rename %s.zip  %s.kmz \n',SaveName2, SaveName2);
        fprintf(fid,' del doc.kml \n');
        fprintf(fid,' del %s',filename2);
        fclose(fid);
        !MakeKMZ.bat 
        !del MakeKMZ.bat
%--------------------------------------------------------------------------
    function ChangeViewAngle      
        LiDARimagerFig = FigHandle;
        parameters     = get(LiDARimagerFig,'UserData'); 
        
        HshdSwitch  = get(parameters.HshdPlotBox,'value');
        ElevSwitch  = get(parameters.ElevPlotBox,'value');
        AsptSwitch  = get(parameters.AspectPlotBox,'value');
        SlopSwitch  = get(parameters.SlopePlotBox,'value');
        DrapSwitch  = get(parameters.DrapChkBox,'value');
        TranspA     = str2double(get(parameters.TranspAbox,'string'));
        TranspB     = str2double(get(parameters.TranspBbox,'string'));
        DrapeA      = get(parameters.DrapeAbox,'value');
        DrapeB      = get(parameters.DrapeBbox,'value');
        ColMapA     = get(parameters.ColMapAbox,'value');
        ColMapB     = get(parameters.ColMapBbox,'value');
        TheseCols   = [parameters.AllColorMaps(((ColMapA-1)*64+1):(ColMapA*64),:);parameters.AllColorMaps(((ColMapB-1)*64+1):(ColMapB*64),:)];

        %first get the extent of current hillshade zoom, check which
        %dataset is to be plotted (hillshade, elevation,...) crop each of
        %them to the current extent; first make sure the rot-matrix works
        
        figure(99);
        Eastings       = xlim;%zeros(1,2);
        Northings      = ylim;%zeros(1,2);
        if min(xlim)<min(parameters.Easting); Eastings(1,1) = min(parameters.Easting); else Eastings(1,1) = min(xlim); end
        if max(xlim)>max(parameters.Easting); Eastings(1,2) = max(parameters.Easting); else Eastings(1,2) = max(xlim); end
        if min(ylim)<min(parameters.Northing); Northings(1,1) = min(parameters.Northing); else Northings(1,1) = min(ylim); end
        if max(ylim)>max(parameters.Northing); Northings(1,2) = max(parameters.Northing); else Northings(1,2) = max(ylim); end
        ncols          = length(parameters.Easting);
        nrows          = length(parameters.Northing);
        relativeEast1  =1+ceil(((min(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
        relativeEast2  = floor(((max(Eastings) - min(parameters.Easting))/(max(parameters.Easting) -min(parameters.Easting)))*ncols);
        relativeNorth1 =1+ceil(((min(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
        relativeNorth2 = floor(((max(Northings)- min(parameters.Northing))/(max(parameters.Northing) -min(parameters.Northing)))*nrows);
         
        cutHshd        = parameters.Hillshadmap(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2);
        cutElev        = parameters.Elevation(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2);
        cutAspt        = parameters.Aspectmap(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2);
        cutSlop        = parameters.Slopemap(relativeNorth1:relativeNorth2,relativeEast1:relativeEast2);
        %then determine spatial extent -together with grid size I make new/local easting/northing coordinates
        [nExt,eExt]    = size(cutHshd);
        nDist          = (nExt-1)*parameters.cellsize;      Northing       = -nDist/2:parameters.cellsize:nDist/2;    
        eDist          = (eExt-1)*parameters.cellsize;      Easting        = -eDist/2:parameters.cellsize:eDist/2;
        maxmaxElev     = max(max(cutElev));
        minminElev     = min(min(cutElev));
       
        averagElev     = (maxmaxElev+minminElev)/2;

        cutElev        = cutElev-averagElev; 
        %then generate the rotation matrix
        ViewAzim          = str2double(get(parameters.ViewAzimuthbox,'string')).*pi/180 +pi;
        
        ViewZeni          = str2double(get(parameters.ViewZenithbox,'string')).*pi/180;
        ViewZfact         = str2double(get(parameters.ViewZfactbox,'string'));
        ViewQuick         = get(parameters.ViewQuickbox,'value');

        MinMinElev        = min(min(cutElev(:,:)));
        cutElev           = cutElev - MinMinElev;
        RotatedPointsList = zeros(nExt*eExt,7);
        ptcount           = 1;
% rotate corners, and the close-by points  
        for runN = 1:nExt
            for runE = 1:eExt
                EastValOld = Easting(1,runE);
                NorthValOld= Northing(1,runN);
                ElevValOld = cutElev(runN,runE)*ViewZfact +MinMinElev;
                
                EastVNew1  = cos(ViewAzim)*EastValOld -sin(ViewAzim)*NorthValOld;
                NorthVNew1 = sin(ViewAzim)*EastValOld +cos(ViewAzim)*NorthValOld;               
                NorthVNew2 = sin(ViewZeni)*NorthVNew1 +cos(ViewZeni)*ElevValOld;
                ElevVNew1  = cos(ViewZeni)*NorthVNew1 -sin(ViewZeni)*ElevValOld;
                % new values are EastVNew1; NorthVNew2; ElevVNew1
                RotatedPointsList(ptcount,:) = [EastVNew1,NorthVNew2,ElevVNew1,cutHshd(runN,runE),cutElev(runN,runE),cutAspt(runN,runE),cutSlop(runN,runE)];
                ptcount  = ptcount +1;
            end
        end
        %then collect the proper ones
        FindMaxEast    = max(RotatedPointsList(:,1));
        FindMinEast    = min(RotatedPointsList(:,1));
        FindMaxNorth   = max(RotatedPointsList(:,2));       
        FindMinNorth   = min(RotatedPointsList(:,2)); 
        GridCellsEast  = (FindMaxEast-FindMinEast)/(eExt-1);        GridCellsNrth  = (FindMaxNorth-FindMinNorth)/(nExt-1);
        NewEasting     = FindMinEast:GridCellsEast:FindMaxEast;     NewNorthing    = FindMinNorth:GridCellsNrth:FindMaxNorth;
        NewMat         = zeros(nExt,eExt);
        NewMatrix      = cat(3,NewMat-(9E+99),NewMat+NaN,NewMat+NaN,NewMat+NaN,NewMat+NaN);
        
        for runPt = 1: (ptcount-1)
           CurrEast   = RotatedPointsList(runPt,1);
           CurrNorth  = RotatedPointsList(runPt,2);
           CurrElev   = RotatedPointsList(runPt,3);
           
           relEast    =1+round((CurrEast-FindMinEast)/(FindMaxEast -FindMinEast)*eExt);
           relNorth   =1+round((CurrNorth-FindMinNorth)/(FindMaxNorth -FindMinNorth)*nExt);
           if (relEast  < 0); relEast = 1; end;   if (relEast > eExt); relEast = eExt; end
           if (relNorth < 0); relNorth= 1; end;   if (relNorth> nExt); relNorth= nExt; end
           if (~isnan(relNorth))&&(~isnan(relEast))
               if CurrElev > NewMatrix(relNorth,relEast,1)
                   NewMatrix(relNorth,relEast,1) = CurrElev;                 %this is the projected elevation% 
                   NewMatrix(relNorth,relEast,2) = RotatedPointsList(runPt,5); %this is the actual elevation% 
                   NewMatrix(relNorth,relEast,3) = RotatedPointsList(runPt,4); %this is the hillshade value% 
                   NewMatrix(relNorth,relEast,4) = RotatedPointsList(runPt,6); %this is the aspect value% 
                   NewMatrix(relNorth,relEast,5) = RotatedPointsList(runPt,7); %this is the slope value% 
               end
           end
        end
        if ViewQuick == 1
            NewMatrix2 = NewMatrix; 
             for runN = 7:(nExt-6)
                 for runE = 7:(eExt-7)
                     if isnan(NewMatrix(runN,runE,2))
                         blah2 = nanmeanOZ(nanmeanOZ(NewMatrix((runN-6):(runN+6),(runE-6):(runE+6),2)));
                         blah3 = nanmeanOZ(nanmeanOZ(NewMatrix((runN-6):(runN+6),(runE-6):(runE+6),3)));
                         blah4 = nanmeanOZ(nanmeanOZ(NewMatrix((runN-6):(runN+6),(runE-6):(runE+6),4)));
                         blah5 = nanmeanOZ(nanmeanOZ(NewMatrix((runN-6):(runN+6),(runE-6):(runE+6),5)));
                         if ~isnan(blah2)
                             NewMatrix2(runN,runE,2) = blah2;
                             NewMatrix2(runN,runE,3) = blah3;
                             NewMatrix2(runN,runE,4) = blah4;
                             NewMatrix2(runN,runE,5) = blah5;
                         end
                     end
                 end
             end
             NewMatrix = NewMatrix2;
             clear NewMatrix2;
        end
        %---------------------------------------
        if HshdSwitch == 1
            figure(201);    
            clf; hold on;
            plot(NewEasting(1,1),NewNorthing(1,1), 'b.');
            title('Oblique surface hillshade plot');
            axis equal;
            imagesc(NewEasting,NewNorthing,NewMatrix(:,:,3));   
            colormap('gray');
            
        end
        if ElevSwitch == 1
            figure(202);    
            clf; hold on;
            plot(NewEasting(1,1),NewNorthing(1,1), 'b.');
            title('Oblique surface elevation plot');
            axis equal;
            imagesc(NewEasting,NewNorthing,NewMatrix(:,:,2)); 
            colormap('jet');
        end
        if AsptSwitch == 1
            figure(203);    
            clf; hold on;
            plot(NewEasting(1,1),NewNorthing(1,1), 'b.');
            title('Oblique surface aspect plot');
            axis equal;
            imagesc(NewEasting,NewNorthing,NewMatrix(:,:,4)); 
            colormap('hsv');
        end
        if SlopSwitch == 1
            figure(204);    
            clf; hold on;
            plot(NewEasting(1,1),NewNorthing(1,1), 'b.');
            title('Oblique surface slope plot');
            axis equal;
            imagesc(NewEasting,NewNorthing,NewMatrix(:,:,5)); 
            blah = flipud(colormap('gray'));
                colormap(blah);
        end
        if DrapSwitch == 1
            figure(223); clf; hold on;
            plot(NewEasting(1,1),NewNorthing(1,1), 'b.');
            if     (DrapeA == 1) && (DrapeB == 1), title('Hillshade plot drapped over hillshade plot');
            elseif (DrapeA == 1) && (DrapeB == 2), title('Hillshade plot drapped over elevation plot');
            elseif (DrapeA == 1) && (DrapeB == 3), title('Hillshade plot drapped over slope plot');
            elseif (DrapeA == 1) && (DrapeB == 4), title('Hillshade plot drapped over aspect plot');
            elseif (DrapeA == 2) && (DrapeB == 1), title('Elevation plot drapped over hillshade plot');    
            elseif (DrapeA == 2) && (DrapeB == 2), title('Elevation plot drapped over elevation plot');
            elseif (DrapeA == 2) && (DrapeB == 3), title('Elevation plot drapped over slope plot');
            elseif (DrapeA == 2) && (DrapeB == 4), title('Elevation plot drapped over aspect plot');
            elseif (DrapeA == 3) && (DrapeB == 1), title('Slope plot drapped over hillshade plot');    
            elseif (DrapeA == 3) && (DrapeB == 2), title('Slope plot drapped over elevation plot');
            elseif (DrapeA == 3) && (DrapeB == 3), title('Slope plot drapped over slope plot');
            elseif (DrapeA == 3) && (DrapeB == 4), title('Slope plot drapped over aspect plot');
            elseif (DrapeA == 4) && (DrapeB == 1), title('Aspect plot drapped over hillshade plot');    
            elseif (DrapeA == 4) && (DrapeB == 2), title('Aspect plot drapped over elevation plot');
            elseif (DrapeA == 4) && (DrapeB == 3), title('Aspect plot drapped over slope plot');
            elseif (DrapeA == 4) && (DrapeB == 4), title('Aspect plot drapped over aspect plot');
            end
            colormap(TheseCols);
            %I should do the colormapping before! also von min-max zu;
            %also das problem ist das aendern der colormaps
            %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            if     (DrapeB == 1), Map = NewMatrix(:,:,3);
            elseif (DrapeB == 2), Map = NewMatrix(:,:,2);   
            elseif (DrapeB == 3), Map = NewMatrix(:,:,5);  
            elseif (DrapeB == 4), Map = NewMatrix(:,:,4);  
            end 
            maxVal   = max(Map(:));    minVal = min(Map(:));
            ScaledColB = round(((Map-minVal)./(maxVal-minVal)).*63)+65;
            ScaledColB(ScaledColB(:,:)<65)=65;    ScaledColB(ScaledColB(:,:)>128)=128;
            imagesc(NewEasting,NewNorthing,ScaledColB,'AlphaData',TranspB);

            if     (DrapeA == 1), Map = NewMatrix(:,:,3);
            elseif (DrapeA == 2), Map = NewMatrix(:,:,2);   
            elseif (DrapeA == 3), Map = NewMatrix(:,:,5);  
            elseif (DrapeA == 4), Map = NewMatrix(:,:,4);  
            end 
            maxVal   = max(Map(:));    minVal = min(Map(:));
            ScaledColA = round(((Map-minVal)./(maxVal-minVal)).*63)+1;
            ScaledColA(ScaledColA(:,:)<1)=1;    ScaledColA(ScaledColA(:,:)>64)=64;
            imagesc(NewEasting,NewNorthing,ScaledColA,'AlphaData',TranspA);

            caxis([min(ScaledColA(:)) max(ScaledColB(:))]);
            axis equal;
        end
%---------------------------------------
%--------------------------------------------------------------------------
    function m = nanmeanOZ(x,dim)
    nans = isnan(x);
    x(nans) = 0;

    if nargin == 1 % let sum deal with figuring out which dimension to use
        % Count up non-NaNs.
        n = sum(~nans);
        n(n==0) = NaN; % prevent divideByZero warnings
        % Sum up non-NaNs, and divide by the number of non-NaNs.
        m = sum(x) ./ n;
    else
        % Count up non-NaNs.
        n = sum(~nans,dim);
        n(n==0) = NaN; % prevent divideByZero warnings
        % Sum up non-NaNs, and divide by the number of non-NaNs.
        m = sum(x,dim) ./ n;
    end
%--------------------------------------------------------------------------
    function y = nansumOZ(x,dim)
    x(isnan(x)) = 0;
    if nargin == 1 % let sum figure out which dimension to work along
        y = sum(x);
    else           % work along the explicitly given dimension
        y = sum(x,dim);
    end
%--------------------------------------------------------------------------      