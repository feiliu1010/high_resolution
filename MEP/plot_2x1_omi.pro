pro plot_2x1_omi

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 2, row = 1

;portrait
xmax = 8 
ymax = 12

xsize= 8
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Season ='JantoMay'

inputyear=2012
inputyear1=inputyear+1
Yr4  = String(inputyear, format = '(i4.4)' )
Yr41  = String(inputyear1, format = '(i4.4)' )


Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/MEP/compare_OMI_'+Yr4+'_'+Yr41+'_'+Season+'_05X0666.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

VC1 = fltarr(InGrid.IMX,InGrid.JMX)
VC2 = fltarr(InGrid.IMX,InGrid.JMX)

filename1 = '/home/gengguannan/work/MEP/met/'+Yr4+'_'+Season +'_OMI_0.66x0.50.nc'
filename2 = '/home/gengguannan/work/MEP/met/'+Yr41+'_'+Season +'_OMI_0.66x0.50.nc'

file_in1 = string(filename1)
fid1=NCDF_OPEN(file_in1)
VCDID1=NCDF_VARID(fid1,'TropVCD')
NCDF_VARGET, fid1, VCDID1,VC1
NCDF_CLOSE, fid1

file_in2 = string(filename2)
fid2=NCDF_OPEN(file_in2)
VCDID2=NCDF_VARID(fid2,'TropVCD')
NCDF_VARGET, fid2, VCDID2,VC2
NCDF_CLOSE, fid2

mi = fltarr(InGrid.IMX,InGrid.JMX)
ra = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1L do begin
for J = 0,InGrid.JMX-1L do begin

    if (VC2[I,J] gt 0 and VC1[I,J] gt 0) then begin
        mi[I,J] = VC2[I,J] - VC1[I,J]
        ra[I,J] = (VC2[I,J] - VC1[I,J])/VC1[I,J] * 100
    endif

endfor
endfor



Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = -5
maxdata = 5

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = mi[I1:I2,J1:J2]
data828 = ra[I1:I2,J1:J2]
print,max(data818),max(data828)


Myct,22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,            			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
;/countries,/continents,/Coasts,    		        $
;/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='2013 - 2012',  	                        $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

tvmap,data828,                                          $
limit=limit,                                            $
/cbar,                                                $
mindata = -100,                                      $
maxdata = 100,                                      $
cbmin = -100, cbmax = 100,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition=[0.3 , 0.03, 1.7, 0.06 ],                    $
;/countries,/continents,/Coasts,                         $
;/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='( 2013 - 2012 ) / 2012',                             $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor


multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary


multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position2,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary



;   Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
;      Position=[ 0.15, 0.10, 0.85, 0.12],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
;      divisions = 11,                                            $
;      c_colors=c_colors,C_levels=C_levels,			 $
;      Min=0, Max=10, Unit='',format = '(f6.1)',charsize=0.8
                   ;
   TopTitle = '10!U15!N molecules/cm!U2!N'
                   
      XYOutS, 0.95, 0.07, TopTitle,                             $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=0.8,                                                $ ; Set text size to twice normal size
      Align= 0.5                                                    ; Center text

   TopTitle = '%'

      XYOutS, 0.5, 1.05,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.4,  				                 $ ; Set text size to twice normal size
      Align=0.5    				                   ; Center text

close_device

end
