pro bpch_to_asc

for year = 2011,2012 do begin

Yr4  = String( Year, format = '(i4.4)' )
infile='/home/liufei/Data/High_resolution/0.01degree/NO2/grid/0.1/nasa_v2_omi_annual_avg_no2_vcol_crd30_'+Yr4+'.01x01.bpch'
outfile = '/home/liufei/Data/High_resolution/0.01degree/NO2/grid/0.1/nasa_v2_omi_annual_avg_no2_vcol_crd30_'+Yr4+'.01x01.asc'

BPCH2ASCII,infile,outfile

endfor

end
