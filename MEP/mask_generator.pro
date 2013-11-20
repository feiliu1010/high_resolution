pro mask_generator

;read shapefile
shapefile ='/home/gengguannan/code/MEP/China_Pro.shp'
oshp=OBJ_NEW('IDLffShape',shapefile)
oshp->getproperty,n_entities=n_ent,Attribute_info=attr_info,n_attributes=n_attr,Entity_type=ent_type
print,'n_entities',n_ent
print,'n_attributes',n_attr

;print Entity
;for i=0,n_ent-1 do begin
;	ent=oshp->getEntity(i)
;	vert=*(ent.vertices)
;endfor

;print Property
;For i=0,n_attr-1 Do Begin
;	PRINT, 'number: ',i
;	PRINT, 'name: ', attr_info[i].name
;	PRINT, 'type: ', attr_info[i].type
;endfor
print,'number 5, name: ', attr_info[5].name


;For i=0,n_ent-1 Do Begin
;	attr=oshp->GetAttributes(i)
;	For index=0, n_attr-1 Do Begin
;		PRINT,attr_info[index].name,' = ',attr.(index)
;	Endfor
;Endfor

FORWARD_FUNCTION CTM_Grid, CTM_Type

;InType = CTM_Type( 'generic', Res=[ 2d0/3d0, 0.5d0], Halfpolar=0, Center180=0)
InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )
inxmid = InGrid.xmid
inymid = InGrid.ymid
close, /all

flag = 0
For J=0,InGrid.JMX-1 do begin 
For I=0,InGrid.IMX-1 do begin
    if  flag then begin
	x = [[x],[InGrid.xmid[I],InGrid.ymid[J]]]
    endif else begin
	x = [InGrid.xmid[I],InGrid.ymid[J]]
	flag =1
    endelse
endfor
endfor
help,x

name = ['Beijing','Tianjin','Hebei','Shanxi','Shandong','Jiangsu','Shanghai','Zhejiang','Henan','Anhui','Sichuan','Chongqing','Hubei','Hunan']
pro_ADCODE99=[110000,120000,130000,140000,370000,320000,310000,330000,410000,340000,510000,500000,420000,430000]
final=fltarr(InGrid.IMX*InGrid.JMX,n_elements(name))
help,final

For num = 0, n_elements(name)-1 do begin

flag = 0
For i=0,n_ent-1 Do Begin
        attr=oshp->GetAttributes(i)
	;index=5 is ADCODE99
	index=5
	ADCODE= pro_ADCODE99[num]
	IF total(attr.(index) eq ADCODE) eq 1.0 then begin
	    ent=oshp->getEntity(i)
            vert=*(ent.vertices)
	    help,vert
	    Obj = OBJ_NEW('IDLanROI',vert)
	    temp = Obj->ContainsPoints(x)
	    if flag then begin
	        result += temp
	    endif else begin
		result = temp
		flag =1
	    endelse
	endif
endfor
help,Result

final[*,num]=Result
endfor

OBJ_DESTROY,oshp
OBJ_DESTROY,Obj


ID_list=lonarr(n_elements(name))
Out_nc_file='/home/gengguannan/indir/mask/Province_mask_0.66x0.50.nc'
FileId = NCDF_Create( Out_nc_file, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
For num = 0, n_elements(name)-1 do begin
	ID_list[num] = NCDF_VarDef( FileID, name[num],      [xID,yID], /Long )
endfor
NCDF_Attput, FileID, /Global, 'Title', 'province ID at 0.5*0.666: 0 is Exterior'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, LonID, InGrid.XMID ,   Count=[ InGrid.IMX ]
NCDF_VarPut, FileID, LatID, InGrid.YMID ,   Count=[ InGrid.JMX ]
For num = 0, n_elements(name)-1 do begin
	NCDF_VarPut, FileID,ID_list[num]  , final[*,num], Count=[ InGrid.IMX, InGrid.JMX ]
endfor
NCDF_Close, FileID


end
