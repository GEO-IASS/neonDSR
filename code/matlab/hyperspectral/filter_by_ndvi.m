function subimg = filter_by_ndvi( subimg, ndvi )

global setting;

[x, y] = size(ndvi);
for i=1:x
    for j=1:y
        if ndvi(i, j) < setting.NDVI_THRESHOLD
            subimg(i, j, :)  = 0;
        end
        
        if subimg(i,j,setting.NIR_INDEX) < setting.NIR_THRESHOLD
            subimg(i, j, :)  = 0;
        end
    end
end

end

