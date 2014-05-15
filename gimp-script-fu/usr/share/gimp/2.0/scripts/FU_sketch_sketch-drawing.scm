; FU_sketch_sketch-drawing.scm
; version 2.7 [gimphelp.org]
; last modified/tested by Paul Sherman
; 05/05/2012 on GIMP-2.8
;
; ------------------------------------------------------------------
; Original information ---------------------------------------------
;
; Drawing script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------
; End original information ------------------------------------------
;--------------------------------------------------------------------

(define (FU-drawing
			img
			drawable
			thickness
	)

  (gimp-image-undo-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
         (thf (* height  0.005 thickness ))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
	 (layer-temp2 (car (gimp-layer-new img width height layer-type "temp2"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-image-insert-layer img layer-temp1 0 -1)
    (gimp-image-insert-layer img layer-temp2 0 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (if (eqv? (car (gimp-drawable-is-gray drawable)) FALSE)      
        (gimp-desaturate layer-temp1))
    (gimp-edit-copy layer-temp1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
    (gimp-invert layer-temp2)
    (plug-in-gauss 1 img layer-temp2 thf thf 0)
    (gimp-layer-set-mode layer-temp2 16)
    (gimp-image-merge-down img layer-temp2 0)
    (set! layer-temp1 (car (gimp-image-get-active-layer img)))
    (gimp-levels layer-temp1 0 215 235 1.0 0 255) 

    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-item-set-name layer-temp1 "Drawing")
    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
	"FU-drawing"
	"<Image>/Script-Fu/Sketch/Drawing"
	"Creates a drawing.\n\nThis version lets you adjust the line thickness."
	"Eddy Verlinden <eddy_verlinden@hotmail.com>"
	"Eddy Verlinden"
	"2007, juli"
	"RGB* GRAY*"
	SF-IMAGE      "Image"	            0
	SF-DRAWABLE   "Drawable"          0
	SF-ADJUSTMENT "thickness"        '(2 1 5 1 1 0 0)
)


