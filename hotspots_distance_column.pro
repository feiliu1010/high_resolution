pro hotspots_distance_column
;this program is used to calculate the mean column for city inside the distance 
;input file is the 'smooth' average file

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data

;num=85
num= 33
Locate=dblarr(4,num)
;filename = '/home/liufei/Data/High_resolution/City_distance_list.csv'
filename = '/home/liufei/Data/High_resolution/PP_distance_list.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)
Dis=dblarr(num)
Dis=Locate[3,*]


nlon = 8000
nlat = 4000
grid = 0.01
lon = dblarr(nlon)
lat = dblarr(nlat)
lon = 70+grid/2+indgen(nlon)*grid
lat = 55-grid/2-indgen(nlat)*grid

pplon= fltarr(num)
pplat= fltarr(num)

;find the grid of city
For i=0,num-1 do begin
pplon[i] = max( where( ( lon ge (Locate[1,i]-grid/2)) and (lon le (Locate[1,i]+grid/2)) ,count1) )
pplat[i] = max( where( ( lat ge (Locate[2,i]-grid/2)) and (lat le (Locate[2,i]+grid/2)) ,count2) )

if pplon[i] eq -1 then begin
        pplon[i]=where(abs(lon-Locate[1,i]-grid/2) lt 10^(-5.0))
endif
if pplat[i] eq -1 then begin
        pplat[i]=where(abs(lat-Locate[2,i]-grid/2) lt 10^(-5.0))
endif

endfor

sty=2005
endy=2012
result=dblarr(endy-sty+2,num)
out_header=strarr(endy-sty+2,1)

For year = sty, endy do begin
Yr4=string(year,format='(i4.4)')
no2=dblarr(nlon,nlat)
header = strarr(6,1)
filename = '/home/liufei/Data/High_resolution/0.01degree/NO2/no2_over_china_12km_'+Yr4+'_with_nasa_v2.asc'
openr,lun,filename,/get_lun
readf,lun,header,no2
close,lun
Free_LUN,lun

;average of column around centre
col=dblarr(num)
count=fltarr(num)

For i=0,num-1 do begin
        x = pplon[i]
        y = pplat[i]
        delta=Dis[i]*10
        For j=-delta,delta do begin
        For k=-delta,delta do begin
            if (x+j lt nlon) and (y+k lt nlat) then begin
                col[i]  += no2[x+j,y+k]
                count[i]+=1
            endif
        endfor
        endfor
	col[i]=col[i]/count[i]
endfor;num


result[year-sty+1,*]= col
out_header[year-sty+1,0]= YR4
endfor;year

out_header[0]='CityID'
For i=1,num do begin
	result[0,i-1]= string(i)
endfor


;outfile ='/home/liufei/Data/High_resolution/City_distance_colunm_average.csv'
outfile ='/home/liufei/Data/High_resolution/PP_distance_colunm_average.csv'
openw,lun,outfile,/get_lun,WIDTH=5000
printf,lun,out_header,result
close,lun
free_lun,lun

end
