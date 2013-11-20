pro plot_1x1

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


limit=[15,70,55,136]

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

Year = 2010
Month = 1
NYMD0 = Year * 10000L + Month * 100L + 1L

Yr4 = string(Year,format='(i4.4)')
Mon2 = String( Month, Format = '(i2.2)' )

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/MEP/emission_change.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

filename = '/home/gengguannan/work/MEP/factor/beta.no2.13_15.up15pct.halfyear.avg.anth.05x0666.bpch'

ctm_get_data,datainfo,filename = filename
data18=*(datainfo[0].data)

no2file = '/home/gengguannan/work/MEP/2013_Ratio2012_JantoJun_OMI_0.66x0.50.nc'

ratio = fltarr(InGrid.IMX,InGrid.JMX)

fid1 = ncdf_open(no2file)
dataid1 = ncdf_varid(fid1,'Ratio')
ncdf_varget,fid1,dataid1,ratio


Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = -20
maxdata = 20

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

change = fltarr(InGrid.IMX,InGrid.JMX)

for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin
    if data18[I,J] gt 0 and ratio[I,J] ne 0 then $
      change[I,J] = data18[I,J] * ratio[I,J]
  endfor
endfor

data828=change[I1:I2,J1:J2] * 100

print,max(data828),min(data828)

Myct,22

tvmap,data828,                                          $   
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
title='emission changes (%)',  	                $
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
      divisions = 11,                                            $
      c_colors=c_colors,C_levels=C_levels,			 $
      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=0.8
                   ;
   TopTitle = ''
                   
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
