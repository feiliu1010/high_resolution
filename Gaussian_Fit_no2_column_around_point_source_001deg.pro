pro Gaussian_Fit_no2_column_around_point_source_001deg


num=85
;num= 33
fit_result=dblarr(3,num)
Locate=dblarr(4,num)
filename = '/home/liufei/Data/High_resolution/City_distance_list.csv'
;filename = '/home/liufei/Data/High_resolution/PP_distance_list.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)
s=dblarr(num)
Dis=Locate[3,*]

date = '2011'

limit = [15,70,55,150]
nlon = 8000
nlat = 4000

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


ngrid = 600.0 ;the number of squares (i.e., grids) in each row/column of the domain
gsize = 0.01  ;the length and width of a single grid, unit in (km)

gsize_str = strtrim(string(gsize,format='(f4.2)'),2)
;domain_size_str = strtrim(string(ngrid * gsize,format='(f4.2)'),2)

filename = '/home/liufei/Data/High_resolution/0.01degree/NO2/no2_over_china_12km_'+date+'_with_nasa_v2.asc'
header = strarr(6,1)
omi_final=dblarr(nlon,nlat)
openr,lun,filename,/get_lun
readf,lun,header,omi_final
close,lun
Free_LUN,lun
;infile = '/z5/wangsiwen/Satellite/no2/NASA_v2_OMI_NO2_001x001_crd30_10-50/nasa_v2_omi_no2_vcol_crd30_10-50_'+date+'_avg.001x001.save'
;restore,infile

For num_i=0,num-1 do begin

center_x = xmid[I1:I2]
center_y = ymid[J1:J2]

junk = omi_final

site = strtrim(string(Locate[0,num_i]),2) 
lat  = Locate[2,num_i] 
lon  = Locate[1,num_i]

a1 = ngrid/2-Dis[num_i]*3*10 
a2 = ngrid/2+Dis[num_i]*3*10
b1 = ngrid/2-Dis[num_i]*3*10
b2 = ngrid/2+Dis[num_i]*3*10

lat_str = strtrim(string(lat),2)
lon_str = strtrim(string(lon),2)

x1_index = where(xmid gt lon-dx/2.0 and xmid le lon+dx/2.0)
y1_index = where(ymid gt lat-dy/2.0 and ymid le lat+dy/2.0)
x1 = min(x1_index, max = x2)
y1 = min(y1_index, max = y2)

limit_now = [(ymid(y1-ngrid/2)-dy/2),(xmid(x1-ngrid/2)-dx/2),(ymid(y1+ngrid/2-1)+dy/2),(xmid(x1+ngrid/2-1)+dx/2)]


junk = junk[(x1-I1-ngrid/2.0):(x1-I1+ngrid/2.0-1),(y1-J1-ngrid/2.0):(y1-J1+ngrid/2.0-1)]
center_x = center_x[(x1-I1-ngrid/2.0):(x1-I1+ngrid/2.0-1)]
center_y = center_y[(y1-J1-ngrid/2.0):(y1-J1+ngrid/2.0-1)]

no2_fit = junk[a1:a2,b1:b2]
center_x = center_x[a1:a2]
center_y = center_y[b1:b2]

dim=size(no2_fit)

kk = 0L

x_final = fltarr(dim[1])
y_final = fltarr(dim[2])

for xx = 0, dim[1]-1 do begin
    distan_x = map_2points(lon,lat,center_x(xx),lat,/meters)/1000.
    if lon gt center_x(xx) then distan_x = distan_x * (-1.0)
    x_final(xx) = distan_x
endfor

for yy = 0, dim[2]-1 do begin
    distan_y = map_2points(lon,lat,lon,center_y(yy),/meters)/1000.
    if lat gt center_y(yy) then distan_y = distan_y * (-1.0)
    y_final(yy) = distan_y
endfor

print,x_final(0),x_final(dim[1]-1),y_final(0),y_final(dim[2]-1)

result = GAUSS2DFIT(no2_fit,fit_p,x_final,y_final,/TILT)

print,site
print,fit_p
fit_result[0,num_i]=num_i+1
fit_result[1,num_i]=fit_p[0]
fit_result[2,num_i]=2*!PI*fit_p[1]*fit_p[2]*fit_p[3]
endfor

outfile ='/home/liufei/Data/High_resolution/City_fit.csv'
openw,lun,outfile,/get_lun
printf,lun,fit_result
close,lun
free_lun,lun

end
