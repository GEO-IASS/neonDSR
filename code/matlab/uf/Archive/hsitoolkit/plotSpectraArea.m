function [] = plotSpectraArea(HSIData, dataPoint, backgroundPoint, spectralSignature)
figure;
HSIDataPoint = HSIData.z(dataPoint(1), dataPoint(2),:);
ax(1) = plot(HSIData.info.wavelength, squeeze(HSIDataPoint), '--rx', 'LineWidth', 2);
hold on

ax(2) = plot(spectralSignature.wavelengths(spectralSignature.startHSIBandIndex:spectralSignature.endHSIBandIndex), ...
    spectralSignature.reflectance(spectralSignature.startHSIBandIndex:spectralSignature.endHSIBandIndex), 'g', 'LineWidth', 2);

allSpec(1,:) =  HSIData.z(dataPoint(1) - 1, dataPoint(2) - 1,:);
allSpec(2,:) =  HSIData.z(dataPoint(1), dataPoint(2) - 1,:);
allSpec(3,:) =  HSIData.z(dataPoint(1) + 1, dataPoint(2) - 1,:);
allSpec(4,:) =  HSIData.z(dataPoint(1) - 1, dataPoint(2),:);
allSpec(5,:) =  HSIData.z(dataPoint(1) + 1, dataPoint(2),:);
allSpec(6,:) =  HSIData.z(dataPoint(1) - 1, dataPoint(2) + 1,:);
allSpec(7,:) =  HSIData.z(dataPoint(1), dataPoint(2) + 1,:);
allSpec(8,:) =  HSIData.z(dataPoint(1) + 1, dataPoint(2) + 1,:);

ax(3) = plot(HSIData.info.wavelength, allSpec(1,:), 'b');
plot(HSIData.info.wavelength, allSpec, 'b');

HSIDataPoint2 = HSIData.z(backgroundPoint(1), backgroundPoint(2),:);
ax(4) = plot(HSIData.info.wavelength, squeeze(HSIDataPoint2), '--ko', 'LineWidth', 2);

legend(ax, 'Target Pixel Spectra', 'Cary500 Spectral Signature', 'Surrounding Pixel Spectra', 'Background Material Pixel');

xlabel('Wavelengths');
ylabel('Reflectance');
title('Reflectance Plots of Target');
end