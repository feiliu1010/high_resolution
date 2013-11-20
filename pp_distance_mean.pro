pro pp_distance_mean
;this program is used to calculate the mean column for  power plant as a function of the distance between the power plant and the pixel centre
;input file is the 'smooth' average file

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data

num=60
Locate=dblarr(3,num)
filename = '/home/liufei/Data/High_resolution/PP_isolated_list.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)	
;num=1
;Locate=[82,117.204483,39.089142]

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

Yr4='2012'
no2=dblarr(nlon,nlat)
header = strarr(6,1)
filename = '/home/liufei/Data/High_resolution/0.01degree/NO2/'+Yr4+'_11_25_no2_over_china_12km_with_nasa_v2.asc'
openr,lun,filename,/get_lun
readf,lun,header,no2
close,lun
Free_LUN,lun
;find the grid with max column around the city with a circle of 0.1 deg*0.1 deg
For i=0,num-1 do begin
	x = pplon[i]
	y = pplat[i]
	For j=-5,5 do begin
	For k=-5,5 do begin
		if no2[x+j,y+k] eq max(no2[x-5:x+5,y-5:y+5]) then begin
			pplon[i]=x+j
			pplat[i]=y+k
			j=5
			k=5
		endif
	endfor
	endfor
endfor

loc=dblarr(2,num)
loc[0,*]=LON[pplon]
loc[1,*]=LAT[pplat]
header=['longitude','latitude']
outfile ='/home/liufei/Data/High_resolution/pp_isolated_max_loc.csv'
openw,lun,outfile,/get_lun,WIDTH=250
printf,lun,header,loc
close,lun
free_lun,lun


;average of column around centre
time_num=20
col=dblarr(num,time_num)
count=fltarr(num,time_num)
distance=dblarr(num,time_num)
For i=0,num-1 do begin
	x = pplon[i]
        y = pplat[i]
	col[i,0]=no2[x,y]
	distance[i,0]=0
	For time=1,time_num-1 do begin
		;calculate very 10-steps (~10km)
		delta=10*time
		;calculate the column
		For j=-delta,delta do begin
			if (x-delta lt nlon) and (y+j lt nlat) then begin
				col[i,time]+= no2[x-delta,y+j]
				count[i,time]+=1
			endif else if (x+delta lt nlon) and (y+j lt nlat) then begin
				col[i,time]+= no2[x+delta,y+j]
				count[i,time]+=1
			endif else if (x+j lt nlon) and (y+delta lt nlat) then begin
				col[i,time]+= no2[x+j,y+delta]
				count[i,time]+=1
			endif else if (x+j lt nlon) and (y-delta lt nlat) then begin
				col[i,time]+= no2[x+j,y-delta]
				count[i,time]+=1
			endif
		endfor
		if (x-delta lt nlon) and (y+delta lt nlat) then begin
			col[i,time]-= no2[x-delta,y+delta]
			count[i,time]-=1
		endif else if (x-delta lt nlon) and (y-delta lt nlat) then begin
			col[i,time]-= no2[x-delta,y-delta]
			count[i,time]-=1
		endif else if (x+delta lt nlon) and (y+delta lt nlat) then begin
			col[i,time]-= no2[x+delta,y+delta]
			count[i,time]-=1
		endif else if (x+delta lt nlon) and (y-delta lt nlat) then begin
			col[i,time]-= no2[x+delta,y-delta]
			count[i,time]-=1
		endif
			
		col[i,time]= col[i,time]/count[i,time]	
		;calculate the distance
		if (x+delta lt nlon) then begin
			distance[i,time]=map_2points(lon[x],lat[y],lon[x+delta],lat[y],/meters)/1000
		endif else begin
			distance[i,time]=map_2points(lon[x],lat[y],lon[x-delta],lat[y],/meters)/1000
		endelse
	endfor
endfor

result=dblarr(2*num,time_num)
;header=fltarr(2*num)
header=fltarr(num)
For i=0,num-1 do begin
	result[2*i,*]=distance[i,*]
	result[2*i+1,*]=col[i,*]
;	header[2*i:(2*i+1)]=string(i+1)
	header[i]=string(i+1)
endfor


outfile ='/home/liufei/Data/High_resolution/PP_distance_no2_'+Yr4+'.csv'
openw,lun,outfile,/get_lun,WIDTH=5000
;printf,lun,header,result
printf,lun,header,col
close,lun
free_lun,lun

end
