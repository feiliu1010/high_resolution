pro find_pp_major
;this program is used to lable the power plants' percentage of emissions in one grid

;build look-up table of power plants' location
FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data

;num=2084
;num=2237
num=2066
Locate=dblarr(3,num)
filename = '/home/liufei/Data/High_resolution/plant_list.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)

nlon = 800
nlat = 500
grid = 0.1
lon = dblarr(nlon)
lat = dblarr(nlat)
lon = 70+grid/2+indgen(nlon)*grid
lat = 10+grid/2+indgen(nlat)*grid

pplon= fltarr(num)
pplat= fltarr(num)

For i=0,num-1 do begin

pplon[i] = where( ( lon ge (Locate[1,i]-grid/2)) and (lon le (Locate[1,i]+grid/2)) ,count1)
pplat[i] = where( ( lat ge (Locate[2,i]-grid/2)) and (lat le (Locate[2,i]+grid/2)) ,count2)

if ( count1 eq 2 ) then begin
	pplon[i] = max(pplon[i])
endif
if ( count2 eq 2) then begin
	pplat[i] = max(pplat[i])
endif

if pplon[i] eq -1 then begin
	pplon[i]=where(abs(lon-Locate[1,i]-grid/2) lt 10^(-5.0))
endif
if pplat[i] eq -1 then begin
	pplat[i]=where(abs(lat-Locate[2,i]-grid/2) lt 10^(-5.0))
endif

endfor

;temp=fltarr(2,num)
;temp[0,*]=pplon
;temp[1,*]=pplat
;outfile ='/home/liufei/Data/High_resolution/PP_temp.asc'
;openw,lun,outfile,/get_lun
;printf,lun,temp
;close,lun
;free_lun,lun


year1=2005
year2=2005
col=year2-year1+1
result=dblarr(col*2+1,num)
header_output=strarr(col*2+1)

For year=year1,year2 do begin

Yr4= string(year,format='(i4.4)')

density1=dblarr(nlon,nlat)
density2=dblarr(nlon,nlat)
density3=dblarr(nlon,nlat)
density4=dblarr(nlon,nlat)
sum=dblarr(nlon,nlat)
ratio=dblarr(nlon,nlat)

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__residential__NOx.nc'
fid=NCDF_OPEN(filename)
varid1=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid1, density1
NCDF_CLOSE, fid

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__industry__NOx.nc'
fid=NCDF_OPEN(filename)
varid2=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid2, density2
NCDF_CLOSE, fid

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__power__NOx.nc'
fid=NCDF_OPEN(filename)
varid3=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid3, density3
NCDF_CLOSE, fid

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__transportation__NOx.nc'
fid=NCDF_OPEN(filename)
varid4=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid4, density4
NCDF_CLOSE, fid

;z:nodata_value = -9999.
density1[where(density1 lt 0)]=0
density2[where(density2 lt 0)]=0
density3[where(density3 lt 0)]=0
density4[where(density4 lt 0)]=0

density1=reform(density1,nlon,nlat)
density2=reform(density2,nlon,nlat)
density3=reform(density3,nlon,nlat)
density4=reform(density4,nlon,nlat)

sum=density1+density2+density3+density4


header_output2 = [['ncols 800'],['nrows 500'],['xllcorner 70'],['yllcorner 10'],['cellsize 0.1'],['nodata_value -999.0']]
outfile ='/home/liufei/Data/High_resolution/2010emis.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output2,sum
close,lun
free_lun,lun
outfile ='/home/liufei/Data/High_resolution/'+Yr4+'emis_pp.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output2,density3
close,lun
free_lun,lun

;asc convert to nc,MEIC nc file is starts at left-up corner
for j=1, nlat/2 do begin
tmp = sum[*,j-1]
sum[*,j-1] = sum[*,nlat-j]
sum[*,nlat-j] = tmp
endfor
undefine, tmp
for j=1, nlat/2 do begin
tmp = density3[*,j-1]
density3[*,j-1] = density3[*,nlat-j]
density3[*,nlat-j] = tmp
endfor
undefine, tmp


ratio[where(sum eq 0)]=0
ratio[where(sum ne 0)]= density3[where(sum ne 0)]/sum[where(sum ne 0)]

For i=0,num-1 do begin
	result[(year-year1)*2,i]=ratio[pplon[i],pplat[i]]
	result[(year-year1)*2+1,i]=density3[pplon[i],pplat[i]]
endfor

header_output[(year-year1)*2]=string(year,format='(i4.4)')+'ratio'
header_output[(year-year1)*2+1]=string(year,format='(i4.4)')+'pp_emission'

endfor; year

pop=dblarr(nlon,nlat)
header = strarr(6,1)
filename = '/home/liufei/Data/Parameters/Population/0.1/urbanpop_01.asc'
openr,lun,filename,/get_lun
readf,lun,header,pop
close,lun
Free_LUN,lun

;asc convert to nc
for j=1, nlat/2 do begin
tmp = pop[*,j-1]
pop[*,j-1] = pop[*,nlat-j]
pop[*,nlat-j] = tmp
endfor
undefine, tmp


For i=0,num-1 do begin
        result[col*2,i]=pop[pplon[i],pplat[i]]
endfor

;header_output=strarr(col+1,1)
;For i=0,col-1 do begin
;	header_output[i]=string(year1+i,format='(i4.4)')
;endfor
header_output[col*2]='urban_pop'
print,header_output

outfile ='/home/liufei/Data/High_resolution/PP_emission_ratio.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output,result
close,lun
free_lun,lun

end
