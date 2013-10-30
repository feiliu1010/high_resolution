pro plot_save_asc

year=2012
Yr4 = string(year,format='(i4.4)')
month=01
Mon2 = string(month,format='(i2.2)')
nlat=4000

filename='/z5/wangsiwen/Satellite/no2/NASA_v2_OMI_NO2_001x001_crd30_10-50/'+Yr4+'/nasa_v2_omi_no2_vcol_crd30_10-50_'+Yr4+'_01_to_12_avg.001x001.save'
;filename='/z5/wangsiwen/Satellite/no2/NASA_v2_OMI_NO2_001x001_crd30_10-50/'+Yr4+'/nasa_v2_omi_month_avg_no2_vcol_crd30_10-50_'+Yr4+Mon2+'.001x001.save'
restore,file=filename
no2=OMI_FINAL
;no2=OMI_MONTH

for j=1, nlat/2 do begin
tmp = no2[*,j-1]
no2[*,j-1] = no2[*,nlat-j]
no2[*,nlat-j] = tmp
endfor
undefine, tmp

header_output = [['ncols 8000'],['nrows 4000'],['xllcorner 70'],['yllcorner 15'],['cellsize 0.01'],['nodata_value -999.0']]
outfile ='/home/liufei/Data/High_resolution/0.01degree/NO2/grid/no2_over_china_grid_'+Yr4+'_with_nasa_v2.asc'
;outfile ='/home/liufei/Data/High_resolution/0.01degree/NO2/grid/no2_over_china_grid_'+Yr4+Mon2+'_with_nasa_v2.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output,no2
close,lun
free_lun,lun

end


