%function [PublicHeaderBlock, VariableLengthRecords, DataPoints, Coords] = readLAS (LASinputfile, mode)
function [DataPoints, Coords] = readLAS (LASinputfile, mode)

% This product is Copyright (c) 2011 University of Florida.
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%   2. Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in the
%      documentation and/or other materials provided with the distribution.
%   3. Neither the name of the University nor the names of its contributors
%      may be used to endorse or promote products derived from this software
%      without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF FLORIDA AND
% CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED.  IN NO EVENT SHALL THE UNIVERSITY OR CONTRIBUTORS
% BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

numErrors = 0;


fid = fopen(LASinputfile, 'r');

PublicHeaderBlock.FileSignature = fread(fid, 4, 'uchar=>char')';
if strcmp(PublicHeaderBlock.FileSignature, 'LASF')
    fprintf( 'Passed validation check:  File Signature (%s)\n',  PublicHeaderBlock.FileSignature);
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  File Signature (%s)\nTotal Errors Found:  %i\n',  PublicHeaderBlock.FileSignature,numErrors);
end

PublicHeaderBlock.FileSourceID = fread(fid, 1, 'uint16=>uint16');
%Global Encoding bits can be read to determine settings based on bits
%positions 0,1,2,3 being set (bits 4-15 not used in this spec)
PublicHeaderBlock.GlobalEncoding = fread(fid, 1, 'uint16=>uint16');
if PublicHeaderBlock.GlobalEncoding == 0 || PublicHeaderBlock.GlobalEncoding == 1
    fprintf( 'Passed validation check:  Global Encoding\n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Global Encoding\nTotal Errors Found:  %i\n',  numErrors);
end

PublicHeaderBlock.ProjectID_GUIDdata1 = fread(fid, 1, 'uint32=>uint32');
PublicHeaderBlock.ProjectID_GUIDdata2 = fread(fid, 1, 'uint16=>uint16');
PublicHeaderBlock.ProjectID_GUIDdata3 = fread(fid, 1, 'uint16=>uint16');
PublicHeaderBlock.ProjectID_GUIDdata4 = fread(fid, 8, 'uchar=>char')';

PublicHeaderBlock.VersionMajor = fread(fid, 1, 'uchar=>uchar');
PublicHeaderBlock.VersionMinor = fread(fid, 1, 'uchar=>uchar');
PublicHeaderBlock.FormatSpecificationNumber = strcat(int2str(PublicHeaderBlock.VersionMajor),'.',int2str(PublicHeaderBlock.VersionMinor));

PublicHeaderBlock.SystemIdentifier = fread(fid, 32, 'uchar=>char')';
PublicHeaderBlock.GeneratingSoftware = fread(fid, 32, 'uchar=>char')';

PublicHeaderBlock.FileCreationDayOfYear = fread(fid, 1, 'uint16=>uint16');
PublicHeaderBlock.FileCreationYear = fread(fid, 1, 'uint16=>uint16');

PublicHeaderBlock.HeaderSize = fread(fid, 1, 'uint16=>uint16');
%check that this matches actual placement
PublicHeaderBlock.OffsetToPointData = fread(fid, 1, 'uint32=>uint32');

PublicHeaderBlock.NumberOfVariableLengthRecords = fread(fid, 1, 'uint32=>uint32');
PublicHeaderBlock.PointDataFormatID = fread(fid, 1, 'uchar=>uchar');
if PublicHeaderBlock.PointDataFormatID == 1
    fprintf( 'Passed validation check:  Point Data Format ID (%i)\n',  PublicHeaderBlock.PointDataFormatID);
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Point Data Format ID (%i)\nTotal Errors Found:  %i\n',  PublicHeaderBlock.PointDataFormatID, numErrors);
end
PublicHeaderBlock.PointDataRecordLength = fread(fid, 1, 'uint16=>uint32');
if PublicHeaderBlock.PointDataRecordLength == 28
    fprintf( 'Passed validation check:  Point Data Record Length 1/2 \n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Point Data Record Length 1/2 (%i)\nTotal Errors Found:  %i\n',  PublicHeaderBlock.PointDataRecordLength, numErrors);
end

PublicHeaderBlock.NumberOfPointRecords = fread(fid, 1, 'uint32=>uint32');

listing = dir(LASinputfile);
estimatedFileSize = PublicHeaderBlock.PointDataRecordLength*PublicHeaderBlock.NumberOfPointRecords + PublicHeaderBlock.OffsetToPointData;
if  estimatedFileSize == listing.bytes
    fprintf( 'Passed validation check:  Point Data Record Length 2/2 \n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Point Data Record Length 2/2 (file size:  %i, estimated file size:  %i)\nTotal Errors Found:  %i\n',  listing.bytes, estimatedFileSize, numErrors);
end

PublicHeaderBlock.NumberOfPointsByReturn = fread(fid, 5, 'uint32=>uint32')';

PublicHeaderBlock.XscaleFactor = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.YscaleFactor = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.ZscaleFactor = fread(fid, 1, 'real*8=>double');

PublicHeaderBlock.Xoffset = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.Yoffset = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.Zoffset = fread(fid, 1, 'real*8=>double');

PublicHeaderBlock.MaxX = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.MinX = fread(fid, 1, 'real*8=>double');

PublicHeaderBlock.MaxY = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.MinY = fread(fid, 1, 'real*8=>double');

PublicHeaderBlock.MaxZ = fread(fid, 1, 'real*8=>double');
PublicHeaderBlock.MinZ = fread(fid, 1, 'real*8=>double');

if ftell(fid) == PublicHeaderBlock.HeaderSize
    fprintf( 'Passed validation check:  Public Header Size\n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Public Header Size (ftell:  %i, header size:  %i)\nTotal Errors Found:  %i\n',  ftell(fid), PublicHeaderBlock.HeaderSize, numErrors);
end

if numErrors == 0
    fprintf( 'Public Header Block passed all validation checks!!!\n\n');
else
    fprintf( 'Public Header Block FAILED validation checks!!!\nExiting!!!\n');
    return
end

if PublicHeaderBlock.FileSourceID == 0
    fprintf('A Flight Line Number was not assigned\n');
else
    fprintf('Flight Line Number:  %i\n', PublicHeaderBlock.FileSourceID);
end

if PublicHeaderBlock.GlobalEncoding == 0
    fprintf('GPS Time in the point records fields is in GPS Week Time\n');
else
    fprintf('GPS Time is standard GPS Time minus 1x10^9\n');
end

fprintf('Format Specification used:  %s\n', PublicHeaderBlock.FormatSpecificationNumber);
fprintf('System Identifier:  %s\n', PublicHeaderBlock.SystemIdentifier);
fprintf('Generating Software:  %s\n', PublicHeaderBlock.GeneratingSoftware);
fprintf('Number of Data Points:  %i\n', PublicHeaderBlock.NumberOfPointRecords);

fprintf( 'Min X:  %8.4f\n', PublicHeaderBlock.MinX);
fprintf( 'Max X:  %8.4f\n', PublicHeaderBlock.MaxX);

fprintf( 'Min Y:  %8.4f\n', PublicHeaderBlock.MinY);
fprintf( 'Max Y:  %8.4f\n', PublicHeaderBlock.MaxY);

fprintf( 'Min Z:  %8.4f\n', PublicHeaderBlock.MinZ);
fprintf( 'Max Z:  %8.4f\n', PublicHeaderBlock.MaxZ);

fprintf( '\n');

%for LAS 1.3 spec
% PublicHeaderBlock.StartOfWaveformDataPacketRecord = fread(fid, 1, 'uint64=>uint64');

%Process Variable Length Records:
for i =1:PublicHeaderBlock.NumberOfVariableLengthRecords
    
    VariableLengthRecords(i).Reserved = fread(fid, 1, 'uint16=>uint16');
    if VariableLengthRecords(i).Reserved == 43707
        fprintf( 'Passed validation check:  Variable Length Record Signature \n');
    else
        numErrors = numErrors + 1;
        fprintf( 'Failed validation check:  Variable Length Record Signature (%i)\nTotal Errors Found:  %i\n',  VariableLengthRecords(i).Reserved, numErrors);
    end
    
    VariableLengthRecords(i).UserID = fread(fid, 16, 'uchar=>char')';
    fprintf( 'User ID:  %s\n', VariableLengthRecords(i).UserID);
    
    VariableLengthRecords(i).RecordID = fread(fid, 1, 'uint16=>uint16');
    fprintf( 'Record ID:  %i\n', VariableLengthRecords(i).RecordID);
    
    VariableLengthRecords(i).RecordLengthAfterHeader = fread(fid, 1, 'uint16=>uint16');
    VariableLengthRecords(i).Description = fread(fid, 32, 'uchar=>char')';
    VariableLengthRecords(i).RecordAfterHeader = fread(fid, VariableLengthRecords(i).RecordLengthAfterHeader, 'uchar=>char')';
    
end

if numErrors == 0
    fprintf( 'Variable Length Record Header Block passed all validation checks!!!\n\n');
    fprintf( 'Visually inspect User ID and Record ID fields to ensure proper settings!!!\n');
    fprintf( 'User ID field can be set to multiple things, however it commonly is used for the 1 mandatory and 2 optional LASF_Projection records\n');
    fprintf( 'Record ID field can be set to multiple things, 34735 is a mandatory LASF_Projection record and 34736 and 34737 are optional LASF_Projection records\n');
else
    fprintf( 'Variable Length Record Header Block FAILED validation checks!!!\nExiting!!!\n');
    return
end

fprintf('\n');

dataPointBlockSignature = fread(fid, 1, 'uint16=>uint16');
if dataPointBlockSignature == 52445
    fprintf( 'Passed validation check:  Point Data Record Signature \n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Point Data Record Signature (%i)\nTotal Errors Found:  %i\n', dataPointBlockSignature, numErrors);
end

if ftell(fid) == PublicHeaderBlock.OffsetToPointData
    fprintf( 'Passed validation check:  Point Data Record Offset \n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  Point Data Record Offset (file position:  %i, point data offset:  %i)\nTotal Errors Found:  %i\n', ftell(fid), PublicHeaderBlock.OffsetToPointData, numErrors);
end

h = waitbar(0,'Processing point data records, please wait...');
counter = 0;
dataPointRecordError = 0;
minIntensity = Inf;
maxIntensity = -Inf;
returnsCount = zeros(5,1);
numberOfReturns = zeros(5,1);
classificationNumber = zeros(5,1);
if mode == 1
    DataPoints(PublicHeaderBlock.NumberOfPointRecords,1) = struct( 'X', [], 'Y', [], 'Z',[],...
        'intensity', [], 'returnNumber', [], 'NumberOfReturns', [], 'ScanDirectionFlag', [], ...
        'EdgeOfFlightLine', [], 'Classification', [], 'ScanAngleRank', [], 'UserData', [], ...
        'PointSourceID', [], 'GPSTime', [], 'XCoord', [], 'YCoord', [], 'ZCoord', []);
    
elseif mode == 2
    
    DataPoints = zeros(PublicHeaderBlock.NumberOfPointRecords, 4);
    Coords = zeros(PublicHeaderBlock.NumberOfPointRecords, 3);
end
%+/- .01 added to solve numerical issues within matlab when dealing with doubles
MaxX = PublicHeaderBlock.MaxX + .01;
MinX = PublicHeaderBlock.MinX - .01;
MaxY = PublicHeaderBlock.MaxY + .01;
MinY = PublicHeaderBlock.MinY - .01;
MaxZ = PublicHeaderBlock.MaxZ + .01;
MinZ = PublicHeaderBlock.MinZ - .01;
for i=1:PublicHeaderBlock.NumberOfPointRecords
    
    counter = counter + 1;
    if counter > 10000
        waitbar(double(i)/cast(PublicHeaderBlock.NumberOfPointRecords,'double'),h);
        counter = 0;
    end
    
    X = fread(fid, 1, 'int32=>int32');
    Y = fread(fid, 1, 'int32=>int32');
    Z = fread(fid, 1, 'int32=>int32');
    
    XCoord = double(X)*PublicHeaderBlock.XscaleFactor + PublicHeaderBlock.Xoffset;
    YCoord = double(Y)*PublicHeaderBlock.YscaleFactor + PublicHeaderBlock.Yoffset;
    ZCoord = double(Z)*PublicHeaderBlock.ZscaleFactor + PublicHeaderBlock.Zoffset;
    
    if ~(XCoord <= MaxX && XCoord >= MinX)
        dataPointRecordError = 1;
        fprintf( 'Failed validation check:  X Coordinate outside of max/min X from header (X Coord:  %d, Header Max/Min X:  %d/%d, ) \n', XCoord, PublicHeaderBlock.MaxX, PublicHeaderBlock.MinX);
    end
    
    if ~(YCoord <= MaxY && YCoord >= MinY)
        dataPointRecordError = 1;
        fprintf( 'Failed validation check:  Y Coordinate outside of max/min Y from header (Y Coord:  %d, Header Max/Min Y:  %d/%d, ) \n', YCoord, PublicHeaderBlock.MaxY, PublicHeaderBlock.MinY);
    end
    
    if ~(ZCoord <= MaxZ && ZCoord >= MinZ)
        dataPointRecordError = 1;
        fprintf( 'Failed validation check:  Z Coordinate outside of max/min Z from header (Z Coord:  %d, Header Max/Min Z:  %d/%d, ) \n', ZCoord, PublicHeaderBlock.MaxZ, PublicHeaderBlock.MinZ);
    end
    
    intensity = fread(fid, 1, 'uint16=>uint16');
    if intensity > maxIntensity
        maxIntensity = intensity;
    end
    if intensity < minIntensity
        minIntensity = intensity;
    end
    
    returnNumber = fread(fid, 1, 'ubit3=>uint8');
    returnsCount(returnNumber) = returnsCount(returnNumber) + 1;
    
    NumberOfReturns = fread(fid, 1, 'ubit3=>uint8');
    numberOfReturns(NumberOfReturns) = numberOfReturns(NumberOfReturns) + 1;
    
    if returnNumber > NumberOfReturns
        dataPointRecordError = 1;
        fprintf( 'Failed validation check:  Return number greater than number of returns for given record (Return Number:  %i, Number of Returns:  %i) \n', returnNumber, NumberOfReturn);
    end
    
    ScanDirectionFlag = fread(fid, 1, 'ubit1=>uint8');
    EdgeOfFlightLine = fread(fid, 1, 'ubit1=>uint8');
    
    Classification = fread(fid, 1, 'uchar=>uint8');
    classificationNumber(Classification) = classificationNumber(Classification) + 1;
    
    ScanAngleRank = fread(fid, 1, 'int8=>int8');
    UserData = fread(fid, 1, 'uchar=>char');
    PointSourceID = fread(fid, 1, 'uint16=>uint16');
    GPSTime = fread(fid, 1, 'real*8=>double');
    
    if mode == 1
        
        DataPoints(i).X = X;
        DataPoints(i).Y = Y;
        DataPoints(i).Z = Z;
        DataPoints(i).XCoord = XCoord;
        DataPoints(i).YCoord = YCoord;
        DataPoints(i).ZCoord = ZCoord;
        
        DataPoints(i).intensity = intensity;
        DataPoints(i).returnNumber = returnNumber;
        DataPoints(i).NumberOfReturns = NumberOfReturns;
        DataPoints(i).ScanDirectionFlag = ScanDirectionFlag;
        DataPoints(i).EdgeOfFlightLine = EdgeOfFlightLine;
        DataPoints(i).Classification = Classification;
        DataPoints(i).ScanAngleRank = ScanAngleRank;
        DataPoints(i).UserData = UserData;
        DataPoints(i).PointSourceID = PointSourceID;
        DataPoints(i).GPSTime = GPSTime;
    elseif mode == 2
        warning off all;
        DataPoints(i,:) = [intensity, returnNumber, NumberOfReturns, EdgeOfFlightLine];
        Coords(i,:) = [XCoord, YCoord, ZCoord];
       
    end
    
    if dataPointRecordError
        fprintf('The user must decide to continue with file read or to kill this process due to the above error!!!\n');
        keyboard;
        dataPointRecordError = 0;
    end
    
end

close(h); % waitbar
fread(fid,1,'ubit1=>char');
if feof(fid)
    fprintf( 'Passed validation check:  End Of File \n');
else
    numErrors = numErrors + 1;
    fprintf( 'Failed validation check:  End Of File (file size:  %i, current position:  %i)\nTotal Errors Found:  %i\n',  listing.bytes, ftell(fid), numErrors);
end

if numErrors == 0
    fprintf( 'Point Data Records passed all validation checks!!!\n');
else
    fprintf( 'Point Data Records FAILED the validation checks!!!\nExiting!!!\n');
    return
end

fprintf('\nMaximum Intensity in file:  %i\n', maxIntensity);
fprintf('Minimum Intensity in file:  %i\n', minIntensity);
fprintf('Number of 1st returns:  %i, 2nd returns:  %i, 3rd returns:  %i, 4th returns:  %i, 5th returns:  %i\n', returnsCount(1), returnsCount(2), returnsCount(3), returnsCount(4), returnsCount(5));
fprintf('Number of 1 return records:  %i, 2 returns records:  %i, 3 returns records:  %i, 4 returns records:  %i, 5 returns records:  %i\n', numberOfReturns(1), numberOfReturns(2), numberOfReturns(3), numberOfReturns(4), numberOfReturns(5));
fprintf('Number of classification 1:  %i, classification 2:  %i, classification 3:  %i, classification 4:  %i, classification 5:  %i\n\n', classificationNumber(1), classificationNumber(2), classificationNumber(3), classificationNumber(4), classificationNumber(5));

if numErrors == 0
    fprintf( 'All validation checks have been passed, enjoy your data!!!\n');
else
    fprintf( 'Some validation checks have FAILED!!!\nExiting!!!\n');
    return
end

fclose(fid);
end
