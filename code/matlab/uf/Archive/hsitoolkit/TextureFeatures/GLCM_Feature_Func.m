function F = GLCM_Feature_Func(WINDOW)
	GLCM = graycomatrix(WINDOW);
	STATS = graycoprops(GLCM);
	F = [STATS.Contrast; STATS.Correlation; STATS.Energy; STATS.Homogeneity];
end
