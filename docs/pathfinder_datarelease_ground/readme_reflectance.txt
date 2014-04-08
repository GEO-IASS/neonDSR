Pathfinder reflectance data

There are two files associated with each reflectance dataset: JPEG image and text files.  

Text file information
---------------------

File name convention:

YYMMDD_AAA-BBB_qqqq.txt

	YY   - two-digit year of meaurement
	MM   - two-digit month of meaurement
	DD   - two-digit day of meaurement
	AAA  - beginning spectrum number
	BBB  - ending spectrum number
	qqqq - short description
	
File contents:

	The reflectance data file has three columns
	1. Wavelength in nanometers
	2. reflectance (mean of several measurements)
	3. standard deviation of the mean calculated in column 2
	

JPEG file information
---------------------

File name convention:

YYMMDD_AAA-BBB_qqqq.txt

	YY   - two-digit year of meaurement
	MM   - two-digit month of meaurement
	DD   - two-digit day of meaurement
	AAA  - beginning spectrum number
	BBB  - ending spectrum number
	qqqq - short description
	
File contents:

Text at the top of the image:
This image file is meant to give a preview of the data contained in the associated 
text file.  The top of the file gives date, time, and location information about 
the dataset.  

Spectra quicklook:
The top plot shows a quicklook of the spectra acquired with the field-portable 
spectroradiometer for the current measurement set.  The list of "Samples selected:" 
in the top right of the image show the spectra selected for calculating the mean 
and standard deviation.

Photograph:
If available, an photograph will be shown to give context of the measurement.  
This will be seen to the right of the spectra quicklook.

Mean reflectance:
A plot of the mean reflectance data from the associated text file.  Spectral 
regions of water vapor absorption (low signal) may have been deleted for more 
clarity.

Percent standard deviation:
The standard deviation is included in the dataset to provide an idea of the 
variability of the measurement.