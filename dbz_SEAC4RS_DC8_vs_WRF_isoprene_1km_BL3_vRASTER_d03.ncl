
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.


   load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
   load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/NCL_GETools.ncl"

begin
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--- Set some Basic Plot Information
svar = "isopr"
;  latmin = 31.90 ;32.48
;  latmax = 32.50 ;32.68
;  lonmin = -89.80;-90.30 
;  lonmax = -89.00;-90.06 

  day = 02
  month = 09
  year = 2013
  sthr = 20
  enhr = 20
  sminute = 15
  eminute = 15


  infls = (/22,12,00/) ; (/hh,mm,ss/)
  infle = (/22,25,00/) ; (/hh,mm,ss/)
  outfs = (/16,18,00/) ; (/hh,mm,ss/)
  outfe = (/16,18,29/) ; (/hh,mm,ss/)

  height = 400.  ; 800m Interpolate over height
 ino = 0
;--- END: Set some Basic Plot Information

;;;;;;;;;;;;;;;;;;;
 ;filename ="WRFV4_MOZACART_T1"     
      filename ="WRFCHEM_d03_v2"  
       a = addfile(filename, "r")
      times = wrf_user_getvar(a,"times",-1);   ; get times in the file
      ntimes = dimsizes(times)         ; number of times in the file
      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  latmin = 31.6;31.7;32.44
  latmax = 32.8;33.2;32.66
  lonmin = -89.50;360.-91.20;60.-90.260
  lonmax = -88.00;360.-89.40;.-90.050
  
  centerlon= (lonmin + lonmax)/2.

;---Open workstation --------------------;
wks = gsn_open_wks("X11","y_"+filename+"_"+svar+"_"+height)
  
  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 120000000
  end setvalues

;---Read terrain height and lat/lon off file.
  ;it        = 10     ; first time step
   it        = 99
  hgt       = wrf_user_getvar(a,svar,it)*1000; isoprene in ppbv
   hgt@lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude/longitude
  hgt@lon2d = wrf_user_getvar(a,"XLONG",it)  ; required for plotting

;  wks = gsn_open_wks("X11","f_gsn")

;---Set some basic plot options
  res               = True
  res@gsnMaximize   = True   ; maximize plot in frame
  res@tiMainString  = "WRF/Chem - isoprene at "+height+" (m) - "+infls(0)+":"+infls(1)+" to "+infle(0)+":"+infle(1)+" (UTC)"
  res@tiMainFontHeightF = 0.01
  res@cnFillOn      = True  
  res@cnLinesOn     = False
  res@mpProjection  = "CylindricalEquidistant"    ; The default
  res@mpDataBaseVersion = "MediumRes"
  res@gsnAddCyclic      = False

;---Zoom in on plot
 res@pmTickMarkDisplayMode = "Always"
 res@mpDataBaseVersion = "HighRes" 

 ;---Define contour levels
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0;0.0
  res@cnMaxLevelValF       = 4;4.0
  res@cnLevelSpacingF      = 0.44
;  res@cnFillMode    = "RasterFill"
   res@tmXTMode     = "Manual"
   res@tmXTValues   = (/269.62,269.66,269.70,269.74,269.78,269.82,269.86,269.90,269.94,269.98/)
   res@tmXTLabels   =(/"90.38W","90.44W","90.30W","90.26W","90.22W","90.18W","90.14W","90.10W","90.06W","90.02W"/)
   res@tmYRValues   =(/32.44,32.48,32.52,32.56,32.60,32.64,32.68/)
   res@tmYRLabels   =(/"32.46N","32.48N","32.52N","32.56N","32.60N","32.64N","32.68N"/)

  res@mpMinLatF     = latmin
  res@mpMaxLatF     = latmax
  res@mpMinLonF     = lonmin
  res@mpMaxLonF     = lonmax

  txres = True
  txres@txFontHeightF = 0.015
  txres@txFont        = 21

;------ Define new colormap 

;--Define plot settings

      gsres               = True
 ;    gsn_define_colormap(wks,"BlAqGrWh2YeOrReVi22")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
     colors = new( (/12/), integer)
;     do imkr = 0,9
;     colors(imkr) = 1 + (imkr*20)             ; 11, 31, 51, 71, 91, 111, 131, 151, 171, 191
;     end do
colors(0) = 0;5
     colors(1) = 33
     colors(2) = 49
     colors(3) = 65
     colors(4) = 97
     colors(5) = 113
     colors(6) = 145
     colors(7) = 161
     colors(8) = 177     
     colors(9) = 193
     colors(10) = 225
     colors(11) = 241


;-- Horizontally interpolate to height coordinates ("z")
  z = wrf_user_getvar(a,"z",it)
  refl =wrf_user_intrp3d(hgt,z,"h",height,0.,False)

;---Plot variable
  plot = gsn_csm_contour_map(wks,refl,res)
 
;;;;;;;;;;;;;;;;;
;Plot shape map ;
;;;;;;;;;;;;;;;;;

;---------Shape file - MS county
  dir       = "/glade/p/work/cuchiara/ncl_wks/flight_radar_winds/shp/"
  filenames = systemfunc("ls -1 " + dir + "*.shp")
  nfiles    = dimsizes(filenames)
  filename = dir + "USA_adm2.shp"

;---- shape resources
  res               = True
  res@gsnMaximize   = True
  res@gsnDraw       = False
  res@gsnFrame      = False

  res@mpFillOn          = False            ; Turn off map fill
  res@mpOutlineOn       = False            ; Turn off NCL's map outlines

  res@pmTickMarkDisplayMode = "Always"     ; Turn on fancier tickmark labels
delete(res)
;---Resource list for shapefile outlines
  lnres                  = True
  lnres@gsLineThicknessF = 0.4        ; Default is 1
  lnres@gsLineColor      = "Black"


;---Attach outlines from shapefile
  dum = gsn_add_shapefile_polylines(wks,plot,filename,lnres)
  delete(lnres)
;---------Shape file - MS county
  dir       = "/glade/p/work/cuchiara/ncl_wks/flight_radar_winds/shp/major_us_roads/"
  filename2 = dir + "tl_2016_us_primaryroads.shp"

;---- shape resources

  rdres                  = True
  rdres@gsLineThicknessF = 1.        ; Line Thickness
  rdres@gsLineColor      = "Grey"     ; Line Color
  rdres@gsLineDashPattern= 2

;---Attach outlines from shapefile
  dum1 = gsn_add_shapefile_polylines(wks,plot,filename2,rdres)
 delete(rdres)

draw(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get DC-8 Aircraft Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spcs = (/ "UTC", "GPS_LAT_MMS", "GPS_LON_MMS", "GPS_ALT_MMS", "CO_DACOM", "NO2_ESRL", "NO_ESRL", "Isoprene-Furan","CH2O_CAMS","H2O2_CIT","O3_ESRL", "U_MMS", "V_MMS","LWC_FCDP", "IWC_2DS" /)
vars = (/ "UTC", "GPS_LAT_MMS", "GPS_LON_MMS", "GPS_ALT_MMS", "CO_DACOM", "NO2_ESRL", "NO_ESRL", "Isoprene-Furan","CH2O_CAMS","H2O2_CIT","O3_ESRL", "U_MMS", "V_MMS","LWC_FCDP", "IWC_2DS" /)


;;;;;; define variable to plot  
  ivar = 6
  csp = spcs(ivar)
  var = vars(ivar)
  print(" variable:  "+var)

;--- define directory and name of the SEAC4RS merged file 
  obsdirname = "/glade/p/work/cuchiara/ncl_wks/NCL_TUTORIAL/"
  fnamedc8 = "dc8_vars.txt"
  dc8file = obsdirname+fnamedc8
  print("DC8 file:  "+dc8file)

;--- Read ICCART file
;    ictVar_DC8 = read_ict(obsdirname+fnamedc8)
   linen= 31571 ;Define the number of lines in the file
   coln = dimsizes(spcs)
   ictVar_DC8 = asciiread(dc8file,(/linen,coln/),"float")
   ictVar_DC8@_FillValue = -999.      ;Define _FillValue

;--- Read variables

    dc8_time_s = ictVar_DC8(:,0)      ; Time, s
    dc8_lat_s = ictVar_DC8(:,1)       ; GPS_LAT_MMS
    dc8_lon_s = ictVar_DC8(:,2)       ; GPS_LON_MMS
    dc8_galt_s = ictVar_DC8(:,3)      ; GPS_ALT_MMS
  ;  dc8_u = ictVar_DC8(:,4)         ; U_MMS
  ;  dc8_v = ictVar_DC8(:,5)         ; V_MMS
   ; dc8_no_s = ictVar_DC8(:,5)
   ; dc8_no2_s = ictVar_DC8(:,6)
    dc8_co_s = ictVar_DC8(:,7)
;--- scale the units
    dc8_var_s = dc8_co_s ;*dc8scl(ivar)

    tmn = floattointeger((dc8_time_s/3600. - floattointeger(dc8_time_s/3600.))*60)
    dc8_utc = floattointeger(dc8_time_s/3600.)*100 


;;;;;;;;;;;;;;;;;
; Plot var data ;
;;;;;;;;;;;;;;;;;
;--Define plot settings

      gsres               = True
 ;    gsn_define_colormap(wks,"BlAqGrWh2YeOrReVi22")
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
     colors = new( (/12/), integer)
;     do imkr = 0,9
;     colors(imkr) = 1 + (imkr*20)             ; 11, 31, 51, 71, 91, 111, 131, 151, 171, 191
;     end do
     colors(0) = 0;5
     colors(1) = 33
     colors(2) = 49
     colors(3) = 65
     colors(4) = 97
     colors(5) = 113
     colors(6) = 145
     colors(7) = 161
     colors(8) = 177     
     colors(9) = 193
     colors(10) = 225
     colors(11) = 241

;--- start, stop times for hour of interest
    if(ino .eq. 0) then
     startsec = infls(0)*3600. + infls(1)*60. + infls(2)  ;inflow
     stopsec  = infle(0)*3600. + infle(1)*60. + infle(2)
    else
     startsec = outfs(0)*3600. + outfs(1)*60. + outfs(2)  ; outflow
     stopsec  = outfe(1)*3600. + outfe(1)*60. + outfe(2)
    end if

;;;;NOTE still using previous startsec and stopsec  
;--- define index for start and stop time and storage into im1 and im2
    c = ind(dc8_time_s .ge. startsec)
    im1 = c(0)
    delete(c)
    c = ind(dc8_time_s .ge. stopsec)
    im2 = c(0)
    delete(c)

 ;--- Loop over selected period
if(ino .eq. 0) then
ai=im1
bi=im2
else
ai=im3
bi=im4
end if

 do im = ai,bi;,10              
   if(ismissing(dc8_var_s(im))) then ;; 
    print(" im dc8_var ismissing    "+im+"   "+dc8_lon_s(im)+"   "+dc8_lat_s(im)+"     " )
   else
    ;--Define marker characteristics  
    gsres@gsMarkerIndex = 16    ; 8=upward triangle;  16=filled dots for markers.
    gsres@gsMarkerThicknessF = 4.
    gsres@gsMarkerSizeF = 9.
    gsres@gsMarkerColor      = "black"
    gsn_polymarker(wks,plot,dc8_lon_s(im),dc8_lat_s(im),gsres)

    ; contour levels indices are defined at the top (in "table")
    
   
       ;contourlvls = (/ 0.,25., 50., 75., 100., 125., 150., 175., 200./)
        ;contourlvls = (/ 0.,15., 30., 45., 60., 75., 90., 105., 120./)
   ;     contourlvls = (/ 88.,92., 96.,100., 104., 108., 112., 116., 120./)
        ;contourlvls = (/0.,1.,2., 3., 4., 5., 6., 7.,8.,9./)
        ;contourlvls = (/0.3,0.6,0.9, 1.2, 1.5, 1.8, 2.1, 2.4,2.7,3./)
	;contourlvls = (/0.4,0.8,1.2, 1.6, 2.0, 2.4, 2.8, 3.2,3.6,4./)
    ;   contourlvls = (/96., 112.,128., 144., 160., 176., 192., 208.,224/)
 ;      contourlvls = (/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5/)
;       contourlvls = (/0,0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8/)
 ;contourlvls = (/ 0,30., 60., 90., 120.,150.,180.,210.,240.,270.,300,330/)
 contourlvls = fspan(0,4,11);(/105,120,135,150.,165.,180.,195,210.,225,240,255,270./)
	gsres@gsMarkerColor      = colors(0)
       if(dc8_var_s(im) .ge. contourlvls(1)) then
         gsres@gsMarkerColor      = colors(1)
       end if
       if(dc8_var_s(im) .ge. contourlvls(2)) then
         gsres@gsMarkerColor      = colors(2)
       end if
       if(dc8_var_s(im) .ge. contourlvls(3)) then
         gsres@gsMarkerColor      = colors(3)
       end if
       if(dc8_var_s(im) .ge. contourlvls(4)) then
         gsres@gsMarkerColor      = colors(4)
       end if
       if(dc8_var_s(im) .ge. contourlvls(5)) then
         gsres@gsMarkerColor      = colors(5)
       end if
       if(dc8_var_s(im) .ge. contourlvls(6)) then
         gsres@gsMarkerColor      = colors(6)
       end if
       if(dc8_var_s(im) .ge. contourlvls(7)) then
         gsres@gsMarkerColor      = colors(7)
       end if
      if(dc8_var_s(im) .ge. contourlvls(8)) then
        gsres@gsMarkerColor      = colors(8)
       end if
      if(dc8_var_s(im) .ge. contourlvls(9)) then
        gsres@gsMarkerColor      = colors(9)
      end if
      if(dc8_var_s(im) .ge. contourlvls(10)) then
        gsres@gsMarkerColor      = colors(10)
      end if
    ;  if(dc8_var_s(im) .ge. contourlvls(11)) then
    ;    gsres@gsMarkerColor      = colors(11)
    ;  end if



;--- plot variables
   gsn_polymarker(wks,plot,dc8_lon_s(im),dc8_lat_s(im),gsres)
print(" var "+im+" "+dc8_time_s(im)+" "+dc8_galt_s(im)+" "+dc8_lat_s(im)+" "+dc8_lon_s(im)+" "+dc8_var_s(im) +" "+gsres@gsMarkerColor)

;---Plot time if
;        atxres = True;
;	atxres@txFontHeightF = 0.009
;        atxres@txFontColor =  "red" 
;	if(dc8_time_s(im) .eq. 60727) then
;	   gsn_text(wks,plot,"16:52:00",dc8_lon_s(im)-0.01,dc8_lat_s(im)+0.01,atxres)
;	else if(dc8_time_s(im) .eq. 60908) then
;	   gsn_text(wks,plot,"16:55:08",dc8_lon_s(im)+0.005,dc8_lat_s(im)+0.021,atxres)
;	else if(dc8_time_s(im) .eq. 70282) then
;	   gsn_text(wks,plot,"19:31:22",dc8_lon_s(im)-0.15,dc8_lat_s(im),atxres)
;	else if(dc8_time_s(im) .eq. 70287) then
;	   gsn_text(wks,plot,"19:31:27",dc8_lon_s(im)-0.19,dc8_lat_s(im)-0.09,atxres)
;	else if(dc8_time_s(im) .eq. 72464) then
;	   gsn_text(wks,plot,"20:07:44",dc8_lon_s(im)-0.095,dc8_lat_s(im)-0.025,atxres)
;	else if(dc8_time_s(im) .eq. 72466) then
;	  gsn_text(wks,plot,"20:07:46",dc8_lon_s(im)-0.1,dc8_lat_s(im)-0.07,atxres)


;	end if end if end if end if end if end if





    end if ;      ; im ismissing
 end do        ; im loop

;exit

  if(ino .eq. 0) then
;--- draw unit (DBZ)
    txres@txFontColor   = "black"
    xpt := 0.90
    ypt := 0.05
    gsn_text_ndc(wks, "(ppbv)", xpt, ypt, txres)

;--- Plot legend for flight track colors. 
    clvls = 1.*contourlvls
    ltxt = flt2string(clvls)
  
;--- define smaller font height
     txres = True
     txres@txFontHeightF = 0.009
     txres@txFont        = 21
  else
;--- Plot legend for flight track colors. 
     clvls = 1.*contourlvls
     ltxt = flt2string(clvls)
  
;--- define smaller font height
     txres = True
     txres@txFontHeightF = 0.009
     txres@txFont        = 21
  end if

 

;--- Marker loop UP ;;;;;;;;;;;;;;
        do i = 0,11

     ypt = (latmax-0.055) - 0.037*(i) ;32.6109 - 0.0053*(i) 
     xpt = lonmax - 0.046


       gsres@gsMarkerIndex = 4  
       gsres@gsMarkerThicknessF = 4.
       gsres@gsMarkerColor      = "black"
       gsn_polymarker(wks,plot,xpt,ypt,gsres)
       gsres@gsMarkerIndex = 16 
       gsres@gsMarkerThicknessF = 2.
       gsres@gsMarkerColor      = colors(i)
       gsn_polymarker(wks,plot,xpt,ypt,gsres)
    end do
;--- units txt loop
    do i = 0,10

      xpt = 0.91 
      ypt = 0.87- 0.020*(i)

        gsn_text_ndc(wks, ltxt(i), xpt, ypt, txres)
       if(i.eq.10) then
        gsn_text_ndc(wks, "(ppbv)", xpt-0.04, ypt-0.0003, txres)
       end if
    end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Close the Plot
; draw(plot)
 frame(wks)


end
