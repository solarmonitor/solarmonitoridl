;PROJECT 	- SOLARMONITOR.ORG
;NAME 		- KANZEL_PREP
;USE 		- Fix the limb darkening on the raw kanzelhoe H-alpha data.
;INPUT  	- LOCALFILE - File name of the FITs to be read in.
;OUTPUT		- ODATA - Limb corrected data array.
;OPT IN		- MAP - Map structure of the data.
;			- INDEX - Full index given by MREADFITS.
;
;Written 12-May-2009 P.A Higgins - pohuigin@gmail.com

pro kanzel_prep, odata, localfile=localfile, index=index, map=map

if n_elements(map) lt 1 then fits2map,localfile,map

if n_elements(index) lt 1 then mreadfits,localfile,index

data=map.data

data=data-min(data)

darklimb_correct, data, odata, lambda = 6562.808, limbxyr = [index.crpix1,index.crpix2,map.rsun/map.dx]

end