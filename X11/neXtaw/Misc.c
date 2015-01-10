/*
 * Misc. functions for neXtaw 
 * 
 * Copyright 2015 by Thomas E. Dickey
 * Copyright (c) 1996 Alfedo K. Kojima
 */

#include "config.h"

#include "Misc.h"

#ifdef XPM_TILE
#include <X11/xpm.h>
#endif

void
neXtawDrawShadowBox(
		       Widget gw,
		       ThreeDWidget tdw,
		       Position x0,
		       Position y0,
		       Position x1,
		       Position y1,
		       Boolean out)
{
    XPoint pt[6];
    Dimension s = tdw->threeD.shadow_width;

    /* 
     * Draw the shadows using the core part width and height, and the threeD
     * part shadow_width.
     *
     * There is no point to do anything if the shadow_width is 0 or the widget
     * has not been realized.
     */
    if ((s > 0) && XtIsRealized(gw)) {

	Dimension h = (Dimension) (y1 - y0);
	Dimension w = (Dimension) (x1 - x0);
	Dimension wms = (Dimension) (w - s);
	Dimension hms = (Dimension) (h - s);
	Dimension wmsm = (Dimension) (w - (s > 1 ? s / 2 : 1));
	Dimension hmsm = (Dimension) (h - (s > 1 ? s / 2 : 1));
	Dimension sm = (Dimension) (s > 1 ? s / 2 : 1);
	Display *dpy = XtDisplay(gw);
	Window win = XtWindow(gw);
	GC top, bot, toph, both;

	if (out) {
	    top = tdw->threeD.top_shadow_GC;
	    bot = tdw->threeD.bot_shadow_GC;
	    toph = tdw->threeD.top_half_shadow_GC;
	    both = tdw->threeD.bot_half_shadow_GC;
	} else {
	    top = tdw->threeD.bot_shadow_GC;
	    bot = tdw->threeD.top_shadow_GC;
	    toph = tdw->threeD.bot_half_shadow_GC;
	    both = tdw->threeD.top_half_shadow_GC;
	}

	if (tdw->threeD.bevel == XtBevelSolid) {
	    toph = top;
	    both = bot;
	}
#define SetPT(n,X,Y) pt[n].x = (short)(X); pt[n].y = (short)(Y)

	/* top-left shadow */
	SetPT(0, x0, y0 + h);
	SetPT(1, x0, y0);
	SetPT(2, x0 + w, y0);
	SetPT(3, x0 + wmsm, y0 + sm - 1);
	SetPT(4, x0 + sm, y0 + sm);
	SetPT(5, x0 + sm - 1, y0 + hmsm);
	XFillPolygon(dpy, win, toph, pt, 6, Complex, CoordModeOrigin);
	if (s > 1) {
	    SetPT(0, x0 + s - 1, y0 + hms);
	    SetPT(1, x0 + s, y0 + s);
	    SetPT(2, x0 + wms, y0 + s - 1);
	    XFillPolygon(dpy, win, top, pt, 6, Complex, CoordModeOrigin);
	}

	/* bottom-right shadow */
	SetPT(0, x0, y0 + h);
	SetPT(1, x0 + w, y0 + h);
	SetPT(2, x0 + w, y0);
	SetPT(3, x0 + wmsm, y0 + sm - 1);
	SetPT(4, x0 + wmsm, y0 + hmsm);
	SetPT(5, x0 + sm - 1, y0 + hmsm);
	XFillPolygon(dpy, win, both, pt, 6, Complex, CoordModeOrigin);
	if (s > 1) {
	    SetPT(0, x0 + s - 1, y0 + hms);
	    SetPT(1, x0 + wms, y0 + hms);
	    SetPT(2, x0 + wms, y0 + s - 1);
	    XFillPolygon(dpy, win, bot, pt, 6, Complex, CoordModeOrigin);
	}
    }
}

#ifdef XPM_TILE
Boolean
neXtawcvtStringToTilePixmap(
			       Display *display,
			       XrmValue * args,
			       Cardinal *num_args,
			       XrmValuePtr from,
			       XrmValuePtr to,
			       XtPointer *converter_data)
{
    String file = (String) from->addr;
    XpmAttributes attr;
    Pixmap pixmap, mask;
    Window win;

    if (*num_args != 2)
	XtAppErrorMsg(XtDisplayToApplicationContext(display),
		      "cvtStringToTilePixmap", "wrongParameters",
		      "XtToolkitError",
		      "String to TilePixmap conversion needs screen and colormap arguments",
		      (String *) NULL, (Cardinal *) NULL);
    win = RootWindow(display,
		     XScreenNumberOfScreen(*((Screen **) args[0].addr)));
    attr.colormap = *((Colormap *) args[1].addr);
    attr.valuemask = XpmSize | XpmReturnPixels | XpmColormap;
    if (XpmReadFileToPixmap(display, win, file, &pixmap, &mask,
			    &attr) != XpmSuccess) {
	XtDisplayStringConversionWarning(display, file, XtRTilePixmap);
	return False;
    }
    if (mask != None)
	XFreePixmap(display, mask);
    if (to->addr != NULL) {
	if (to->size < sizeof(Pixmap)) {
	    to->size = sizeof(Pixmap);
	    XtDisplayStringConversionWarning(display, file, XtRTilePixmap);
	    return False;
	}
	*(Pixmap *) (to->addr) = pixmap;
    } else {
	static Pixmap s_pixmap;

	s_pixmap = pixmap;
	to->addr = (XtPointer) &s_pixmap;
    }
    to->size = sizeof(Pixmap);
    return True;
}
#endif /* XPM_TILE */
