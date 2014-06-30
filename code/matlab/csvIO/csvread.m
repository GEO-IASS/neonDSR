function m = csvread( filename, delim )
%CSVREADH Read a comma separated value file. To get the header header = fileData(1,:);
% to convert strings to double do str2double(matrix)

% Validate input args
if nargin==0
    error(nargchk(1,1,nargin,'struct')); 
end

% Get Filename
if ~ischar(filename)
    error('csvreadh:FileNameMustBeString', ...
        'Filename must be a string.'); 
end

% Make sure file exists
if exist(filename,'file') ~= 2 
    error('csvreadh:FileNotFound',...
    'File not found.');
end

if nargin==1
    delim = ',';
end

% open input file
file = fopen( filename );
%line = fgetl( file );
%h = regexp( line, delim, 'split' );

m = [];
% this is not quick for sure, but works
while 1
    line = fgetl( file );
    if ~ischar(line), break, end
    %m = [m; str2double(regexp( line, ',', 'split' ))];
    m = [m; regexp( line, ',', 'split' )];
end

fclose(file);