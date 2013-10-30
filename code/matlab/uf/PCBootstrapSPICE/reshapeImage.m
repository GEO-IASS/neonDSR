function pixelList = reshapeImage(imageData)

pixelList = reshape(shiftdim(imageData(:,:,:),2),size(imageData,3),size(imageData,1)*size(imageData,2));