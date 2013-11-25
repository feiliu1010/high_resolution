; This code is writen to refine OMI swath NO2 data
; Siwen Wang (Nov 13, 2012)
; update by Fei Liu (Nov 23, 2013)
; Please do not distribute the code to others without author's concent.

pro get_OMI_NASA_v2_NO2_input_China_flag

for year = 2012,2012 do begin
for month = 2,2 do begin

if year eq 2004 and month lt 10 then continue

Yr4 = string(year,format='(i4.4)')
Mon2 = string(month,format='(i2.2)')

dir_omi='/z6/satellite/OMI/no2/NASA_Swath_v2/'+Yr4+'/'
spawn,'ls '+dir_omi+'OMI-Aura_L2-OMNO2_'+Yr4+'m'+Mon2+'*.he5 ',list_omi

dir_output = '/home/liufei/Data/High_resolution/preparation/NASA_v2_OMI_NO2_asc_for_China_cf50/flag/'+Yr4+'/'+Mon2+'/'
;dir_output = '/z5/wangsiwen/Satellite/no2/NASA_v2_OMI_NO2_asc_for_China_cf50/'+Yr4+'/'+Mon2+'/'

lp = 0 ; Set lp to 20 if only pixels 20~40 are used 
missing = -999.0

for k = 0L,n_elements(list_omi)-1L do begin

PRINT,'file: '+list_omi(k)
PRINT,strtrim((k+1),2)+' file(s) over '+strtrim(n_elements(list_omi),2)+' files to be processed'

; Define arrays to read in the data
ARRSIZE     = 150000L
lon1_s      = DblArr( ARRSIZE         )
lat1_s      = DblArr( ARRSIZE         )
lon2_s      = DblArr( ARRSIZE         )
lat2_s      = DblArr( ARRSIZE         )
lon3_s      = DblArr( ARRSIZE         )
lat3_s      = DblArr( ARRSIZE         )
lon4_s      = DblArr( ARRSIZE         )
lat4_s      = DblArr( ARRSIZE         )
sdate_s     = DblArr( ARRSIZE         )
spx_s       = DblArr( ARRSIZE         )
sza_s       = DblArr( ARRSIZE         )
g_lat_s     = DblArr( ARRSIZE         )
g_lon_s     = DblArr( ARRSIZE         )
no2trp_s    = DblArr( ARRSIZE         )
rcf_s       = DblArr( ARRSIZE         )
fc_s        = DblArr( ARRSIZE         )
cldpre_s    = DblArr( ARRSIZE         )
sfpres_s    = DblArr( ARRSIZE         )
terrainht_s = DblArr( ARRSIZE         )
salb_s      = DblArr( ARRSIZE         )
xtrack_flag_s = DblArr( ARRSIZE       )
n = 0L

;Read hdf files
fid = h5f_open(list_omi(k))

groupid = h5g_open(fid,'/HDFEOS/SWATHS/ColumnAmountNO2/Geolocation Fields/')
dataid  = h5d_open(groupid,'Latitude')             &  g_lat      = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'Longitude')            &  g_lon      = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'FoV75CornerLatitude')  &  latCorner  = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'FoV75CornerLongitude') &  lonCorner  = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'SolarZenithAngle')     &  sza        = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'Time')                 &  sdate      = h5d_read(dataid)
h5d_close, dataid
h5g_close, groupid

groupid = h5g_open(fid,'/HDFEOS/SWATHS/ColumnAmountNO2/Data Fields/')
dataid  = h5d_open(groupid,'CloudFraction')        &  fc         = h5d_read(dataid) * 0.001
h5d_close, dataid
dataid  = h5d_open(groupid,'CloudPressure')        &  cldpre     = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'CloudRadianceFraction')&  rcf        = h5d_read(dataid) * 0.001 
h5d_close, dataid
dataid  = h5d_open(groupid,'TerrainReflectivity')  &  salb       = h5d_read(dataid) * 0.001
h5d_close, dataid
dataid  = h5d_open(groupid,'TerrainPressure')      &  sfpres     = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'TerrainHeight')        &  terrainht  = h5d_read(dataid)
h5d_close, dataid
dataid  = h5d_open(groupid,'ColumnAmountNO2Trop')  &  no2trp     = h5d_read(dataid) / 1.0E+15
h5d_close, dataid
dataid  = h5d_open(groupid,'XTrackQualityFlags')   &  xtrack_flag= h5d_read(dataid)
h5d_close, dataid
h5g_close, groupid

h5f_close, fid

dim = SIZE(g_lat)
ntrack = dim[1]
ntimes = dim[2]
ntr_vec = 1 + INDGEN(ntrack)
tgt_spix = ntr_vec
spx = ntr_vec # replicate(1, ntimes)

print,ntrack,ntimes

flelen = strlen(list_omi(k))
fln_tag = strtrim(strmid(list_omi(k), flelen-65, 61),2)

YY = fix(strmid(list_omi[k], flelen-47, 4))
MM = fix(strmid(list_omi[k], flelen-42, 2))
DD = fix(strmid(list_omi[k], flelen-40, 2))

date_now = YY * 10000L + MM * 100L + DD * 1L
print,date_now

;Apply the filter for row anomaly
;IF yy EQ 2005 OR yy EQ 2006 THEN BEGIN
;    anomalies = 0
;ENDIF ELSE BEGIN
;    anomalies = 1
;ENDELSE

; Row Anomaly (0-based)
; Anomaly 1 (since June 25th 2007) ==> 53:54
; Anomaly 2 (since May, 11th 2008) ==> 37:42
; Anomaly 3 (since December, 1st 2008) ==> 35:44
; Anomaly 4 (since January, 24th 2009) ==> 28:44
; Anomaly 5 (since March 2009) ==> 30:40 and 46:49
; Anomaly 6 since August 1st 2009 use only cross-track pixels: 0-24


;IF (anomalies EQ 1) THEN BEGIN
;    PRINT,'REMOVING OMI ANOMALIES...'
;    IF (date_now GE 20070625L) THEN no2trp(53:54,*) = missing
;    IF (date_now GE 20080511L) THEN no2trp(37:44,*) = missing
;    IF (date_now GE 20090124L) THEN no2trp(27:44,*) = missing
;    IF (date_now GE 20110705L) THEN no2trp(42,45,*) = missing
;    IF (date_now GE 20110801L) THEN no2trp(41:45,*) = missing
;ENDIF

npix = N_ELements(no2trp[*,0])

for m=0L,n_elements(g_lon(0,*))-1L do begin

    lon1_s(n:n+(npix-lp)-1)       = loncorner(0,lp/2:npix-(lp/2+1),m)
    lon2_s(n:n+(npix-lp)-1)       = loncorner(1,lp/2:npix-(lp/2+1),m)
    lon3_s(n:n+(npix-lp)-1)       = loncorner(2,lp/2:npix-(lp/2+1),m)
    lon4_s(n:n+(npix-lp)-1)       = loncorner(3,lp/2:npix-(lp/2+1),m)
    lat1_s(n:n+(npix-lp)-1)       = latcorner(0,lp/2:npix-(lp/2+1),m)
    lat2_s(n:n+(npix-lp)-1)       = latcorner(1,lp/2:npix-(lp/2+1),m)
    lat3_s(n:n+(npix-lp)-1)       = latcorner(2,lp/2:npix-(lp/2+1),m)
    lat4_s(n:n+(npix-lp)-1)       = latcorner(3,lp/2:npix-(lp/2+1),m)
    sdate_s(n:n+(npix-lp)-1)      = sdate(m)
    spx_s(n:n+(npix-lp)-1)        = spx(lp/2:npix-(lp/2+1),m)
    sza_s(n:n+(npix-lp)-1)        = sza(lp/2:npix-(lp/2+1),m)
    g_lat_s(n:n+(npix-lp)-1)      = g_lat(lp/2:npix-(lp/2+1),m)
    g_lon_s(n:n+(npix-lp)-1)      = g_lon(lp/2:npix-(lp/2+1),m)
    no2trp_s(n:n+(npix-lp)-1)     = no2trp(lp/2:npix-(lp/2+1),m)
    rcf_s(n:n+(npix-lp)-1)        = rcf(lp/2:npix-(lp/2+1),m)
    fc_s(n:n+(npix-lp)-1)         = fc(lp/2:npix-(lp/2+1),m)
    cldpre_s(n:n+(npix-lp)-1)     = cldpre(lp/2:npix-(lp/2+1),m)
    sfpres_s(n:n+(npix-lp)-1)     = sfpres(lp/2:npix-(lp/2+1),m)    
    terrainht_s(n:n+(npix-lp)-1)  = terrainht(lp/2:npix-(lp/2+1),m)
    salb_s(n:n+(npix-lp)-1)       = salb(lp/2:npix-(lp/2+1),m)
    xtrack_flag_s(n:n+(npix-lp)-1)= xtrack_flag(lp/2:npix-(lp/2+1),m)
    n=n+(npix-lp)

endfor

;FILTERING (To customize)
ind_ok = where((sdate_s GT 0) AND (no2trp_s GE -10.0) AND                   $
               (sza_s GE 0. AND sza_s LT 70.) AND                           $
               (fc_s GE 0. AND fc_s LE 0.5) AND                             $
               (g_lat_s GE 15. AND g_lat_s LE 55.) AND                      $
               (g_lon_s GE 70. AND g_lon_s LE 150.) AND                     $
               (xtrack_flag_s EQ 0) AND                                     $
               (spx_s GE 5. AND spx_s LE 55.))

print,'available pixels in this file',n_elements(ind_ok)

if (ind_ok(0) EQ -1) then continue

lon1_s       = lon1_s(ind_ok)
lon2_s       = lon2_s(ind_ok)
lon3_s       = lon3_s(ind_ok)
lon4_s       = lon4_s(ind_ok)
lat1_s       = lat1_s(ind_ok)
lat2_s       = lat2_s(ind_ok)
lat3_s       = lat3_s(ind_ok)
lat4_s       = lat4_s(ind_ok)
sdate_s      = sdate_s(ind_ok)
spx_s        = spx_s(ind_ok)
sza_s        = sza_s(ind_ok)
g_lat_s      = g_lat_s(ind_ok)
g_lon_s      = g_lon_s(ind_ok)
no2trp_s     = no2trp_s(ind_ok)
rcf_s        = rcf_s(ind_ok)
fc_s         = fc_s(ind_ok)
cldpre_s     = cldpre_s(ind_ok)
sfpres_s     = sfpres_s(ind_ok)
terrainht_s  = terrainht_s(ind_ok)
salb_s       = salb_s(ind_ok)
xtrack_flag_s= xtrack_flag_s(ind_ok)

outfile = dir_output + fln_tag + '.asc'
print,outfile

openw,lun,outfile,/GET_LUN

for pp = 0L,n_elements(ind_ok)-1L do begin

printf, lun, format = '(20f15.4)', $
sdate_s[pp], spx_s[pp], g_lat_s[pp], g_lon_s[pp], no2trp_s[pp], sza_s[pp], $
lat1_s[pp], lat2_s[pp], lat3_s[pp], lat4_s[pp], $
lon1_s[pp], lon2_s[pp], lon3_s[pp], lon4_s[pp], $
rcf_s[pp], fc_s[pp], cldpre_s[pp], sfpres_s[pp], terrainht_s[pp], salb_s[pp]

endfor

close, lun
free_lun, lun

endfor ; loop over files

endfor

fin :

endfor;year
END


