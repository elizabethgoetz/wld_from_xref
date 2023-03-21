;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Name:       WLDfromXREF
;;; Author:     Ulises  Guzman
;;; Created:    06/14/2017
;;; Copyright:   (c)
;;; AutoCAD Version:   AutoCAD Map 3D 2016
;;;;;;;;; --------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;; This script creates world files for any xref in the CAD drawing. It calculates the required transformations by following Aaron Cheuvront's logic (University of Washington),
;;; but it doesn't require any user interaction. It also saves the world files to their appropiate Meridian folders to further facilitate georeferencing floorplans. Python will
;;; be used to invoke this routine on multiple CAD files.
;;;;;;;;; ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun CreateWorldFile ( / appAcad docActive blocksCollection blockItem xrefName removalCand xrefPath stringRemoved xreFoldName xrefsObj currObj currObjProp wldPath wldFile)
  (vl-load-com) ;;;loads activeX
  (setq appAcad (vlax-get-acad-object)
        docActive (vla-get-ActiveDocument appAcad)
        ) ;;;;;;;;;setq appAcad
  (setq blocksCollection (vla-get-blocks docActive))
  (vlax-for blockItem blocksCollection
            ;;;checking if the block is a xref
            (if (= (vlax-get-property blockItem 'IsXref) :vlax-true)
                (progn
                  ;;; reloading xrefs
                  (vl-catch-all-apply 'vla-reload (list blockItem))
                  (setq xrefName (vlax-get blockItem 'Name)
                        ;;;lisp is not very good at doing regex
                        removalCand "\\\\FMMERIDIAN\\am\\Vault,D-UCBFAC\\SUSTAINING\\BUILDING\\CAD\\SS\\"
                        xrefPath (vla-get-path blockItem)
                        stringRemoved (vl-string-left-trim removalCand xrefPath)
                        xreFoldName (vl-filename-directory stringRemoved)
                        )
                  ;;;bind - insert xref
                  (vlax-invoke-method blockItem "bind" :vlax-true)
                  ;;; (print(vlax-dump-object blockItem))
                  ;;;;;;;;; (print(entget(tblsearch "BLOCK" (vlax-get-property blockItem 'Name)))) 
                  (setq xrefsObj (ssget "_X" (list (cons 0 "INSERT")(cons 2 xrefName)))
                        currObj (ssname xrefsObj 0)
                        currObjProp (entget currObj '("*")) 
                        ;;;calculating transformation parameters following 
                        ;;;Aaron Cheuvront's (University of Washington) logic.
                        ;;;His original code can be found in the WorldFile.LSP 
                        ;;;routine
                        ;;;creating world file
                        pt1 "0,0"
                        pt2 "1000,1000"
                        ins (cdr (assoc 10 currObjProp))
                        pt3x ins
                        pt3 (strcat (rtos (car pt3x) 2 10) "," (rtos (cadr pt3x) 2 10))
                        ang (cdr (assoc 50 currObjProp))
                        scale (cdr (assoc 41 currObjProp))
                        dist (* scale (sqrt (* 2 (* 1000 1000))))
                        pt4x (polar ins (+ (* pi 0.25) ang) dist)
                        pt4 (strcat (rtos (car pt4x) 2 10) "," (rtos (cadr pt4x) 2 10))         
                        ;;; wldPath (strcat "G:\\Ulises_Python_Scripts\\worldfiles\\" xreFoldName "\\" xrefName ".wld")
                        ;;; wldPath (strcat "E:\\Users\\ulgu3559\\Desktop\\WORLDTEST\\dwg\\"  xrefName ".wld")
                        ;;; wldPath (strcat "E:\\Users\\ulgu3559\\Desktop\\WORLDTEST\\dwg_dos\\"  xrefName ".wld")
                        wldPath (strcat "\\\\Kingtut\\gis\\gis_scratch\\"  xrefName ".wld") 
                        ;;; this line saves the world file to the buildings' folders inside  Meridian
                        ;;; it is assumed that the letter W has been already assigned to that location                 
                        ;;; wldPath (strcat "W:\\" xreFoldName "\\" xrefName ".wld")                     
                        wldFile (open wldPath "w")
                        )
                  (print wldPath)                 
                  ;;; (print currObjProp)               
                  ;;;write the 2 lines of points to the file
                  (write-line (strcat pt1 " " pt3) wldFile)
                  (write-line (strcat pt2 " " pt4) wldFile)
                  (close wldFile)                               
                  );;;progn
                );;;if
            ) ;;;vlax-for
  ;;; (print "Jarvis out (Proceeds to drop the mic)")
  (princ)
  )
(CreateWorldFile)

