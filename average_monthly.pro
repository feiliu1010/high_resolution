pro average_monthly

limit = [15,70,55,150]

year_start = 2005
year_end   = 2012
month_start = 1
month_end = 12

Yr_start = string(year_start,format='(i4.4)')
Yr_end = string(year_end,format='(i4.4)')
Mon_start = string(month_start,format='(i2.2)')
Mon_end = string(month_end,format='(i2.2)')
;Month_tag = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']


InType   = CTM_Type( 'generic', Res=[0.01d0, 0.01d0], HalfPolar=0, Center180=0 )
InGrid   = CTM_Grid( InType, /No_Vertical )

xmid = InGrid.xmid
ymid = InGrid.ymid

dx = InType.Resolution[0]
dy = InType.Resolution[1]

radius_smooth = 12.0 ;the smoothing radius, unit in (km)
radius_smooth_str = strtrim(string(fix(radius_smooth)),2)
gsize = InType.Resolution[0]
gsize_str = strtrim(string(gsize,format='(f4.2)'),2)


i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

for year = year_start,year_end do begin
	Yr4 = string(year,format='(i4.4)')
	no2_domain_annual = fltarr(I2-I1+1L,J2-J1+1L)
        num_domain_annual = fltarr(I2-I1+1L,J2-J1+1L)
	for month = month_start,month_end do begin
		Mon2 = string(month,format='(i2.2)')
		no2_domain_monthly = fltarr(I2-I1+1L,J2-J1+1L)
		header=strarr(6,1)
		filename=file_search('/home/liufei/Data/High_resolution/0.01degree/NO2/monthly/'+Yr4+'_*'+'/no2_over_china_'+gsize_str+'deg_'+radius_smooth_str+'r_'+Yr4+Mon2+'_with_nasa_v2.asc')
		print,filename
		openr,lun,filename,/get_lun
		readf,lun,header,no2_domain_monthly
		close,lun
		Free_LUN,lun
		no2_domain_annual[where(no2_domain_monthly gt 0.)]+=no2_domain_monthly[where(no2_domain_monthly gt 0.)]
		num_domain_annual[where(no2_domain_monthly gt 0.)]+=1
	endfor;month
	no2_domain_annual[where(num_domain_annual gt 0.)]=no2_domain_annual[where(num_domain_annual gt 0.)]/num_domain_annual[where(num_domain_annual gt 0.)]

header_output = [['ncols 8000'],['nrows 4000'],['xllcorner 70'],['yllcorner 15'],['cellsize 0.01'],['nodata_value -999.0']]
outfile ='/home/liufei/Data/High_resolution/0.01degree/NO2/no2_over_china_12km_'+Yr4+'_with_nasa_v2.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output,no2_domain_annual
close,lun
free_lun,lun
endfor;year

end
