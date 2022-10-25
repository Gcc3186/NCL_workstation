
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot SkewT's at a number of locations

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;

 pobs = asciiread("profile_obs.txt",(/143,5/),"float")
 pmodoa = asciiread("profile_modeled_OA.txt",(/73,5/),"float")
 pmod = asciiread("profile_modeled.txt",(/73,5/),"float")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Stations, and their lat/lon locations

  ip_locs = (/ "JAN"/)
  ip_lats = (/   32.32/)          
  ip_lons = (/  -90.08/)
  ip_times= (/   "12" /)
  ip_dates= (/   "2013-09-02"/)
  ip_opre = (/ "JAN_"/)

  dimloc = dimsizes(ip_lats)
  nloc = dimloc(0)

  type = "X11"
  wks = gsn_open_wks(type,"SkewT_WRF-Obs-Sep2_OANARR_18")

  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")
   do ip = 0, nloc-1       ; LOOP through above 20 station locations and
                           ; plot a skewT if location is inside model domain
     wrfdate = ip_dates(ip)
     if(ip_times(ip) .ne. "23") then
      wrfhour = ip_times(ip)+":10:00"
     else
      wrfhour = "21:10:00"         ; don't have 2300 in wrf sim currently
     end if
     wrfhour = "21:10:00"         ; just set to this to test on Kristin's code

;***************************************************************
; The WRF ARW input file.  
     wrfdir = "./"
     fname = wrfdir+"wrfout2_10min_d01_"+wrfdate+"_"+wrfhour+".nc"
     print(" WRF file:  "+fname )
     filename ="WRFCHEM_lgtn"
     a = addfile(filename, "r")
     b = addfile("WRFCHEM_lgtn" , "r")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
     FirstTime = True
     times  = wrf_user_list_times(a)  ; get times in the file
     ntimes = dimsizes(times)         ; number of times in the file

;    Get some dimension info - so we can later check to make sure 
;    the sounding locations are inside the model domain
     mdims = getfilevardimsizes(a,"P")
     nd = dimsizes(mdims)
print(" mdims = "+mdims)
     dimX = mdims(nd-1)
     dimY = mdims(nd-2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;it = 0
     it = 72 
     ita = 36
       print("Working on time: " + times(it) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    First get the variables we will need        

       tc  = wrf_user_getvar(a,"tc",it)         ; T in C
       td  = wrf_user_getvar(a,"td",it)         ; dew point temperature
       p   = wrf_user_getvar(a, "pressure",it)  ; grid point pressure
       z   = wrf_user_getvar(a, "z",it)         ; grid point height
       uvm = wrf_user_getvar(a,"uvmet",it)      ; umet and vmet averaged to mass points
					        ; This is a 4D array where
					        ; uvm(0,:,:,:) is umet, and
					        ; uvm(1,:,:,:) is vmet, and
					        ; This function rotate winds to earth coord.

       tca  = wrf_user_getvar(b,"tc",ita)         ; T in C
       tda  = wrf_user_getvar(b,"td",ita)         ; dew point temperature
       pa   = wrf_user_getvar(b, "pressure",ita)  ; grid point pressure
       za   = wrf_user_getvar(b, "z",ita)         ; grid point height
       uvma = wrf_user_getvar(b,"uvmet",ita)      ; umet and vmet averaged to mass points
					        ; This is a 4D array where
					        ; uvm(0,:,:,:) is umet, and
					        ; uvm(1,:,:,:) is vmet, and
					        ; This function rotate winds to earth coord.


    ; extract u and v from uvm array, and turn wind into kts
       u   = uvm(0,:,:,:)*1.94386 
       v   = uvm(1,:,:,:)*1.94386

; extract u and v from uvm array, and turn wind into kts
       ua   = uvma(0,:,:,:)*1.94386 
       va   = uvma(1,:,:,:)*1.94386

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Get ij point in model domain for location "ip"
    ; loc(1) is south-north (y) and loc(0) is west-east (x)
       loc = wrf_user_ll_to_ij(a, ip_lons(ip), ip_lats(ip), True)
       locX = loc(0)
       locY = loc(1)

      if ( locX .lt. 1 .or. locX .gt. dimX .or. locY .lt. 1 .or. locY .gt. dimY )
         if ( FirstTime)
           print("Attempting to plot: " + "Station - " + ip_locs(ip) )
           print("                    " + "at location: "+ ip_lats(ip) +" ; "+ ip_lons(ip) )
           print("                    " + "SKIP: Sounding outside model domain" )
         end if
      else

    ; We need array points in NCL space 
         locX = locX - 1
         locY = locY - 1

    ; Define a few skew-T plotting options
         skewtOpts          = True
         skewtOpts@DrawHeightScale   = True    ; plot height scale on side
         skewtOpts@DrawHeightScaleFt = False   ; plot height scale in km
         skewtOpts@DrawStandardAtm   = True    ; draw standard atm on plot
         skewtOpts@vpXF              = 0.12    ; controls off-set from left
         skewtOpts@vpYF              = 0.87    ; controls off-set from top
         skewtOpts@vpWidthF          = 0.75    ; controls size of plot
         skewtOpts@vpHeightF         = 0.75    ; controls size of plot
         skewtOpts@DrawFahrenheit    = False   ; use deg C scale
         ;skewtOpts@tiMainFontHeightF = 0.015   ; change height of main title
        ;skewtOpts@DrawColLine       = False   ; draw lines in black
         skewtOpts@DrawColAreaFill   = True   ; color on background plot
        ;skewtOpts@DrawColAreaColor  = "Green" ; final color may depend on the color table used
         skewtOpts@DrawColAreaColor  = 53     ; Light Green for WhViBlGrYeOrReWh color table
         skewtOpts@PrintOpts         = False   ; do not print options out


  ;      Get the skew-T background
         skewtOpts@tiMainString = ip_locs(ip)+" ("+ip_lats(ip)+", "+ip_lons(ip)+")  at " + times(it)
         skewt_bkgd             = skewT_BackGround (wks, skewtOpts)
         draw (skewt_bkgd)

         printMinMax(p(:,locY,locX), True)

  ;      Draw the skew-T plot NARR OA
         dataOpts           = True
         dataOpts@Parcel    = 1 
         dataOpts@WspdWdir  = False  ; wind speed and dir [else: u,v]
         dataOpts@HspdHdir  = False   ; wind speed and dir [else: u,v]
         dataOpts@PlotWindH = False  ; plot wind barbs at h lvls [pibal; special]
         dataOpts@ThermoInfo = False
         dataOpts@linePatternDewPt = 1
         dataOpts@linePatternTemperature = 0
         dataOpts@colTemperature  = "blue"
         dataOpts@colDewPt        = "blue"
         dataOpts@colWindP        = "blue"
         skewT_data = skewT_PlotData(wks, skewt_bkgd, p(:,locY,locX), \
                                                     tc(:,locY,locX), \
                                                     td(:,locY,locX), \
                                                      z(:,locY,locX), \
                                                      u(:,locY,locX), \
                                                      v(:,locY,locX), \
                                                     dataOpts)


;      Draw the skew-T plot NARR NO OA
         dataOpts1           = True
         dataOpts1@Parcel    = 1 
         dataOpts1@WspdWdir  = False  ; wind speed and dir [else: u,v]
         dataOpts1@HspdHdir  = False   ; wind speed and dir [else: u,v]
         dataOpts1@PlotWindH = False  ; plot wind barbs at h lvls [pibal; special]
         dataOpts1@ThermoInfo = False
         dataOpts1@xpWind    = 50.
         dataOpts1@linePatternDewPt = 1
         dataOpts1@linePatternTemperature = 0
         dataOpts1@colTemperature  = "red"
         dataOpts1@colDewPt        = "red"
         dataOpts1@colWindP        = "red"
          skewT_data = skewT_PlotData(wks, skewt_bkgd, pa(:,locY,locX), \
                                                     tca(:,locY,locX), \
                                                     tda(:,locY,locX), \
                                                      za(:,locY,locX), \
                                                      ua(:,locY,locX), \
                                                      va(:,locY,locX), \
                                                     dataOpts1)

        print(tc(:,locY,locX))
         ;print(table)
         table_modnooa=new((/73,5/),float)
         table_modnooa(:,1)=tc(:,locY,locX)
         table_modnooa(:,2)=td(:,locY,locX)
         table_modnooa(:,0)=z(:,locY,locX)
         table_modnooa(:,3)=u(:,locY,locX)
         table_modnooa(:,4)=v(:,locY,locX)

fmtf1 ="15f15.3" ; format string using fortran notation
opt1 = True
opt1@fout = "profile_modeled_OA.txt"
write_matrix(table_modnooa,fmtf1,opt1)

         draw(skewT_data)

;         wrf_cape = skewT_data@Cape          ; Convective Available Potential Energy [J]
;         wrf_pwat = skewT_data@Pwat          ; Precipitable Water [cm]
;         wrf_shox = skewT_data@Shox          ; Showalter Index (stability)
;         wrf_plcl = skewT_data@Plcl          ; Pressure of the lifting condensation level [hPa]
;         wrf_tlcl = skewT_data@Tlcl          ; Temperature at the lifting condensation level [C]

;         print(" WRF_"+ip_opre(ip)+ip_lats(ip)+"_"+ip_lons(ip)+"-"+times+"   CAPE,PWat,Shox,Plcl,Tlcl   "+ \
;               wrf_cape+"  "+wrf_pwat+"  "+wrf_shox+"  "+wrf_plcl+"  "+wrf_tlcl )

;***************************
         draw(skewT_data)

;         obs_cape = skewT_data@Cape          ; Convective Available Potential Energy [J]
;         obs_pwat = skewT_data@Pwat          ; Precipitable Water [cm]
 ;        obs_shox = skewT_data@Shox          ; Showalter Index (stability)
 ;        obs_plcl = skewT_data@Plcl          ; Pressure of the lifting condensation level [hPa]
 ;        obs_tlcl = skewT_data@Tlcl          ; Temperature at the lifting condensation level [C]

 ;        print(" OBS_"+ip_opre(ip)+ip_lats(ip)+"_"+ip_lons(ip)+"-"+times+"   CAPE,PWat,Shox,Plcl,Tlcl   "+ \
  ;             obs_cape+"  "+obs_pwat+"  "+obs_shox+"  "+obs_plcl+"  "+obs_tlcl )

         txres = True
         txres@txFontHeightF = 0.012
         txres@txFont        = 21
         txres@txJust        = "CenterRight"
         txres@txPerimOn     = False
         txres@txFontColor   = "red"
         ;wrftxt = "WRF: CAPE = "+wrf_cape
         xpt = 0.69
         ypt = 0.83
         gsn_text_ndc(wks, wrftxt, xpt, ypt, txres)
         txres@txFontColor   = "magenta"
         ;obstxt = "OBS: CAPE = "+obs_cape
         ypt = 0.80
         gsn_text_ndc(wks, obstxt, xpt, ypt, txres)

  ;      Close the frame
         frame(wks)

         delete(skewtOpts)
         delete(dataOpts)
         delete(skewT_data)
         delete(skewt_bkgd)

         delete(obsdata)
         delete(obs_p)
         delete(obs_tc)
         delete(obs_td)
         delete(obs_z)
         delete(obs_wspd)
         delete(obs_wdir)
      end if                          ; if sonde location is on grid

    FirstTime = False

   end do     ; END OF LOCATIONS   ip loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


end

