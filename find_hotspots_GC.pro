pro find_hotspots_GC
;this programme is used to find the results of Geos-chem simulation of hotspots
;GC resolution:0.5*0.667

num=85
Locate=dblarr(4,num)
filename = '/home/liufei/Data/High_resolution/City_distance_list.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)
Dis=dblarr(num)
Dis=Locate[3,*]

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )
inxmid = InGrid.xmid
inymid = InGrid.ymid

;read gc file
year1=2011
YR1=string(year1,format='(i4.4)')
year2=2012
YR2=string(year2,format='(i4.4)')
period = 'JantoDec'

GC1 = fltarr(InGrid.IMX,InGrid.JMX)
gc_file1= '/home/liufei/Data/Geos-chem/sample/'+YR1+'_'+period +'_GC_0.66x0.50.nc'
file_in1 = string(gc_file1)
fid1=NCDF_OPEN(file_in1)
VCDID1=NCDF_VARID(fid1,'TropVCD')
NCDF_VARGET, fid1, VCDID1,GC1
NCDF_CLOSE, fid1

GC2 = fltarr(InGrid.IMX,InGrid.JMX)
gc_file2= '/home/liufei/Data/Geos-chem/sample/'+YR2+'_'+period +'_GC_0.66x0.50.nc'
file_in2 = string(gc_file2)
fid2=NCDF_OPEN(file_in2)
VCDID2=NCDF_VARID(fid2,'TropVCD')
NCDF_VARGET, fid2, VCDID2,GC2
NCDF_CLOSE, fid2

;read OMI file
lon_sta=70
lon_end=150

lat_sta=15
lat_end=55

nlon = 8000
nlat = 4000

VC1_t=dblarr(nlon,nlat)
header = strarr(6,1)
filename = '/home/liufei/Data/High_resolution/0.01degree/NO2/no2_over_china_12km_'+Yr1+'_with_nasa_v2.asc'
openr,lun,filename,/get_lun
readf,lun,header,VC1_t
close,lun
Free_LUN,lun

VC2_t=dblarr(nlon,nlat)
header = strarr(6,1)
filename = '/home/liufei/Data/High_resolution/0.01degree/NO2/no2_over_china_12km_'+Yr2+'_with_nasa_v2.asc'
openr,lun,filename,/get_lun
readf,lun,header,VC2_t
close,lun
Free_LUN,lun
;convert asc to nc
for j=1, nlat/2 do begin
tmp = VC1_t[*,j-1]
VC1_t[*,j-1] = VC1_t[*,nlat-j]
VC1_t[*,nlat-j] = tmp
endfor
undefine, tmp

for j=1, nlat/2 do begin
tmp = VC2_t[*,j-1]
VC2_t[*,j-1] = VC2_t[*,nlat-j]
VC2_t[*,nlat-j] = tmp
endfor
undefine, tmp

;expand to global
nlon_g = 36000
nlat_g = 18000

VC1 = dblarr(nlon_g,nlat_g)
VC2 = dblarr(nlon_g,nlat_g)
print,(180+lon_sta)*100-1,uint((180+lon_end)*100-1),(90+lat_sta)*100-1,(90+lat_end)*100-1

VC1[((180+lon_sta)*100-1):uint(((180+lon_end)*100-2)),((90+lat_sta)*100-1):((90+lat_end)*100-2)]=VC1_t
VC2[((180+lon_sta)*100-1):uint(((180+lon_end)*100-2)),((90+lat_sta)*100-1):((90+lat_end)*100-2)]=VC2_t


;grid_x=float(2/3)
grid_x=0.6667
grid_y=0.5
lon = inxmid
lat = inymid
close, /all
;print,lon
;print,lat
pplon= fltarr(num)
pplat= fltarr(num)

;find the grid of hotspots at GC resolution
For i=0,num-1 do begin
pplon[i] = max( where( ( lon ge (Locate[1,i]-grid_x/2)) and (lon le (Locate[1,i]+grid_x/2)) ,count1) )
pplat[i] = max( where( ( lat ge (Locate[2,i]-grid_y/2)) and (lat le (Locate[2,i]+grid_y/2)) ,count2) )

;print,pplon[i],pplat[i]
if pplon[i] eq -1 then begin
        pplon[i]=where(abs(lon-Locate[1,i]-grid_x/2) lt 10^(-5.0))
endif
if pplat[i] eq -1 then begin
        pplat[i]=where(abs(lat-Locate[2,i]-grid_y/2) lt 10^(-5.0))
endif

endfor

;find the grid of hotspots at OMI resolution
pplon_omi= fltarr(num)
pplat_omi= fltarr(num)
grid_omi=0.01
lon_omi = -180+grid_omi/2+indgen(nlon)*grid_omi
lat_omi = -90 +grid_omi/2+indgen(nlat)*grid_omi

For i=0,num-1 do begin
pplon_omi[i] = max( where( ( lon_omi ge (Locate[1,i]-grid_omi/2)) and (lon le (Locate[1,i]+grid_omi/2)) ,count1) )
pplat_omi[i] = max( where( ( lat_omi ge (Locate[2,i]-grid_omi/2)) and (lat le (Locate[2,i]+grid_omi/2)) ,count2) )

if pplon_omi[i] eq -1 then begin
        pplon_omi[i]=where(abs(lon_omi-Locate[1,i]-grid_omi/2) lt 10^(-5.0))
endif
if pplat_omi[i] eq -1 then begin
        pplat_omi[i]=where(abs(lat_omi-Locate[2,i]-grid_omi/2) lt 10^(-5.0))
endif

endfor


;calculate the corresponding GC results inside the hotspot boundary
emis1=dblarr(num)
emis2=dblarr(num)

emis_weight1=dblarr(num)
emis_weight2=dblarr(num)

sample1=fltarr(num)
sample2=fltarr(num)

For i=0,num-1 do begin
        x = pplon[i]
        y = pplat[i]
	x_OMI = pplon_OMI[i]
        y_OMI = pplat_OMI[i]

        delta=Dis[i]*10
        For j=-delta,delta do begin
        For k=-delta,delta do begin
	;find the grid inside boundary of GC
	temp_lon = max( where( ( lon ge (lon[x]+0.01*j-grid_x/2)) and (lon le (lon[x]+0.01*j+grid_x/2)) ,count1) )
	temp_lat = max( where( ( lat ge (lat[y]+0.01*k-grid_y/2)) and (lat le (lat[y]+0.01*k+grid_y/2)) ,count2) )
	if temp_lon eq -1 then begin
        	temp_lon = where(abs(lon-(lon[x]+0.01*j)-grid_x/2) lt 10^(-5.0))
	endif
	if temp_lat eq -1 then begin
        	temp_lat = where(abs(lat-(lat[y]+0.01*k)-grid_y/2) lt 10^(-5.0))
	endif

	;sum the GC results
	if GC1[temp_lon,temp_lat] gt 0U then begin
		emis1[i]+=GC1[temp_lon,temp_lat]
		emis_weight1[i]+=VC1[x_OMI+j,y_OMI+k]*GC1[temp_lon,temp_lat]
		sample1[i]+=1
	endif
	if GC2[temp_lon,temp_lat] gt 0U then begin
                emis2[i]+=GC2[temp_lon,temp_lat]
		emis_weight2[i]+=VC2[x_OMI+j,y_OMI+k]*GC2[temp_lon,temp_lat]
                sample2[i]+=1
        endif
	endfor
	endfor
endfor

For i=0,num-1 do begin
	if sample1[i] gt 0u then begin
		emis1[i]=emis1[i]/sample1[i]
	endif else begin
		emis1[i]=-999
	endelse

	if sample2[i] gt 0u then begin
                emis2[i]=emis2[i]/sample2[i]
        endif else begin
                emis2[i]=-999
        endelse
endfor

header=['ID',YR1,YR2,'weight1','weight2']
result=dblarr(5,num)
result[0,*]= Locate[0,*]
result[1,*]= emis1
result[2,*]= emis2
result[3,*]= emis_weight1
result[4,*]= emis_weight2

outfile ='/home/liufei/Data/High_resolution/City_distance_GC_VCD.csv'
openw,lun,outfile,/get_lun,WIDTH=5000
printf,lun,header,result
close,lun
free_lun,lun

end
