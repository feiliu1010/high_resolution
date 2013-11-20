pro calculate_emission

InType  = CTM_Type( 'GEOS5', res=[2d0/3d0,0.5d0])
InGrid  = CTM_Grid( InType, /No_Vertical )


;get base emission
a=fltarr(InGrid.IMX,InGrid.JMX)
nod=fltarr(InGrid.IMX,InGrid.JMX)

for year = 2010,2010 do begin
for month = 1,5 do begin
Yr4 = string(year,format='(i4.4)')
Mon2 = string(month,format='(i2.2)')

emisfile = '/home/gengguannan/work/MEP/factor/emis.'+Yr4+Mon2+'.save'

restore,emisfile
help, emis_total


for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin
    if (emis_total[I,J] gt 0) then $
        a[I,J] += emis_total[I,J]
  endfor
endfor


endfor
endfor


; emission changes
betafile = '/home/gengguannan/work/MEP/met/beta.no2.13_15.up15pct.5m.avg.anth.05x0666.bpch'

ctm_get_data,datainfo,filename = betafile
data18=*(datainfo[0].data)

no2file = '/home/gengguannan/work/MEP/met/2013_Ratio2012_JantoMay_OMI_nomet_0.66x0.50.nc'

ratio = fltarr(InGrid.IMX,InGrid.JMX)
print,min(ratio)


fid1 = ncdf_open(no2file)
dataid1 = ncdf_varid(fid1,'Ratio')
ncdf_varget,fid1,dataid1,ratio

change = fltarr(InGrid.IMX,InGrid.JMX)

for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin
    if data18[I,J] gt 0 and ratio[I,J] ne 0 then $
      change[I,J] = ratio[I,J] * data18[I,J]
  endfor
endfor


;get change emission
b = fltarr(InGrid.IMX,InGrid.JMX)

for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin
    if change[I,J] ne 0 then $
      b[I,J] = ( change[I,J] + 1) * a[I,J]
  endfor
endfor


;get province changes
province = ['Beijing','Tianjin','Hebei','Shanxi','Shandong','Jiangsu','Shanghai','Zhejiang','Henan','Anhui','Sichuan','Chongqing','Hubei','Hunan']

maskfile = '/home/gengguannan/indir/mask/Province_mask_0.66x0.50.nc'

for no = 0,n_elements(province)-1 do begin
;for no = 0,2 do begin

mask = fltarr(InGrid.IMX,InGrid.JMX)

fid1 = ncdf_open(maskfile)
dataid1 = ncdf_varid(fid1,province[no])
ncdf_varget,fid1,dataid1,mask

emis1 = 0
emis2 = 0
grid = 0


for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin
    if mask[I,J] gt 0 and b[I,J] gt 0 then begin
       emis1 += a[I,J]
       emis2 += b[I,J]
       grid += 1
    endif
  endfor
endfor


print,emis1,emis2
print,grid

endfor

end
