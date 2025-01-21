; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  

begin

  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 120000000
  end setvalues

;-- Allows to write variables bigger than 2Gb
setfileoption("nc","Format","LargeFile") 

   hrr  = "17"

;---------------------------------------------
; Define netcdf output file
;---------------------------------------------
;--- Delete existent file and define fileout name
;    foutn = "WRFOUT_LAND1_1of2_Sep18_d03_"+hrr+"_SEvar.nc"
    foutn = "WRFOUT_COREA.nc"

    diro = ""
    system("rm "+diro+foutn)

;----Open wrfout file
    dir = "/glade/scratch/cuchiara/backup_Sep02_simulation_04202020/wrfouts/"

   filenameoff = "wrfchem_rst_noscav_d03_2013-09-02_18:15:00"
   filename = "wrfchem_rst_rfstd_d03_2013-09-02_18:15:00"
    aoff = addfile(dir+filenameoff, "r") 
    a = addfile(dir+filename, "r")

;---Define points to trim the file

;-CORE A
    str_i = 165
    end_i = 182
    str_j = 337
    end_j = 357;

     str_t = 3
     end_t = 10

print(":---------------------------------------------------------------:")
print("Importing variables from file:"+filenameoff+" it may take a while!!!")
print(":---------------------------------------------------------------:") 

;---Read in data

    times = a->Times(str_t:end_t,:)
    lat =a->XLAT(str_t:end_t,str_i:end_i,str_j:end_j)
    lat@units = "south_north"
 
    lon =a->XLONG(str_t:end_t,str_i:end_i,str_j:end_j)
    lon@units = "west_east"

 ;   Ta =a->HGT(str_t:end_t,str_i:end_i,str_j:end_j) ;TIP: Always output HGT to check projection

    ph  =a->PH(str_t:end_t,:,str_i:end_i,str_j:end_j)
    phb  =a->PHB(str_t:end_t,:,str_i:end_i,str_j:end_j);
    pb  =a->PB(str_t:end_t,:,str_i:end_i,str_j:end_j)
    p  =a->P(str_t:end_t,:,str_i:end_i,str_j:end_j)
    REFL_10CM =a->REFL_10CM(str_t:end_t,:,str_i:end_i,str_j:end_j)

    W = wrf_user_getvar(a,"wa",-1)
    W := W(str_t:end_t,:,str_i:end_i,str_j:end_j)
    z = wrf_user_getvar(a,"z",-1)
    z := z(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tk = wrf_user_getvar(a,"T",-1)-273.15
    tk := tk(str_t:end_t,:,str_i:end_i,str_j:end_j)

    qc = a->QCLOUD(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qr = a->QRAIN(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qi = a->QICE(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qs = a->QSNOW(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qg = a->QGRAUP(str_t:end_t,:,str_i:end_i,str_j:end_j)
    EVAPPROD = a->EVAPPROD(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    RAINPROD = a->RAINPROD(str_t:end_t,:,str_i:end_i,str_j:end_j)        

    o3 =  a->o3(str_t:end_t,:,str_i:end_i,str_j:end_j)
    no =  a->no(str_t:end_t,:,str_i:end_i,str_j:end_j)
    no2=  a->no2(str_t:end_t,:,str_i:end_i,str_j:end_j)
    co=   a->co(str_t:end_t,:,str_i:end_i,str_j:end_j)
    hcho= a->hcho(str_t:end_t,:,str_i:end_i,str_j:end_j)
    h2o2= a->h2o2(str_t:end_t,:,str_i:end_i,str_j:end_j)
    ch3ooh= a->ch3ooh(str_t:end_t,:,str_i:end_i,str_j:end_j)

    hcho_off= aoff->hcho(str_t:end_t,:,str_i:end_i,str_j:end_j)
    h2o2_off= aoff->h2o2(str_t:end_t,:,str_i:end_i,str_j:end_j)
    ch3ooh_off= aoff->ch3ooh(str_t:end_t,:,str_i:end_i,str_j:end_j)

;---------------------------------------------
;   derived variables
;---------------------------------------------

    hcho_se = 100 * ((hcho_off - hcho)/hcho_off)
    h2o2_se = 100 * ((h2o2_off - h2o2)/h2o2_off)
    ch3ooh_se = 100 * ((ch3ooh_off - ch3ooh)/ch3ooh_off)

    qtot = ( qc + qr + qi + qs + qg)
;    new_time = wrf_times_c(times,3)

;;;;;;-------;;;;;
  REFL_10CM!0   ="Time"
  REFL_10CM!1   ="bottom_top"
  REFL_10CM!2   ="south_north"
  REFL_10CM!3   = "west_east"
  REFL_10CM@coordinates = "XLAT XLONG" 
  REFL_10CM&south_north = lat(0,:,0)
  REFL_10CM&west_east = lon(0,0,:)
  REFL_10CM@_FillValue = -9999.


;;;;;;-------;;;;;
  z!0   ="Time"
  z!1   ="bottom_top"
  z!2   ="south_north"
  z!3   = "west_east"
;  z&south_north = lat(0,:,0)
;  z&west_east = lon(0,0,:)
  z@_FillValue = -9999.
  z@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  qc!0   ="Time"
  qc!1   ="bottom_top"
  qc!2   ="south_north"
  qc!3   = "west_east"
  qc&south_north = lat(0,:,0)
  qc&west_east = lon(0,0,:)
  qc@_FillValue = -9999.
  qc@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  qr!0   ="Time"
  qr!1   ="bottom_top"
  qr!2   ="south_north"
  qr!3   = "west_east"
  qr&south_north = lat(0,:,0)
  qr&west_east = lon(0,0,:)
  qr@_FillValue = -9999.
  qr@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  qi!0   ="Time"
  qi!1   ="bottom_top"
  qi!2   ="south_north"
  qi!3   = "west_east"
  qi&south_north = lat(0,:,0)
  qi&west_east = lon(0,0,:)
  qi@_FillValue = -9999.
  qi@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  qs!0   ="Time"
  qs!1   ="bottom_top"
  qs!2   ="south_north"
  qs!3   = "west_east"
  qs&south_north = lat(0,:,0)
  qs&west_east = lon(0,0,:)
  qs@_FillValue = -9999.
  qs@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  qg!0   ="Time"
  qg!1   ="bottom_top"
  qg!2   ="south_north"
  qg!3   = "west_east"
  qg&south_north = lat(0,:,0)
  qg&west_east = lon(0,0,:)
  qg@_FillValue = -9999.
  qg@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  qtot!0   ="Time"
  qtot!1   ="bottom_top"
  qtot!2   ="south_north"
  qtot!3   = "west_east"
  qtot&south_north = lat(0,:,0)
  qtot&west_east = lon(0,0,:)
  qtot@_FillValue = -9999.
  qtot@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  tk!0   ="Time"
  tk!1   ="bottom_top"
  tk!2   ="south_north"
  tk!3   = "west_east"
  tk&south_north = lat(0,:,0)
  tk&west_east = lon(0,0,:)
  tk@_FillValue = -9999.
  tk@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  p!0   ="Time"
  p!1   ="bottom_top"
  p!2   ="south_north"
  p!3   = "west_east"
  p&south_north = lat(0,:,0)
  p&west_east = lon(0,0,:)
  p@_FillValue = -9999.
  p@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  ph!0   ="Time"
  ph!1   ="bottom_top"
  ph!2   ="south_north"
  ph!3   = "west_east"
  ph&south_north = lat(0,:,0)
  ph&west_east = lon(0,0,:)
  ph@_FillValue = -9999.
  ph@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  phb!0   ="Time"
  phb!1   ="bottom_top"
  phb!2   ="south_north"
  phb!3   = "west_east"
  phb&south_north = lat(0,:,0)
  phb&west_east = lon(0,0,:)
  phb@_FillValue = -9999.
  phb@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  pb!0   ="Time"
  pb!1   ="bottom_top"
  pb!2   ="south_north"
  pb!3   = "west_east"
  pb&south_north = lat(0,:,0)
  pb&west_east = lon(0,0,:)
  pb@_FillValue = -9999.
  pb@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  RAINPROD!0   ="Time"
  RAINPROD!1   ="bottom_top"
  RAINPROD!2   ="south_north"
  RAINPROD!3   = "west_east"
  RAINPROD&south_north = lat(0,:,0)
  RAINPROD&west_east = lon(0,0,:)
  RAINPROD@_FillValue = -9999.
  RAINPROD@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  EVAPPROD!0   ="Time"
  EVAPPROD!1   ="bottom_top"
  EVAPPROD!2   ="south_north"
  EVAPPROD!3   = "west_east"
  EVAPPROD&south_north = lat(0,:,0)
  EVAPPROD&west_east = lon(0,0,:)
  EVAPPROD@_FillValue = -9999.
  EVAPPROD@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  o3!0   ="Time"
  o3!1   ="bottom_top"
  o3!2   ="south_north"
  o3!3   = "west_east"
  o3&south_north = lat(0,:,0)
  o3&west_east = lon(0,0,:)
  o3@_FillValue = -9999.
  o3@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  no!0   ="Time"
  no!1   ="bottom_top"
  no!2   ="south_north"
  no!3   = "west_east"
  no&south_north = lat(0,:,0)
  no&west_east = lon(0,0,:)
  no@_FillValue = -9999.
  no@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  no2!0   ="Time"
  no2!1   ="bottom_top"
  no2!2   ="south_north"
  no2!3   = "west_east"
  no2&south_north = lat(0,:,0)
  no2&west_east = lon(0,0,:)
  no2@_FillValue = -9999.
  no2@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  co!0   ="Time"
  co!1   ="bottom_top"
  co!2   ="south_north"
  co!3   = "west_east"
  co&south_north = lat(0,:,0)
  co&west_east = lon(0,0,:)
  co@_FillValue = -9999.
  co@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  hcho!0   ="Time"
  hcho!1   ="bottom_top"
  hcho!2   ="south_north"
  hcho!3   = "west_east"
  hcho&south_north = lat(0,:,0)
  hcho&west_east = lon(0,0,:)
  hcho@_FillValue = -9999.
  hcho@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  h2o2!0   ="Time"
  h2o2!1   ="bottom_top"
  h2o2!2   ="south_north"
  h2o2!3   = "west_east"
  h2o2&south_north = lat(0,:,0)
  h2o2&west_east = lon(0,0,:)
  h2o2@_FillValue = -9999.
  h2o2@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  ch3ooh!0   ="Time"
  ch3ooh!1   ="bottom_top"
  ch3ooh!2   ="south_north"
  ch3ooh!3   = "west_east"
  ch3ooh&south_north = lat(0,:,0)
  ch3ooh&west_east = lon(0,0,:)
  ch3ooh@_FillValue = -9999.
  ch3ooh@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  hcho_off!0   ="Time"
  hcho_off!1   ="bottom_top"
  hcho_off!2   ="south_north"
  hcho_off!3   = "west_east"
  hcho_off&south_north = lat(0,:,0)
  hcho_off&west_east = lon(0,0,:)
  hcho_off@_FillValue = -9999.
  hcho_off@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  h2o2_off!0   ="Time"
  h2o2_off!1   ="bottom_top"
  h2o2_off!2   ="south_north"
  h2o2_off!3   = "west_east"
  h2o2_off&south_north = lat(0,:,0)
  h2o2_off&west_east = lon(0,0,:)
  h2o2_off@_FillValue = -9999.
  h2o2_off@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  ch3ooh_off!0   ="Time"
  ch3ooh_off!1   ="bottom_top"
  ch3ooh_off!2   ="south_north"
  ch3ooh_off!3   = "west_east"
  ch3ooh_off&south_north = lat(0,:,0)
  ch3ooh_off&west_east = lon(0,0,:)
  ch3ooh_off@_FillValue = -9999.
  ch3ooh_off@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  hcho_se!0   ="Time"
  hcho_se!1   ="bottom_top"
  hcho_se!2   ="south_north"
  hcho_se!3   = "west_east"
  hcho_se&south_north = lat(0,:,0)
  hcho_se&west_east = lon(0,0,:)
  hcho_se@_FillValue = -9999.
  hcho_se@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  h2o2_se!0   ="Time"
  h2o2_se!1   ="bottom_top"
  h2o2_se!2   ="south_north"
  h2o2_se!3   = "west_east"
  h2o2_se&south_north = lat(0,:,0)
  h2o2_se&west_east = lon(0,0,:)
  h2o2_se@_FillValue = -9999.
  h2o2_se@coordinates = "XLAT XLONG" 

;;;;;;-------;;;;;
  ch3ooh_se!0   ="Time"
  ch3ooh_se!1   ="bottom_top"
  ch3ooh_se!2   ="south_north"
  ch3ooh_se!3   = "west_east"
  ch3ooh_se&south_north = lat(0,:,0)
  ch3ooh_se&west_east = lon(0,0,:)
  ch3ooh_se@_FillValue = -9999.
  ch3ooh_se@coordinates = "XLAT XLONG" 

;---------------------------------------------
; Create netCDF file
;---------------------------------------------

    fout = addfile (diro+foutn,"c")

;===================================================================
; explicitly declare file definition mode. Improve efficiency.
;===================================================================
        setfileoption(fout,"DefineMode",True)

;--- Copy all global attributes from WRFout to new file

;    fileattdef( fout, in )

    globalAtt = True
    globalAtt@title         = "netCDF Created by G.C.Cuchiara"  
;    globalAtt@source_file   =  tostring(inf)
    globalAtt@Conventions   = "None"
    globalAtt@creation_date = systemfunc ("date")
    globalAtt@MAP_PROJ_CHAR = "CylindricalEquidistant"
    fileattdef( fout, globalAtt )
;===================================================================
; predefine the coordinate variables and their dimensionality
; Note: to get an UNLIMITED record dimension, we set the dimensionality
; to -1 (or the actual size) and set the dimension name to True.
;===================================================================

        ntim  = dimsizes(times)                 ; get dimension sizes  
	ndept  = dimsizes(z(0,:,0,0))        
	nlat  = dimsizes(lat(0,:,0))  
	nlon  = dimsizes(lon(0,0,:))      

        dimNames = (/"Time", "bottom_top", "south_north", "west_east"/)  
	dimSizes = (/ -1   ,  ndept, nlat,  nlon/) 
	dimUnlim = (/ True , False, False, False/)   
	filedimdef(fout,dimNames,dimSizes,dimUnlim)

;----------------------------------------------------------------------
; allocate selected variables in the new file
;---------------------------------------------------------------------

print(":---------------------------------------------------------------:")
print("Creating variables in the new file: "+foutn)
print(":---------------------------------------------------------------:")


;===================================================================
; predefine the the dimensionality of the variables to be written out
;===================================================================
; Here we are using NCL functions to facilitate defining 
; each variable's dimension name(s) and type. 
; The following could be replaced with explicit, user defined dimension 
; names different from those associated with the variable in memory. 
; Say, PS(time,lat,lon) in the NCL script. They could be redefined for the file via: 
; filevardef(fout, "PS"   ,typeof(PS) ,(/"TIME","latitude","longitude"/)) 
;===================================================================
;       filevardef(fout, "times" ,typeof(times),getvardims(times)) 
;       filevardef(fout, "bottom_up" ,typeof(depth),getvardims(depth) )                           
       filevardef(fout, "XLAT"  ,typeof(lat),getvardims(lat))                          
       filevardef(fout, "XLONG"  ,typeof(lon),getvardims(lon))  

;       copy_VarMeta(water_temp,newwater_temp)
       filevardef(fout, "REFL_10CM" ,typeof(REFL_10CM) ,getvardims(REFL_10CM))    
       filevardef(fout, "z" ,typeof(z) ,getvardims(z))    
;       filevardef(fout, "tk" ,typeof(tk) ,getvardims(tk))
       filevardef(fout, "QCLOUD" ,typeof(qc) ,getvardims(qc))
       filevardef(fout, "QRAIN" ,typeof(qr) ,getvardims(qr))        
       filevardef(fout, "QSNOW" ,typeof(qs) ,getvardims(qs))
       filevardef(fout, "QGRAUPEL" ,typeof(qg) ,getvardims(qg))
       filevardef(fout, "QICE" ,typeof(qi) ,getvardims(qi))
       filevardef(fout, "EVAPPROD" ,typeof(EVAPPROD) ,getvardims(EVAPPROD))
       filevardef(fout, "RAINPROD" ,typeof(RAINPROD) ,getvardims(RAINPROD))
       filevardef(fout, "QTOT" ,typeof(qtot) ,getvardims(qtot))
       filevardef(fout, "o3" ,typeof(o3) ,getvardims(o3))
       filevardef(fout, "no" ,typeof(no) ,getvardims(no))
       filevardef(fout, "no2" ,typeof(no2) ,getvardims(no2))
       filevardef(fout, "co" ,typeof(co) ,getvardims(co))
       filevardef(fout, "hcho" ,typeof(hcho) ,getvardims(hcho))
       filevardef(fout, "h2o2" ,typeof(h2o2) ,getvardims(h2o2))
       filevardef(fout, "ch3ooh" ,typeof(ch3ooh) ,getvardims(ch3ooh))
       filevardef(fout, "hcho_off" ,typeof(hcho_off) ,getvardims(hcho_off))
       filevardef(fout, "h2o2_off" ,typeof(h2o2_off) ,getvardims(h2o2_off))
       filevardef(fout, "ch3ooh_off" ,typeof(ch3ooh_off) ,getvardims(ch3ooh_off))
       filevardef(fout, "hcho_se" ,typeof(hcho_se) ,getvardims(hcho_se))
       filevardef(fout, "h2o2_se" ,typeof(h2o2_se) ,getvardims(h2o2_se))
       filevardef(fout, "ch3ooh_se" ,typeof(ch3ooh_se) ,getvardims(ch3ooh_se))
;       filevardef(fout, "PHB",typeof(phb),getvardims(phb))
;       filevardef(fout, "PH",typeof(ph),getvardims(ph))
;;       filevardef(fout, "PB",typeof(pb),getvardims(pb))
;       filevardef(fout, "P",typeof(p),getvardims(p))
;===================================================================
; Copy attributes associated with each variable to the file
; All attributes associated with each variable will be copied.
 ;====================================================================

       filevarattdef(fout,"times" ,times)                    ; copy time attributes
;       filevarattdef(fout,"depth",depth)                     ; copy lev attributes
       filevarattdef(fout,"XLAT"  ,lat)                     ; copy lat attributes
       filevarattdef(fout,"XLONG"  ,lon)                     ; copy lon attributes
 
       filevarattdef(fout,"REFL_10CM"   ,REFL_10CM)                      ; copy PS attributes
       filevarattdef(fout,"z" , z)
;       filevarattdef(fout,"tk", tk)

       filevarattdef(fout,"QCLOUD",qc)
       filevarattdef(fout,"QRAIN",qr)
       filevarattdef(fout,"QICE",qi)
       filevarattdef(fout,"QSNOW",qs)
       filevarattdef(fout,"QGRAUPEL",qg)
       filevarattdef(fout,"QTOT",qtot)
       filevarattdef(fout,"EVAPPROD", EVAPPROD)
       filevarattdef(fout,"RAINPROD", RAINPROD)
       filevarattdef(fout,"o3",o3)
       filevarattdef(fout,"no",no)
       filevarattdef(fout,"no2",no2)
       filevarattdef(fout,"co",co)
       filevarattdef(fout,"hcho",hcho)
       filevarattdef(fout,"h2o2",h2o2)
       filevarattdef(fout,"ch3ooh",ch3ooh)
       filevarattdef(fout,"hcho_off",hcho)
       filevarattdef(fout,"h2o2_off",h2o2)
       filevarattdef(fout,"ch3ooh_off",ch3ooh)
       filevarattdef(fout,"hcho_se",hcho)
       filevarattdef(fout,"h2o2_se",h2o2)
       filevarattdef(fout,"ch3ooh_se",ch3ooh)
;       filevarattdef(fout,"PHB",phb)
;       filevarattdef(fout,"PH",ph)
;       filevarattdef(fout,"PB",pb)
;       filevarattdef(fout,"P",p)
;===================================================================
; output only the data values since the dimensionality and such have
; been predefined. The "(/", "/)" syntax tells NCL to only output the
; data values to the predefined locations on the file.
 ;====================================================================

     fout->times = (/times/)
;     fout->depth   = (/depth/)
     fout->XLAT  = lat
     fout->XLONG = lon

    fout->PHB   = (/phb/)
    fout->PB   = (/pb/)

    fout->P   = (/p/)
    fout->PH   = (/ph/)
    fout->tk   = (/tk/)
    fout->REFL_10CM = REFL_10CM
    
    fout->RAINPROD = (/RAINPROD/)
    fout->EVAPPROD = (/EVAPPROD/)

    fout->QCLOUD    = (/qc/)
    fout->QRAIN     = (/qr/)
    fout->QSNOW     = (/qs/)
    fout->QGRAUP    = (/qg/)
    fout->QICE      = (/qi/)

;    fout->QVAPOR    = (/QVAPOR/)

    fout->QTOT 	    = (/qtot/)
    fout->z 	    = (/z/)
    fout->o3 = o3
    fout->no = no
    fout->no2 = no2
    fout->co = co

    fout->hcho = hcho
    fout->h2o2 = h2o2
    fout->ch3ooh = ch3ooh

    fout->hcho_se = hcho_se
    fout->h2o2_se = h2o2_se
    fout->ch3ooh_se = ch3ooh_se

    fout->hcho_off = hcho_off
    fout->h2o2_off = h2o2_off
    fout->ch3ooh_off = ch3ooh_off

end
