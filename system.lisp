;;; -*- Mode: Lisp; Package: User -*-

;;;  (c) copyright 1998,1999,2000 by Michael McDonald (mikemac@mikemac.com)
;;;  (c) copyright 2000 by 
;;;           Robert Strandh (strandh@labri.u-bordeaux.fr)

;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Library General Public
;;; License as published by the Free Software Foundation; either
;;; version 2 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Library General Public License for more details.
;;;
;;; You should have received a copy of the GNU Library General Public
;;; License along with this library; if not, write to the 
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
;;; Boston, MA  02111-1307  USA.

(in-package :common-lisp-user)

#+:excl(require :clx)
#+:excl(require :loop)

(defparameter *clim-directory* (directory-namestring *load-truename*))

#+cmu
(progn
  (unless (fboundp 'ext:stream-read-char)
    (unless (ignore-errors (ext:search-list "gray-streams:"))
      (setf (ext:search-list "gray-streams:")
	'("target:pcl/" "library:subsystems/")))
    (load "gray-streams:gray-streams-library"))
  #-MK-DEFSYSTEM
  (load "library:subsystems/defsystem"))

(pushnew :CLIM *features*)

#+mk-defsystem (use-package "MK")

#+mk-defsystem
(defmacro clim-defsystem ((module &key depends-on) &rest components)
  `(defsystem ,module
       :source-pathname *clim-directory*
       :source-extension "lisp"
       ,@(and depends-on `(:depends-on ,depends-on))
        :components
	(:serial
	 ,@components)))

#-mk-defsystem
(defmacro clim-defsystem ((module &key depends-on) &rest components)
  `(defsystem ,module ()
     (:serial
      ,@depends-on
      ,@components)))

(clim-defsystem (:clim-lisp)
  ;; First possible patches
  #+:CMU       "Lisp-Dep/fix-cmu"
  #+:EXCL	"Lisp-Dep/fix-acl"
  #+:SBCL      "Lisp-Dep/fix-sbcl"
  "package")

(clim-defsystem (:clim-core)
   ;; First possible patches
   #+:CMU       "Lisp-Dep/fix-cmu"
   #+:EXCL	"Lisp-Dep/fix-acl"
   #+:SBCL      "Lisp-Dep/fix-sbcl"
   "package"

   "decls"

   #.(OR
      #+(AND :CMU :MP (NOT :PTHREAD))  "Lisp-Dep/mp-cmu"
      #+(AND :SBCL :MP (NOT :PTHREAD)) "Lisp-Dep/mp-sbcl"
      #+:EXCL                          "Lisp-Dep/mp-acl"
      #| fall back |#                  "Lisp-Dep/mp-nil")
   "utils"
   "defresource"
   "setf-star"
   
   "design"
   "X11-colors"
   ;; "brectangle"
   "coordinates"
   "transforms"
   "regions"

   "sheets"
   "pixmap"
   
   "events"

   "ports" ; depends on events
   "grafts"
   "medium"
   "output"

   "input"
   "repaint"
   "graphics"
   "views"
   "encapsulate"
   "stream-output"
   "recording"
   "stream-input"
)

(clim-defsystem (:goatee-core :depends-on (:clim-core))
  "Goatee/conditions"
  "Goatee/dbl-list"
  "Goatee/flexivector"
  "Goatee/buffer"
  "Goatee/editable-buffer"
  "Goatee/editable-area"
  "Goatee/clim-area"
  "Goatee/goatee-command"
  "Goatee/editing-stream"
  )

(clim-defsystem (:clim-postscript :depends-on (:clim-core))
   "Backends/PostScript/package"
   "Backends/PostScript/class"
   "Backends/PostScript/graphics"
   "Backends/PostScript/sheet"
   )

(clim-defsystem (:clim :depends-on (:clim-core :goatee-core :clim-postscript))
   "input-editing"
   "presentations"
   "commands"
   "frames"
   "panes"
   "gadgets"
   "menu"
   "table-formatting"
   "bordered-output"
   "incremental-redisplay"
   "builtin-commands"
   )

(clim-defsystem (:clim-clx :depends-on (:clim))
  "Backends/CLX/package"
  "Backends/CLX/keysyms"
  "Backends/CLX/keysymdef"
  "Backends/CLX/port"
  "Backends/CLX/medium"
  "Backends/CLX/graft"
  "Backends/CLX/frame-manager"
  "Backends/CLX/image"
  "Backends/CLX/clim-extensions"
  )

#+gl
(clim-defsystem (:clim-opengl :depends-on (:clim))
   "Backends/OpenGL/opengl-x-frame-manager"
   "Backends/OpenGL/opengl-frame-manager"
   "Backends/OpenGL/opengl-x-port-before"
   "Backends/OpenGL/opengl-port"
   "Backends/OpenGL/opengl-x-port-after"
   "Backends/OpenGL/opengl-medium"
   "Backends/OpenGL/opengl-x-graft"
   )

(clim-defsystem (:clim-looks :depends-on (:clim-clx #+gl :clim-opengl))
  "Looks/pixie")

;;; Will depend on :goatee soon...
;;; name of :clim-clx-user chosen by mikemac for no good reason
(clim-defsystem (:clim-clx-user :depends-on (:clim :clim-clx)))

(clim-defsystem (:clim-examples :depends-on (:clim :clim-looks))
   "Examples/calculator"
   "Examples/colorslider"
   "Examples/menutest"
   "Examples/address-book"
   "Examples/traffic-lights"
   "Examples/clim-fig"
   "Examples/postscript-test"
   "Examples/transformations-test"
   "Examples/stream-test"
   "Examples/presentation-test"
   "Examples/gadget-test"
   "Goatee/goatee-test")



