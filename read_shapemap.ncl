load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function creates a cylindrical equidistant map of Australia
; so you you can add polylines, polygons, or point data to it later.
;----------------------------------------------------------------------
function create_map(wks,title)
local a, res2
begin
  res2               = True
  res2@gsnMaximize   = True
  res2@gsnDraw       = False
  res2@gsnFrame      = False

  res2@mpOutlineOn   = True
  res2@mpFillOn      = False  
  res2@mpDataBaseVersion = "MediumRes"

;---Turn on fancier tickmark labels.
  res2@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  res2@mpLimitMode           = "LatLon"
  res2@mpMinLatF             = 31.5
  res2@mpMaxLatF             = 33.0
  res2@mpMinLonF             = -91
  res2@mpMaxLonF             = -89

  res2@tiMainString          = title

;---Create map.
  map = gsn_csm_map(wks,res2)

  return(map)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;
; This shapefile was obtained from:
;
;  http://e-atlas.org.au/content/au-ga-river-basins-1997
;
  filename = "shape_map/Designated_Highways.shp"

;--- Open workstation.
  wks = gsn_open_wks("x11","shapefiles")

;---Create the map
  map = create_map(wks,"Places of interest")

;---Attach the polylines
  pres             = True
  pres@gsLineColor = "blue"
  poly = gsn_add_shapefile_polylines(wks,map,filename,pres)

;---Drawing the map will also draw the attached polylines.
  draw(map)
  frame(wks)
end
