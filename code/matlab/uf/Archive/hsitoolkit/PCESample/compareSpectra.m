function [SAD, bestMatch] = compareSpectra(Eestimate, SPECTRA)

%Example: call this function using the following PCE Sample output: [SAD, bestMatch] = compareSpectra(SampleTrace(2).E, SPECTRA);

for i = 1:length(SPECTRA)
    Etruth(i,:) = SPECTRA(i).data(:,3);
end

display = 1;

%normalize Etruth
nE = Etruth.*Etruth;
nE = sum(nE,2);
nE = sqrt(nE);
eTruthNorm = Etruth./repmat(nE, [1,size(Etruth,2)]);

for c = 1:size(Eestimate,3)
    %normalize spectra
    nE = Eestimate(:,:,c).*Eestimate(:,:,c);
    nE = sum(nE,2);
    nE = sqrt(nE);
    eEstNorm(:,:,c) = Eestimate(:,:,c)./repmat(nE, [1,size(Eestimate,2)]);
    for j = 1:size(Eestimate,1)
        SAD(:,j,c) = acos(eTruthNorm*eEstNorm(j,:,c)');
    end
    
    
end

[~, bestMatch] = min(SAD);
bestMatch = squeeze(bestMatch);

if(display)
    if(size(bestMatch,1) == 1)
            figure(101);
            for j = 1:size(Eestimate,1)
                subplot(1, size(Eestimate,1), j);
                plot(eEstNorm(j,:), 'r');
                hold on;
                plot(eTruthNorm(bestMatch(j), :), 'k');
                title({SPECTRA(bestMatch(j)).name, 'Red: Estimate, Black: Truth'});
            end
    else
        for k = 1:size(Eestimate,3)
            figure(100+k);
            for j = 1:size(Eestimate,1)
                subplot(1, size(Eestimate,1), j);
                plot(eEstNorm(j,:,k), 'r');
                hold on;
                plot(eTruthNorm(bestMatch(j,k), :), 'k');
                title({SPECTRA(bestMatch(j,k)).name, 'Red: Estimate, Black: Truth'});
            end
        end
    end
end