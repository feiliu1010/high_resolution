pro plot_bpch_asc

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

nlat = InGrid.JMX

close, /all

for year = 2011,2012 do begin
for month = 1,12 do begin

Yr4  = String( Year, format = '(i4.4)' )
no2 = dblarr(InGrid.IMX,InGrid.JMX)
Mon2 = String( month, format = '(i2.2)' )

;infile='/home/liufei/Data/High_resolution/0.01degree/NO2/grid/0.1/nasa_v2_omi_annual_avg_no2_vcol_crd30_'+Yr4+'.01x01.bpch'
infile='/z5/wangsiwen/Satellite/no2/NASA_v2_OMI_NO2_01x01_crd30/'+Yr4+'/'+Mon2+'/nasa_v2_omi_month_avg_no2_vcol_crd30_'+Yr4+Mon2+'.01x01.bpch'
CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, filename = infile
no2 =*(datainfo1[0].data)
help,no2
CTM_Cleanup

for j=1, nlat/2 do begin
tmp = no2[*,j-1]
no2[*,j-1] = no2[*,nlat-j]
no2[*,nlat-j] = tmp
endfor
undefine, tmp

header_output = [['ncols 3600'],['nrows 1800'],['xllcorner -180'],['yllcorner -90'],['cellsize 0.1'],['nodata_value -999.0']]
;outfile = '/home/liufei/Data/High_resolution/0.01degree/NO2/grid/0.1/nasa_v2_omi_annual_avg_no2_vcol_crd30_'+Yr4+'.01x01.asc'
outfile = '/home/liufei/Data/High_resolution/0.01degree/NO2/grid/0.1/nasa_v2_omi_annual_avg_no2_vcol_crd30_'+Yr4+Mon2+'.01x01.asc'
openw,lun,outfile,/get_lun
printf,lun,header_output,no2
close,lun
free_lun,lun

endfor
endfor

end



