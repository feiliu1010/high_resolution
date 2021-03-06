pro map_city_info
;this program is used to mapping information (from MEIC: power plant emissions, vehicle emissions, total emissions; from power plant database: total capacity, SCR capacity) 
;MEIC resolution: 0.1 degree
FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data
;********************************
num=85
Locate=dblarr(4,num)
filename = '/home/liufei/Data/High_resolution/City_distance_list.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)
Dis=dblarr(num)
Dis=Locate[3,*]

nlon = 800
nlat = 500
grid = 0.1
lon = dblarr(nlon)
lat = dblarr(nlat)
lon = 70+grid/2+indgen(nlon)*grid
lat = 60-grid/2-indgen(nlat)*grid

pplon= fltarr(num)
pplat= fltarr(num)

;find the grid of city at MEIC resolution
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


unit_coal_2011=dblarr(num)
unit_coal_2012=dblarr(num)
unit_emis_2011=dblarr(num)
unit_emis_2012=dblarr(num)

;**********************************
year1=2005
year2=2012
;every year has 4 data: power plant emissions, vehicle emissions, total emissions, total capacity
col=year2-year1+1
;2011 and 2012 has one  extra data: SCR capacity, coal consumption, NOX emissions
result=dblarr(col*4+7,num)
result[col*4+6,*]=Locate[0,*]
header_output=strarr(col*4+7)
header_output[col*4+6]='city_ID'

For year=year1,year2 do begin

Yr4= string(year,format='(i4.4)')


;calculate the emissions
density1=dblarr(nlon,nlat)
density2=dblarr(nlon,nlat)
density3=dblarr(nlon,nlat)
density4=dblarr(nlon,nlat)
sum=dblarr(nlon,nlat)

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

pp=dblarr(num)
vehicle=dblarr(num)
emis=dblarr(num)
For i=0,num-1 do begin
        x = pplon[i]
        y = pplat[i]
        delta=Dis[i]
        For j=-delta,delta do begin
	For k=-delta,delta do begin
	    if (x+j lt nlon) and (y+k lt nlat) then begin
		pp[i]     +=density3[x+j,y+k]
		vehicle[i]+=density4[x+j,y+k]
		emis[i]   +=sum[x+j,y+k]
	    endif
	endfor
	endfor
endfor;num

;calculate capacity
;*************************************
num_pp_2005_2010=2902
num_pp_2011=2367
num_pp_2012=2388

case year of
2011:num_pp=num_pp_2011
2012:num_pp=num_pp_2012
else:num_pp=num_pp_2005_2010
endcase
 
if year le 2010 then begin
	Locate= dblarr(8,num_pp)
	unit  = dblarr(3,num_pp)
	filename = '/home/liufei/Data/High_resolution/unit_capacity_2005_2010.csv'
	DELIMITER = ','
	HEADERLINES = 1
	Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
	Locate=Data.(0)
	unit=[Locate[0,*],Locate[1,*],Locate[year-2005+2,*]]
endif else begin
	;2011,2012 has extra info: coal consumption and NOX emissions
	Locate = dblarr(5,num_pp)
	unit   = dblarr(5,num_pp)
	filename='/home/liufei/Data/High_resolution/unit_capacity_'+Yr4+'.csv'
	DELIMITER = ','
        HEADERLINES = 1
        Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
        Locate=Data.(0)
        unit=Locate	
endelse


;whether pp inside city+-delta
cap=dblarr(num)
unit_coal=dblarr(num)
unit_emis=dblarr(num)

For i=0,num-1 do begin
        x = pplon[i]
        y = pplat[i]
        delta=Dis[i]
	For j=0,num_pp-1 do begin
		if (unit[0,j] le lon[min([x+delta,nlon-1])]+grid/2) and (unit[0,j] ge lon[max([x-delta,0])]-grid/2) $
		and (unit[1,j] le lat[max([y-delta,0])]+grid/2) and (unit[1,j] ge lat[min([y+delta,nlat-1])]-grid/2) then begin
			cap[i]+= unit[2,j]
			if year ge 2011 then begin
				unit_coal[i]+= unit[3,j]
				unit_emis[i]+= unit[4,j]
			endif
		endif
	endfor			
endfor

;output result
result[(year-year1)*4,*]= pp
result[(year-year1)*4+1,*]=vehicle
result[(year-year1)*4+2,*]=emis
result[(year-year1)*4+3,*]=cap

case year of 
2011:unit_coal_2011=unit_coal
2012:unit_coal_2012=unit_coal
else:print,'NO',YR4
endcase

case year of
2011:unit_emis_2011=unit_emis
2012:unit_emis_2012=unit_emis
else:print,'NO',YR4
endcase

header_output[(year-year1)*4]=strcompress(string(year,format='(i4.4)')+'_pp_emis',/remove)
header_output[(year-year1)*4+1]=strcompress(string(year,format='(i4.4)')+'_vehicle_emis',/remove)
header_output[(year-year1)*4+2]=strcompress(string(year,format='(i4.4)')+'_total_emis',/remove)
header_output[(year-year1)*4+3]=strcompress(string(year,format='(i4.4)')+'_total_capacity',/remove)

endfor; year

;calculate SCR capacity

;*******************************
For year=2011,2012 do begin
	case year of
		2011:num_pp=237
		2012:num_pp=408
	endcase

	Yr4= string(year,format='(i4.4)')
        Locate = dblarr(3,num_pp)
        unit   = dblarr(3,num_pp)
        filename='/home/liufei/Data/High_resolution/SCR_unit_'+Yr4+'.csv'
        DELIMITER = ','
        HEADERLINES = 1
        Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
        Locate=Data.(0)
        unit=Locate
	;whether pp inside city+-delta
	cap=dblarr(num)
	For i=0,num-1 do begin
        	x = pplon[i]
 	        y = pplat[i]
        	delta=Dis[i]
	        For j=0,num_pp-1 do begin
                     if (unit[0,j] le lon[min([x+delta,nlon-1])]+grid/2) and (unit[0,j] ge lon[max([x-delta,0])]-grid/2) $
                and (unit[1,j] le lat[max([y-delta,0])]+grid/2) and (unit[1,j] ge lat[min([y+delta,nlat-1])]-grid/2) then begin    
			cap[i]+= unit[2,j]
                    endif
		endfor
        endfor
	
	result[col*4+(year-2011),*]=cap
	header_output[col*4+(year-2011)]=strcompress(string(year,format='(i4.4)')+'_SCR_capacity',/remove)

endfor

result[col*4+(year2-2011)+1,*]=unit_coal_2011
result[col*4+(year2-2011)+2,*]=unit_emis_2011
result[col*4+(year2-2011)+3,*]=unit_coal_2012
result[col*4+(year2-2011)+4,*]=unit_emis_2012
header_output[col*4+(year2-2011)+1]='2011_unit_coal'
header_output[col*4+(year2-2011)+2]='2011_unit_emis'
header_output[col*4+(year2-2011)+3]='2012_unit_coal'
header_output[col*4+(year2-2011)+4]='2012_unit_emis'

outfile ='/home/liufei/Data/High_resolution/map_city_info.asc'
openw,lun,outfile,/get_lun,WIDTH=2500
printf,lun,header_output,result
close,lun
free_lun,lun

end
