function  hsi2scidb( hsi_img )
%HSI2SCIDB This function will generate a csv file that is conforming to
%scidb specs.
%   The way it works is as follows: here we produce a 1D matrix in scidb
%   that will have X, Y, wave_len, Val in each line, later on when importing to scidb
%  , redimension_store will convert X,Y, wave_len n to respective dimensions (3d) 

fName = 'hsi_img.csv';
fid = fopen(fName,'w');    
if fid ~= -1
  fprintf(fid,'%s\r\n','x,y,wave_length,val');       %# Print the string
                   


    for i = 1:size(hsi_img,1)
        for j = 1:size(hsi_img,2)
            for k = 1:size(hsi_img,3)
                 fprintf(fid,'%d,%d,%d,%d\r\n',i,j,k,hsi_img(i,j,k));  
            end
        end
    end

end
fclose(fid);   % Close the file
end