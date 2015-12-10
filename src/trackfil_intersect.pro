;+
; NAME:
;		trackfil_intersect
;
; PURPOSE:
;		Apply the intersection algorithm on contours area to track for the given time range.
;		(Only for filaments which have a length lesser than !LMIN).
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		TRACKFIL
;
; CALLING SEQUENCE:
;		IDL> Results = trackfil_intersect(filename,hfc_data,ctr_coord)
;
; INPUTS:
;		filename  - Scalar of string type containing the name of the observation file.
;		hfc_data  - Structure containing the filaments data loaded from the HFC.
;		ctr_coord - Structure containing the contours heliographic coordinates computed using the chain code.
;
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;		SILENT - Quiet mode.
;
; OUTPUTS:
;		Returns the hfc_data structure with tracking information (i.e. lvl_trust, feat_id) updated.
;
; OPTIONAL OUTPUTS:
;		error - Equal to 1 if an error occurs, 0 else.
;
; COMMON BLOCKS:
;		CLOG
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS:
;		Calls the Helio Software library.
;
; CALL:
;		tim2carr
;		shape_overlap (from MIDL_lib)
;		shape_area	  (from MIDL_lib)
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by: X.Bonnin,	05-MAY-2011.
;
;-

FUNCTION trackfil_intersect, filename, hfc_data, ctr_coord, error=error, SILENT=SILENT

COMMON CLOG,loglun

;[1]:Initialize the input parameters
;[1]:===============================
error = 1
if (n_params() lt 3) then message,'Incorrect number of input arguments!'
if (size(hfc_data,/TNAME) ne 'STRUCT') then message,'HFC_DATA input parameter must be a structure!'
if (size(ctr_coord,/TNAME) ne 'STRUCT') then message,'CTR_COORD input parameter must be a structure!'

data = hfc_data
Xdata = ctr_coord

SILENT = keyword_set(SILENT)
;[1]:===============================

;[2]:Retrieve hfc data 
;[2]:=================
file = strtrim(filename[0],2)

;Get date of the observation file
iobs = where(data.loc_filename eq file,nobs)
jd_obs0 = data[iobs[0]].jd_obs

;Longitude range of the Carrington map to retrieve (in julian day)
jd_range = [jd_obs0 - 0.5d*!TRACKING_PERIOD,jd_obs0 + 0.5d*!TRACKING_PERIOD]

;Keep id of filaments only for this time range
where_in = where(data.jd_obs ge jd_range[0] and data.jd_obs le jd_range[1],nfil)
if (where_in[0] eq -1) then begin
	message,/INFO,'No filament corresponds to the input criteria!'
	return,hfc_data
endif
id_fil = data[where_in].id_fil
date_obs = data[where_in].date_obs
jd_obs = data[where_in].jd_obs
lnth = data[where_in].ske_len_deg

;time range in string format
trange = jd2str(jd_range)

;Corresponding Decimal Carrington longitudes of the central meridian
dc = tim2carr(trange,/DC)

trackfil_log,loglun,'Time range to span = '+trange[0]+' to '+trange[1]
trackfil_log,loglun,'Corresponding Decimal Carrington rotation range = '+string(dc[0],format='(f7.2)')+' to '+string(dc[1],format='(f7.2)')
trackfil_log,loglun,'Number of filaments to match = '+strtrim(nfil,2) + ' (ske_len_deg < ' + string(!LMIN,format='(f5.1)')+'°)'
;[2]:=================

;[3]:Calculate Carrington coordinates 
;[3]:================================

;Parameters for the Carrington grid
grid_res = 1.e30 ;grid resolution

id_ctr = 0L & Xcar = dblarr(2,1)
for i=0L,nfil-1L do begin
	if (~SILENT) then printl,'Carrington coordinates converting  : '+string(100.*(i+1L)/nfil,format='(f6.2)')+'% completed.'
		
	;Get contour coordinates of the filament
	where_id = where(id_fil[i] eq Xdata.id_fil)
	if (where_id[0] eq -1) then continue
	Xhel_i = reform(Xdata.Xhel[*,where_id])
	
	;Calculate the Carrington coordinates of the contour for the time range
	Xcar_i = hel2car(Xhel_i,date_obs[i],dec0=dc[0],/DRC)
	
	;Set spatial resolution of Carrington grid (in deg)
	dX_i = reform(Xcar_i[0,*])
	dX_i = (abs(dX_i - shift(dX_i,1)))[1:*]
	dY_i = reform(Xcar_i[1,*])
	dY_i = (abs(dY_i - shift(dY_i,1)))[1:*]
	grid_res = [grid_res,dX_i(where(dX_i ne 0.)),dY_i(where(dY_i ne 0.))]
				
	id_ctr = [id_ctr,id_fil[i] + lonarr(n_elements(Xcar_i[0,*]))]
	Xcar = [[Xcar],[Xcar_i]]
endfor
print,''
id_ctr = id_ctr[1:*]
Xcar = Xcar[*,1:*]
Xhel_i = 0B & Xcar_i = 0B & dX_i = 0B & dY_i = 0B;free memory

;Define grid resolution used to search for overlapped filaments
grid_res = 0.1d*median(grid_res[1:*])

trackfil_log,loglun,'Spatial resolution of Carrington Grid = '+strtrim(grid_res,2)+' deg.'

;[3]:================================


;[4]:Perform the intersection algorithm
;[4]:==================================
processed = intarr(nfil,nfil)

;Loops on filaments
for i=0L,nfil-1L do begin

	if (~SILENT) then printl,'Intersection computing : '+string(100.*(i+1L)/nfil,format='(f6.2)')+'% completed.'
	
	;Perform intersection method only for filaments fo which the length is lesser that !LMIN
	if (lnth[i] ge !LMIN) then continue
	
	;Initialize lvl of trust
	where_i = (where(id_fil[i] eq data.id_fil))[0]
	data[where_i].lvl_trust = 0
	
	;Get contour Carrington coordinates of the filament
	where_id = where(id_fil[i] eq id_ctr,ni)
	if (where_id[0] eq -1) then continue
	Xi = reform(Xcar[0,where_id])
	Yi = reform(Xcar[1,where_id])
	Ai = poly_area(Xi,Yi)
					
	;Look for filaments which have an intersection with the current one
	Pij = fltarr(nfil)
	for j=0L,nfil-1L do begin
		if (i eq j) then continue
		if (processed[i,j] eq 1) or (processed[j,i] eq 1) then continue
		
		;Get contour Carrington coordinates of the second filament
		where_j = where(id_fil[j] eq id_ctr,nj)
		Xj = reform(Xcar[0,where_j])
		Yj = reform(Xcar[1,where_j])
		Aj = poly_area(Xj,Yj)
	
		ii = poly_intersect(Ai,Aj)
		
		stop
		;Compute the area of the convex hull
		Xij = [Xi,Xj] & Yij = [Yi,Yj]
		triangulate,Xij,Yij,triangle,ihull
		Ahull = poly_area([Xij[ihull],Xij[ihull[0]]],[Yij[ihull],Yij[ihull[0]]])
	
		;if convex hull area is greater than the sum of the two filaments area, there is no intersection -> continue
		if (Ahull gt (Ai + Aj)) then continue 
		
		;if intersection, calculate the intersection area (i.e. common pixels ratio) using the Carrington grid
		
		;Generate local Carrington grid
		Xmin = min([Xi,Xj],max=Xmax)
		Ymin = min([Yi,Yj],max=Ymax)
		nX = long((Xmax-Xmin)/grid_res) + 2L
		nY = long((Ymax-Ymin)/grid_res) + 2L
		Xgrid = grid_res*findgen(nX) + Xmin
		Ygrid = grid_res*findgen(nY) + Ymin
		grid = intarr(nX,nY)
	
		;Pixels of the first filament contour on the grid
		iX = (Xi - Xmin)/grid_res
		iY = (Yi - Ymin)/grid_res
	
		;Pixels inside the contour
		ipix = polyfillv(iX,iY,nX,nY)
		nipix = n_elements(ipix)	
		grid[ipix] = 1
	
		;Pixels of the second filament contour on the grid
		jX = (Xj - Xmin)/grid_res
		jY = (Yj - Ymin)/grid_res
		
		;Pixels inside the contour
		jpix = polyfillv(jX,jY,nX,nY)
		njpix = n_elements(jpix)
		grid[jpix] = grid[jpix] + 1
		
		;grid = 2 where there are common pixels
		where_ij = where(grid ge 2,nijpix)
		
		;Compute the ratio of common pixels number on the sum of numbers of pixels of the two filaments polygons
		Pij[j] = 100.*2.*float(nijpix)/float(nipix + njpix) 
		
		processed[i,j] = 1 & processed[j,i] = 1
	endfor
	 	
	lvl_trust = max(Pij,j)
	where_i = (where(id_fil[i] eq data.id_fil))[0]
	where_j = (where(id_fil[j] eq data.id_fil))[0]
	
	if (lvl_trust gt 0.) then begin
	;Filament i receives the tracking index (feat_id) of the filament j for which 
	;the overlapping is maximal 
		if (data[where_j].ske_len_deg ge !LMIN) then begin
			data[where_i].feat_id = data[where_j].feat_id
		endif else begin
			data[where_i].feat_id = data[where_j].feat_id
			where_feat_id_j = where(data[where_j].feat_id eq data.feat_id)
			len_feat_id = data[where_feat_id_j].ske_len_deg
			wlen = where(len_feat_id ge !LMIN)
			if (wlen[0] eq -1) then begin
				data[where_feat_id_j].feat_id = min([id_fil[i],data[where_j].feat_id])
			endif else begin
				data[where_i].feat_id = data[where_feat_id_j[wlen[0]]].feat_id
			endelse
		endelse
	endif
	data[where_i].lvl_trust = lvl_trust  
endfor
;[4]:====================================


error = 0
return,data
END