
%  grid the area to x and y min,max
%  for DSM assign max of each aligning point 
%  for DTM assign min of each aligning point
%  for CHM subtract the two
%  
%  to fill the pixels that don't get any values look into neighbors in 3 pixels distance and take their min/max/avg bsed on 1/d their manhatan didtance

%  This approach is directly adopted from FUSION done by 
% Bob McGaughey                     USDA Forest Service  
% (206) 543-4713                    University of Washington
% FAX (206) 685-0790                Bloedel 386
% PO Box 352100
% Seattle, WA 98195-2100 

% located at  // ./scatter/XYZ2DTM/XYZ2DTM.cpp
