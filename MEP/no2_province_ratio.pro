pro no2_province_ratio

FORWARD_FUNCTION CTM_Grid, CTM_Type
Season ='JantoMay'

inputyear=2012
inputyear1=inputyear+1
Yr4  = String(inputyear, format = '(i4.4)' )
Yr41  = String(inputyear1, format = '(i4.4)' )


InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

close, /all

VC1 = fltarr(InGrid.IMX,InGrid.JMX)
VC2 = fltarr(InGrid.IMX,InGrid.JMX)
day1= fltarr(InGrid.IMX,InGrid.JMX)
day2= fltarr(InGrid.IMX,InGrid.JMX)
sample1=fltarr(InGrid.IMX,InGrid.JMX)
sample2=fltarr(InGrid.IMX,InGrid.JMX)

filename1 ='/home/gengguannan/work/MEP/met/'+Yr4+'_'+Season +'_OMI_0.66x0.50.nc'
filename2 ='/home/gengguannan/work/MEP/met/'+Yr41+'_'+Season +'_OMI_0.66x0.50.nc'

file_in1 = string(filename1)
fid1=NCDF_OPEN(file_in1)
VCDID1=NCDF_VARID(fid1,'TropVCD')
NCDF_VARGET, fid1, VCDID1,VC1
dayid1=NCDF_VARID(fid1,'DayNumber')
NCDF_VARGET,fid1,dayid1,day1
Samid1=NCDF_VARID(fid1,'SampleNumber')
NCDF_VARGET,fid1,Samid1,sample1

NCDF_CLOSE, fid1

file_in2 = string(filename2)
fid2=NCDF_OPEN(file_in2)
VCDID2=NCDF_VARID(fid2,'TropVCD')
NCDF_VARGET, fid2, VCDID2,VC2
dayid2=NCDF_VARID(fid2,'DayNumber')
NCDF_VARGET,fid2,dayid2,day2
Samid2=NCDF_VARID(fid2,'SampleNumber')
NCDF_VARGET,fid2,Samid2,sample2

NCDF_CLOSE, fid2

name = ['Beijing','Tianjin','Hebei','Shanxi','Shandong','Jiangsu','Shanghai','Zhejiang','Henan','Anhui','Sichuan','Chongqing','Hubei','Hunan']
ID_list=lonarr(n_elements(name))
loc_list=fltarr(InGrid.IMX,InGrid.JMX,n_elements(name))
filename3 ='/home/gengguannan/indir/mask/Province_mask_0.66x0.50.nc'
file_in3 = string(filename3)
fid3=NCDF_OPEN(file_in3)
For num=0,n_elements(name)-1 do begin
	ID_list[num]=NCDF_VARID(fid3,name[num])
	temp2=fltarr(InGrid.IMX,InGrid.JMX)
	NCDF_VARGET, fid3,ID_list[num],temp2
	loc_list[*,*,num]=temp2
endfor
NCDF_CLOSE, fid3

a2012_list=fltarr(n_elements(name))
a2013_list=fltarr(n_elements(name))
dif_list=fltarr(n_elements(name))
a2012_day_list=lonarr(n_elements(name))
a2013_day_list=lonarr(n_elements(name))
a2012_sample_list=lonarr(n_elements(name))
a2013_sample_list=lonarr(n_elements(name))

For num=0,n_elements(name)-1 do begin
    loc_temp = fltarr(InGrid.IMX,InGrid.JMX)
    loc_temp = loc_list[*,*,num]
    temp = where( loc_temp gt 0 )
    a2012_list[num] = mean(VC1[temp])
    a2013_list[num] = mean(VC2[temp])
    dif_list[num]= (a2013_list[num] - a2012_list[num])/a2012_list[num]
    a2012_day_list[num] = mean(day1[temp])
    a2013_day_list[num] = mean(day2[temp])
    a2012_sample_list[num] = total(sample1[temp])
    a2013_sample_list[num] = total(sample2[temp])
endfor

dir='/home/gengguannan/work/MEP/'
outfile = dir +Yr41+'_Ratio'+Yr4+'_'+Season +'_province_OMI_0.66x0.50.asc'
openw, lun, Outfile ,/GET_LUN
printf, lun,['area','2012_NO2_column','2013_NO2_column','(2013-2012)/2012',$
	'2012_Day_number','2013_Day_number','2012_Sample_number','2013_Sample_number']
For num=0,n_elements(name)-1 do begin
	printf, lun,name[num],a2012_list[num],a2013_list[num],dif_list[num],$
		a2012_day_list[num],a2013_day_list[num],a2012_sample_list[num],a2013_sample_list[num]
endfor
close, lun
Free_LUN, lun

end
