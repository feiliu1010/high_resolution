pro china_analysis_no2_space_smoothing_method_nasa_v2_monthly

limit = [15,70,55,150]

year_start = 2005
year_end   = 2005
month_start = 11
month_end = 11

Yr_start = string(year_start,format='(i4.4)')
Yr_end = string(year_end,format='(i4.4)')
Mon_start = string(month_start,format='(i2.2)')
Mon_end = string(month_end,format='(i2.2)')
Month_tag = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']


InType   = CTM_Type( 'generic', Res=[0.01d0, 0.01d0], HalfPolar=0, Center180=0 )
InGrid   = CTM_Grid( InType, /No_Vertical )

xmid = InGrid.xmid
ymid = InGrid.ymid

dx = InType.Resolution[0]
dy = InType.Resolution[1]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


radius_smooth = 12.0 ;the smoothing radius, unit in (km)
radius_smooth_str = strtrim(string(fix(radius_smooth)),2)
gsize = InType.Resolution[0]
gsize_str = strtrim(string(gsize,format='(f4.2)'),2)

no2_domain_annual = fltarr(I2-I1+1L,J2-J1+1L)
num_domain_annual = fltarr(I2-I1+1L,J2-J1+1L)
;no2_domain_JJA = fltarr(I2-I1+1L,J2-J1+1L)
;num_domain_JJA = fltarr(I2-I1+1L,J2-J1+1L)
;no2_domain_310 = fltarr(I2-I1+1L,J2-J1+1L)
;num_domain_310 = fltarr(I2-I1+1L,J2-J1+1L)


for year = year_start,year_end do begin
Yr4 = string(year,format='(i4.4)')

for month = month_start,month_end do begin
Mon2 = string(month,format='(i2.2)')

dir_omi='/z5/wangsiwen/Satellite/no2/NASA_v2_OMI_NO2_asc_for_China_cf50/'+Yr4+'/'+Mon2+'/'
;dir_omi='/work/zhangq_work/wangsiwen/Satellite/NASA_v2_OMI_NO2_asc_for_China_cf50/'+Yr4+'/'+Mon2+'/'
spawn,'ls '+dir_omi+'OMI-Aura_L2-OMNO2_'+Yr4+'m'+Mon2+'*.asc ',list_omi

for k = 0L,n_elements(list_omi)-1L do begin
PRINT,'file: '+list_omi(k)
PRINT,strtrim((k+1),2)+' file(s) over '+strtrim(n_elements(list_omi),2)+' files to be processed'

; Define arrays to read in the data
ARRSIZE    = 50000L
sdate      = DblArr( ARRSIZE         )
spix       = DblArr( ARRSIZE         )
glat       = DblArr( ARRSIZE         )
glon       = DblArr( ARRSIZE         )
;rcf        = DblArr( ARRSIZE         )
fc         = DblArr( ARRSIZE         )
;cldpres    = DblArr( ARRSIZE         )
;thpres     = DblArr( ARRSIZE         )
sza        = DblArr( ARRSIZE         )
albedo     = DblArr( ARRSIZE         )
vcolno2    = DblArr( ARRSIZE         )
lat1	   = DblArr( ARRSIZE         )
lat2       = DblArr( ARRSIZE         )
lat3       = DblArr( ARRSIZE         )
lat4       = DblArr( ARRSIZE         )
lon1       = DblArr( ARRSIZE         )
lon2       = DblArr( ARRSIZE         )
lon3       = DblArr( ARRSIZE         )
lon4       = DblArr( ARRSIZE         )
n = 0L

flelen = strlen(list_omi[k])

date_YY = fix(strmid(list_omi[k], flelen-47, 4))
date_MM = fix(strmid(list_omi[k], flelen-42, 2))
date_DD = fix(strmid(list_omi[k], flelen-40, 2))

date_now = date_YY * 10000L + date_MM * 100L + date_DD * 1L
print,date_now

;Read NO2 files
result = fltarr(20)
openr,lun,list_omi(k),/GET_LUN

while ( not EOF( lun ) ) do begin

ReadF,lun,result

sdate[n]   = result[0]
spix[n]    = result[1]
glat[n]    = result[2]
glon[n]    = result[3]
vcolno2[n] = result[4]
sza[n]     = result[5]
lat1[n]	   =result[6]
lat2[n]    =result[7]
lat3[n]    =result[8]
lat4[n]    =result[9]
lon1[n]    =result[10]
lon2[n]    =result[11]
lon3[n]    =result[12]
lon4[n]    =result[13]
;rcf[n]     = result[14]
fc[n]      = result[15]
;cldpres[n] = result[16]
;thpres[n]  = result[17]
albedo[n]  = result[19]

n++
endwhile
;print,n

Close,    lun
Free_LUN, lun


;FILTERING (To customize)
ind_ok = where((sdate GT 0) AND (sza LT 70.) AND                            $
               (fc GE 0. AND fc LE 0.3) AND                                 $
               ;(glat GE limit[0]-0.15 AND glat LE limit[2]+0.15) AND        $
               ;(glon GE limit[1]-0.15 AND glon LE limit[3]+0.15) AND        $
               (albedo GE 0. AND albedo LT 0.3) AND                         $
               (vcolno2 GE 0.) AND                                          $
               (year LE 2008 AND spix GE 6. AND spix LE 55.) OR             $
               (year LE 2009 AND year GT 2008 AND spix GE 6. AND spix LE 26.) OR             $
		(year GE 2011 AND spix GE 6. AND spix LE 25.))


print,'available pixels in this file',n_elements(ind_ok)

if ind_ok(0) EQ -1 then continue

spix = spix(ind_ok)
glat = glat(ind_ok)
glon = glon(ind_ok)
vcolno2 = vcolno2(ind_ok)
lat1 = lat1(ind_ok)
lat2 = lat2(ind_ok)
lat3 = lat3(ind_ok)
lat4 = lat4(ind_ok)
lon1 = lon1(ind_ok)
lon2 = lon2(ind_ok)
lon3 = lon3(ind_ok)
lon4 = lon4(ind_ok)

for nn = 0L,n_elements(ind_ok)-1L do begin

    ;remove the row anomaly
    if (date_now GE 20070625L AND spix(nn) GE 54 AND spix(nn) LE 55) then continue
    if (date_now GE 20080511L AND spix(nn) GE 38 AND spix(nn) LE 45) then continue   
    if (date_now GE 20090124L AND spix(nn) GE 28 AND spix(nn) LE 45) then continue
    if (date_now GE 20110705L AND spix(nn) GE 43 AND spix(nn) LE 46) then continue
    if (date_now GE 20110801L AND spix(nn) GE 42 AND spix(nn) LE 46) then continue

    x1_index = where(xmid ge glon(nn)-0.2 and xmid le glon(nn)+0.2)
    y1_index = where(ymid ge glat(nn)-0.15 and ymid le glat(nn)+0.15)
    x1 = min(x1_index, max = x2)
    y1 = min(y1_index, max = y2)
    ;print, 'Grids around OMI pixel:  x1:x2',x1,x2, 'y1:y2',y1,y2

    for xx = 0L,x2-x1 do begin
      for yy = 0L,y2-y1 do begin

          if ( (xx+x1 lt I1) or (yy+y1 lt J1) or (xx+x1 gt I2) or (yy+y1 gt J2) ) then continue
	  l1=[lon1[nn],lat1[nn]]
	  l2=[lon2[nn],lat2[nn]]
	  l3=[lon3[nn],lat3[nn]]
	  l4=[lon4[nn],lat4[nn]]

          ll1=[lon2[nn],lat2[nn]]
          ll2=[lon3[nn],lat3[nn]]
          ll3=[lon4[nn],lat4[nn]]
          ll4=[lon1[nn],lat1[nn]]

	  temp1=pnt_line([xmid(xx+x1),ymid(yy+y1)],l1,ll1,p1)
          temp11=pnt_line([xmid(xx+x1),ymid(yy+y1)],l1,ll1,p11,/INTERVAL)
	  if temp1 lt temp11 then begin
		temp1=temp11
	  	if ((xmid(xx+x1)-lon1[nn])^2+(ymid(yy+y1)-lat1[nn])^2) le $
		   ((xmid(xx+x1)-lon2[nn])^2+(ymid(yy+y1)-lat2[nn])^2)	then begin
		   p1=l1
		endif else begin
		   p1=ll1
		endelse
	  endif
	  temp2=pnt_line([xmid(xx+x1),ymid(yy+y1)],l2,ll2,p2)
	  temp22=pnt_line([xmid(xx+x1),ymid(yy+y1)],l2,ll2,p2,/INTERVAL)
	  if temp2 lt temp22 then begin
                temp2=temp22
                if ((xmid(xx+x1)-lon2[nn])^2+(ymid(yy+y1)-lat2[nn])^2) le $
                   ((xmid(xx+x1)-lon3[nn])^2+(ymid(yy+y1)-lat3[nn])^2) then begin
                   p2=l2
                endif else begin
                   p2=ll2
                endelse
          endif
	  temp3=pnt_line([xmid(xx+x1),ymid(yy+y1)],l3,ll3,p3)
	  temp33=pnt_line([xmid(xx+x1),ymid(yy+y1)],l3,ll3,p3,/INTERVAL)
	  if temp3 lt temp33 then begin
                temp3=temp33
                if ((xmid(xx+x1)-lon3[nn])^2+(ymid(yy+y1)-lat3[nn])^2) le $
                   ((xmid(xx+x1)-lon4[nn])^2+(ymid(yy+y1)-lat4[nn])^2) then begin
                   p3=l3
                endif else begin
                   p3=ll3
                endelse
          endif
	  temp4=pnt_line([xmid(xx+x1),ymid(yy+y1)],l4,ll4,p4)
	  temp44=pnt_line([xmid(xx+x1),ymid(yy+y1)],l4,ll4,p4,/INTERVAL)
	  if temp4 lt temp44 then begin
                temp4=temp44
                if ((xmid(xx+x1)-lon4[nn])^2+(ymid(yy+y1)-lat4[nn])^2) le $
                   ((xmid(xx+x1)-lon1[nn])^2+(ymid(yy+y1)-lat1[nn])^2) then begin
                   p4=l4
                endif else begin
                   p4=ll4
                endelse
          endif

	  
	  line_distance=[temp1,temp2,temp3,temp4]
	  temp5=min(line_distance,Min_Subscript)
	  loc=Min_Subscript[0]
	  point=dblarr(2,4)
	  point=[[p1],[p2],[p3],[p4]]
	  p_x=point[0,loc]
	  p_y=point[1,loc]
	  
	  distance=map_2points(p_x,p_y,xmid(xx+x1),ymid(yy+y1),/meters)
	  distance = distance/1000.
          ;print,xmid(xx+x1),ymid(yy+y1),glon(nn),glat(nn)

          if (distance LE radius_smooth) then begin
              no2_domain_annual(xx+x1-I1,yy+y1-J1) += vcolno2(nn)
              num_domain_annual(xx+x1-I1,yy+y1-J1) += 1L

             ;if (month ge 6 and month le 8) then begin
             ;     no2_domain_JJA(xx+x1-I1,yy+y1-J1) += vcolno2(nn)
             ;     num_domain_JJA(xx+x1-I1,yy+y1-J1) += 1L
             ; endif

             ; if (month ge 3 and month le 10) then begin
             ;     no2_domain_310(xx+x1-I1,yy+y1-J1) += vcolno2(nn)
             ;     num_domain_310(xx+x1-I1,yy+y1-J1) += 1L
             ; endif

          endif

      endfor
    endfor          

endfor

print,'total samples used in the domain:',total(num_domain_annual)

endfor ;loop over files

ind_final = where(num_domain_annual GT 0)
if ind_final[0] NE -1 then begin
   no2_domain_annual(ind_final) = no2_domain_annual(ind_final)/num_domain_annual(ind_final)
endif

;if ind_final[0] NE -1 then begin
;   no2_domain_JJA(ind_final) = no2_domain_JJA(ind_final)/num_domain_JJA(ind_final)
;endif

;ind_final = where(num_domain_310 GT 0)
;if ind_final[0] NE -1 then begin
;   no2_domain_310(ind_final) = no2_domain_310(ind_final)/num_domain_310(ind_final)
;endif


;reverse
nlat_g=J2-J1+1L
for j=1, nlat_g/2 do begin
        tmp = no2_domain_annual[*,j-1]
        no2_domain_annual[*,j-1] = no2_domain_annual[*,nlat_g-j]
        no2_domain_annual[*,nlat_g-j] = tmp
endfor
undefine, tmp


header_output = [['ncols 8000'],['nrows 4000'],['xllcorner 70'],['yllcorner 15'],['cellsize 0.01'],['nodata_value -999.0']]
outfile ='/home/liufei/Data/High_resolution/0.01degree/NO2/monthly/no2_over_china_'+gsize_str+'deg_'+radius_smooth_str+'r_'+Yr4+Mon2+'_with_nasa_v2.asc'
;outfile ='/work/zhangq_work/liufei/NO2/0.1deg_monthly/no2_over_china_'+gsize_str+'deg_'+radius_smooth_str+'r_'+Yr4+Mon2+'_with_nasa_v2.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output,no2_domain_annual
close,lun
free_lun,lun

outfile ='/home/liufei/Data/High_resolution/0.01degree/NO2/monthly/no2_over_china_'+gsize_str+'deg_'+radius_smooth_str+'r_'+Yr4+Mon2+'_with_nasa_v2_num.asc'
;outfile ='/work/zhangq_work/liufei/NO2/0.1deg_monthly/no2_over_china_'+gsize_str+'deg_'+radius_smooth_str+'r_'+Yr4+Mon2+'_with_nasa_v2_num.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output,num_domain_annual
close,lun
free_lun,lun

endfor ;loop over month
endfor ;loop over year
end
