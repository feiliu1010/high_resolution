pro plot_1x1_diff_by_met

;InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.125d0, 0.125d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;limit=[15,70,55,136]
limit=[22,100,46,132]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 4.0

multipanel, omargin=[0.05,0.02,0.02,0.05]

;portrait
xmax = 8 
ymax = 12

xsize= 4
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0


Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/MEP/diff_by_met.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

maskfile = '/home/gengguannan/indir/mask/China_mask.geos5.v3.0125x0125'

ctm_get_data,datainfo,filename = maskfile
mask=*(datainfo[0].data)


;gc file
filename1 = '/home/gengguannan/work/MEP/met/2012_JantoMay_GC_0.66x0.50.bpch'
filename2 = '/home/gengguannan/work/MEP/met/2013_JantoMay_GC_0.66x0.50.bpch'

ctm_get_data,datainfo,filename = filename1
data18=*(datainfo[0].data)

ctm_get_data,datainfo,filename = filename2
data28=*(datainfo[0].data)


;omi file
;VC1 = fltarr(InGrid.IMX,InGrid.JMX)
;VC2 = fltarr(InGrid.IMX,InGrid.JMX)

;filename3 ='/home/gengguannan/work/MEP/met/2012_JantoMay_OMI_0.66x0.50.nc'
;filename4 ='/home/gengguannan/work/MEP/met/2013_JantoMay_OMI_0.66x0.50.nc'

;file_in1 = string(filename3)
;fid1=NCDF_OPEN(file_in1)
;VCDID1=NCDF_VARID(fid1,'TropVCD')
;NCDF_VARGET, fid1, VCDID1,VC1
;NCDF_CLOSE, fid1

;file_in2 = string(filename4)
;fid2=NCDF_OPEN(file_in2)
;VCDID2=NCDF_VARID(fid2,'TropVCD')
;NCDF_VARGET, fid2, VCDID2,VC2
;NCDF_CLOSE, fid2

filename3 ='/home/liufei/Data/Satellite/NO2/KNMI_L3/no2_2012_Jan2May_average.bpch'
filename4 ='/home/liufei/Data/Satellite/NO2/KNMI_L3/no2_2013_Jan2May_average.bpch'

ctm_get_data,datainfo,filename = filename3
VC1=*(datainfo[0].data)

ctm_get_data,datainfo,filename = filename4
VC2=*(datainfo[0].data)

;cal
mi1 = fltarr(InGrid.IMX,InGrid.JMX)
ra1 = fltarr(InGrid.IMX,InGrid.JMX)
mi2 = fltarr(InGrid.IMX,InGrid.JMX)
ra2 = fltarr(InGrid.IMX,InGrid.JMX)


for I = 0,InGrid.IMX-1L do begin
for J = 0,InGrid.JMX-1L do begin

;    if (data18[I,J] gt 0 and data28[I,J] gt 0) then begin
;        mi1[I,J] = data28[I,J] - data18[I,J]
;        ra1[I,J] = (data28[I,J] - data18[I,J])/data18[I,J] * 100
;    endif

    if (VC2[I,J] gt 0 and VC1[I,J] gt 0) then begin
        mi2[I,J] = VC2[I,J] - VC1[I,J]
        ra2[I,J] = (VC2[I,J] - VC1[I,J])/VC1[I,J] * 100
    endif

endfor
endfor


Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = -3
maxdata = 3

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818=mi2[I1:I2,J1:J2]
;data818=ra2[I1:I2,J1:J2] - ra1[I1:I2,J1:J2]

print,max(data818),min(data818)

;myct,/BuWhRd,ncolors=24
myct,25

tvmap,data818,                                          $   
limit=limit,					        $     
/nocbar,            			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='',  	                $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor


multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary


   Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.1, 0.10, 0.95, 0.12],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
      divisions = 7,                                            $
      c_colors=c_colors,C_levels=C_levels,			 $
      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=0.8
                   ;
   TopTitle = '10!U15!N molecules/cm!U2!N'
;   TopTitle = '%'                   
      XYOutS, 0.55, 0.03, TopTitle, $
      /Normal,                      $ ; Use normal coordinates
      Color=!MYCT.BLACK,            $ ; Set text color to black
      CharSize=0.8,                 $ ; Set text to twice normal size
      Align= 0.5                      ; Center text

   TopTitle = ''

      XYOutS, 0.5, 1.05,TopTitle,   $
      /Normal,                 	    $ ; Use normal coordinates
      Color=!MYCT.BLACK, 	    $ ; Set text color to black
      CharSize=1.4,  		    $ ; Set text to twice normal size
      Align=0.5    		      ; Center text

close_device

end
