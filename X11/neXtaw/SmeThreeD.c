/***********************************************************

Copyright 2015,2022 by Thomas E. Dickey
Copyright (c) 1996 by Alfredo Kojima
Copyright 1987, 1988 by Digital Equipment Corporation, Maynard, Massachusetts,
and the Massachusetts Institute of Technology, Cambridge, Massachusetts.
Copyright 1992, 1993 by Kaleb Keithley

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the names of Digital, MIT, or Kaleb
Keithley not be used in advertising or publicity pertaining to distribution
of the software without specific, written prior permission.

DIGITAL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
DIGITAL BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

******************************************************************/

#include "private.h"

#include <X11/Xlib.h>
#include <X11/StringDefs.h>
#include <X11/IntrinsicP.h>
#include "XawInit.h"
#include "SmeThreeDP.h"
#include <X11/Xosdefs.h>

/* Initialization of defaults */

#define XtNtopShadowPixmap "topShadowPixmap"
#define XtCTopShadowPixmap "TopShadowPixmap"
#define XtNbottomShadowPixmap "bottomShadowPixmap"
#define XtCBottomShadowPixmap "BottomShadowPixmap"
#define XtNshadowed "shadowed"
#define XtCShadowed "Shadowed"

#define offset(field) XtOffsetOf(SmeThreeDRec, field)

static XtResource resources[] =
{
    {XtNshadowWidth, XtCShadowWidth, XtRDimension, sizeof(Dimension),
     offset(sme_threeD.shadow_width), XtRImmediate, (XtPointer) 2},
    {XtNtopShadowPixel, XtCTopShadowPixel, XtRPixel, sizeof(Pixel),
     offset(sme_threeD.top_shadow_pixel), XtRString, DeConst(XtDefaultForeground)},
    {XtNbottomShadowPixel, XtCBottomShadowPixel, XtRPixel, sizeof(Pixel),
     offset(sme_threeD.bot_shadow_pixel), XtRString, DeConst(XtDefaultForeground)},
    {XtNtopShadowPixmap, XtCTopShadowPixmap, XtRPixmap, sizeof(Pixmap),
     offset(sme_threeD.top_shadow_pxmap), XtRImmediate, (XtPointer) NULL},
    {XtNbottomShadowPixmap, XtCBottomShadowPixmap, XtRPixmap, sizeof(Pixmap),
     offset(sme_threeD.bot_shadow_pxmap), XtRImmediate, (XtPointer) NULL},
    {XtNtopShadowContrast, XtCTopShadowContrast, XtRInt, sizeof(int),
     offset(sme_threeD.top_shadow_contrast), XtRImmediate, (XtPointer) 20},
    {XtNbottomShadowContrast, XtCBottomShadowContrast, XtRInt, sizeof(int),
     offset(sme_threeD.bot_shadow_contrast), XtRImmediate, (XtPointer) 40},
    {XtNuserData, XtCUserData, XtRPointer, sizeof(XtPointer),
     offset(sme_threeD.user_data), XtRPointer, (XtPointer) NULL},
    {XtNbeNiceToColormap, XtCBeNiceToColormap, XtRBoolean, sizeof(Boolean),
     offset(sme_threeD.be_nice_to_cmap), XtRImmediate, (XtPointer) False},
    {XtNshadowed, XtCShadowed, XtRBoolean, sizeof(Boolean),
     offset(sme_threeD.shadowed), XtRImmediate, (XtPointer) False},
    {XtNborderWidth, XtCBorderWidth, XtRDimension, sizeof(Dimension),
     XtOffsetOf(RectObjRec, rectangle.border_width), XtRImmediate,
     (XtPointer) 0}
};

#undef offset

static void Initialize(Widget, Widget, ArgList, Cardinal *);
static void Destroy(Widget);
static void ClassPartInitialize(WidgetClass);
static void _XawSme3dDrawShadows(Widget);
static Boolean SetValues(Widget, Widget, Widget, ArgList, Cardinal *);

SmeThreeDClassRec smeThreeDClassRec =
{
    {				/* core fields */
    /* superclass               */ (WidgetClass) & smeClassRec,
    /* class_name               */ "SmeThreeD",
    /* widget_size              */ sizeof(SmeThreeDRec),
    /* class_initialize         */ NULL,
    /* class_part_initialize    */ ClassPartInitialize,
    /* class_inited             */ FALSE,
    /* initialize               */ Initialize,
    /* initialize_hook          */ NULL,
    /* realize                  */ NULL,
    /* actions                  */ NULL,
    /* num_actions              */ 0,
    /* resources                */ resources,
    /* resource_count           */ XtNumber(resources),
    /* xrm_class                */ NULLQUARK,
    /* compress_motion          */ TRUE,
    /* compress_exposure        */ TRUE,
    /* compress_enterleave      */ TRUE,
    /* visible_interest         */ FALSE,
    /* destroy                  */ Destroy,
    /* resize                   */ XtInheritResize,
    /* expose                   */ NULL,
    /* set_values               */ SetValues,
    /* set_values_hook          */ NULL,
    /* set_values_almost        */ XtInheritSetValuesAlmost,
    /* get_values_hook          */ NULL,
    /* accept_focus             */ NULL,
    /* version                  */ XtVersion,
    /* callback_private         */ NULL,
    /* tm_table                 */ NULL,
    /* query_geometry           */ XtInheritQueryGeometry,
    /* display_accelerator      */ NULL,
    /* extension                */ NULL
    },
    {				/* Menu Entry fields */
    /* highlight                */ XtInheritHighlight,
    /* unhighlight              */ XtInheritUnhighlight,
    /* notify                   */ XtInheritNotify,
    /* extension                */ NULL
    },
    {				/* threeD fields */
    /* shadow draw              */ _XawSme3dDrawShadows
    }
};

WidgetClass smeThreeDObjectClass = (WidgetClass) & smeThreeDClassRec;

/****************************************************************
 *
 * Private Procedures
 *
 ****************************************************************/

#define shadowpm_width 8
#define shadowpm_height 8
static char shadowpm_bits[] =
{
    '\252', '\125', '\252', '\125', '\252', '\125', '\252', '\125'};

static char mtshadowpm_bits[] =
{
    '\222', '\044', '\111', '\222', '\044', '\111', '\222', '\044'};

static char mbshadowpm_bits[] =
{
    '\155', '\333', '\266', '\155', '\333', '\266', '\155', '\333'};

/* ARGSUSED */
static void
AllocTopShadowGC(Widget w)
{
    SmeThreeDObject tdo = (SmeThreeDObject) w;
    Screen *scn = XtScreenOfObject(w);
    XtGCMask valuemask;
    XGCValues myXGCV;

    if (tdo->sme_threeD.be_nice_to_cmap || DefaultDepthOfScreen(scn) == 1) {
	valuemask = GCTile | GCFillStyle;
	myXGCV.tile = tdo->sme_threeD.top_shadow_pxmap;
	myXGCV.fill_style = FillTiled;
    } else {
	valuemask = GCForeground;
	myXGCV.foreground = tdo->sme_threeD.top_shadow_pixel;
    }
    tdo->sme_threeD.top_shadow_GC = XtGetGC(w, valuemask, &myXGCV);
}

/* ARGSUSED */
static void
AllocBotShadowGC(Widget w)
{
    SmeThreeDObject tdo = (SmeThreeDObject) w;
    Screen *scn = XtScreenOfObject(w);
    XtGCMask valuemask;
    XGCValues myXGCV;

    if (tdo->sme_threeD.be_nice_to_cmap || DefaultDepthOfScreen(scn) == 1) {
	valuemask = GCTile | GCFillStyle;
	myXGCV.tile = tdo->sme_threeD.bot_shadow_pxmap;
	myXGCV.fill_style = FillTiled;
    } else {
	valuemask = GCForeground;
	myXGCV.foreground = tdo->sme_threeD.bot_shadow_pixel;
    }
    tdo->sme_threeD.bot_shadow_GC = XtGetGC(w, valuemask, &myXGCV);
}

/* ARGSUSED */
static void
AllocEraseGC(Widget w)
{
    Widget parent = XtParent(w);
    SmeThreeDObject tdo = (SmeThreeDObject) w;
    XtGCMask valuemask;
    XGCValues myXGCV;

    valuemask = GCForeground;
    myXGCV.foreground = parent->core.background_pixel;
    tdo->sme_threeD.erase_GC = XtGetGC(w, valuemask, &myXGCV);
}

/* ARGSUSED */
static void
AllocTopShadowPixmap(Widget new)
{
    SmeThreeDObject tdo = (SmeThreeDObject) new;
    Widget parent = XtParent(new);
    Display *dpy = XtDisplayOfObject(new);
    Screen *scn = XtScreenOfObject(new);
    unsigned long top_fg_pixel = 0, top_bg_pixel = 0;
    char *pm_data = NULL;
    Boolean create_pixmap = FALSE;

    /*
     * I know, we're going to create two pixmaps for each and every
     * shadow'd widget.  Yeuck.  I'm semi-relying on server side
     * pixmap cacheing.
     */

    if (DefaultDepthOfScreen(scn) == 1) {
	top_fg_pixel = BlackPixelOfScreen(scn);
	top_bg_pixel = WhitePixelOfScreen(scn);
	pm_data = mtshadowpm_bits;
	create_pixmap = TRUE;
    } else if (tdo->sme_threeD.be_nice_to_cmap) {
	if (parent->core.background_pixel == WhitePixelOfScreen(scn)) {
	    top_fg_pixel = WhitePixelOfScreen(scn);
	    top_bg_pixel = BlackPixelOfScreen(scn);
	} else if (parent->core.background_pixel == BlackPixelOfScreen(scn)) {
	    top_fg_pixel = BlackPixelOfScreen(scn);
	    top_bg_pixel = WhitePixelOfScreen(scn);
	} else {
	    top_fg_pixel = parent->core.background_pixel;
	    top_bg_pixel = WhitePixelOfScreen(scn);
	}
	if (parent->core.background_pixel == WhitePixelOfScreen(scn) ||
	    parent->core.background_pixel == BlackPixelOfScreen(scn)) {
	    pm_data = mtshadowpm_bits;
	} else {
	    pm_data = shadowpm_bits;
	}
	create_pixmap = TRUE;
    }
    if (create_pixmap) {
	tdo->sme_threeD.top_shadow_pxmap
	    = XCreatePixmapFromBitmapData(dpy,
					  RootWindowOfScreen(scn),
					  pm_data,
					  shadowpm_width,
					  shadowpm_height,
					  top_fg_pixel,
					  top_bg_pixel,
					  (unsigned) DefaultDepthOfScreen(scn));
    }
}

/* ARGSUSED */
static void
AllocBotShadowPixmap(Widget new)
{
    SmeThreeDObject tdo = (SmeThreeDObject) new;
    Widget parent = XtParent(new);
    Display *dpy = XtDisplayOfObject(new);
    Screen *scn = XtScreenOfObject(new);
    unsigned long bot_fg_pixel = 0, bot_bg_pixel = 0;
    char *pm_data = NULL;
    Boolean create_pixmap = FALSE;

    if (DefaultDepthOfScreen(scn) == 1) {
	bot_fg_pixel = BlackPixelOfScreen(scn);
	bot_bg_pixel = WhitePixelOfScreen(scn);
	pm_data = mbshadowpm_bits;
	create_pixmap = TRUE;
    } else if (tdo->sme_threeD.be_nice_to_cmap) {
	if (parent->core.background_pixel == WhitePixelOfScreen(scn)) {
	    bot_fg_pixel = WhitePixelOfScreen(scn);
	    bot_bg_pixel = BlackPixelOfScreen(scn);
	} else if (parent->core.background_pixel == BlackPixelOfScreen(scn)) {
	    bot_fg_pixel = BlackPixelOfScreen(scn);
	    bot_bg_pixel = WhitePixelOfScreen(scn);
	} else {
	    bot_fg_pixel = parent->core.background_pixel;
	    bot_bg_pixel = BlackPixelOfScreen(scn);
	}
	if (parent->core.background_pixel == WhitePixelOfScreen(scn) ||
	    parent->core.background_pixel == BlackPixelOfScreen(scn)) {
	    pm_data = mbshadowpm_bits;
	} else {
	    pm_data = shadowpm_bits;
	}
	create_pixmap = TRUE;
    }
    if (create_pixmap) {
	tdo->sme_threeD.bot_shadow_pxmap
	    = XCreatePixmapFromBitmapData(dpy,
					  RootWindowOfScreen(scn),
					  pm_data,
					  shadowpm_width,
					  shadowpm_height,
					  bot_fg_pixel,
					  bot_bg_pixel,
					  (unsigned) DefaultDepthOfScreen(scn));
    }
}

/* ARGSUSED */
void
XawSme3dComputeTopShadowRGB(new, xcol_out)
     Widget new;
     XColor *xcol_out;
{
    if (XtIsSubclass(new, smeThreeDObjectClass)) {
	SmeThreeDObject tdo = (SmeThreeDObject) new;
	Widget w = XtParent(new);
	XColor get_c;
	double contrast;
	Display *dpy = XtDisplayOfObject(new);
	Screen *scn = XtScreenOfObject(new);
	Colormap cmap = DefaultColormapOfScreen(scn);

	get_c.pixel = w->core.background_pixel;
	if (get_c.pixel == WhitePixelOfScreen(scn) ||
	    get_c.pixel == BlackPixelOfScreen(scn)) {
	    contrast = (100 - tdo->sme_threeD.top_shadow_contrast) / 100.0;
	    xcol_out->red = (unsigned short) (contrast * 65535.0);
	    xcol_out->green = (unsigned short) (contrast * 65535.0);
	    xcol_out->blue = (unsigned short) (contrast * 65535.0);
	} else {
	    contrast = 1.0 + tdo->sme_threeD.top_shadow_contrast / 100.0;
	    XQueryColor(dpy, cmap, &get_c);
#define MIN(x,y) (unsigned short) ((x < y) ? x : y)
	    xcol_out->red = MIN(65535, (int) (contrast * (double) get_c.red));
	    xcol_out->green = MIN(65535, (int) (contrast * (double) get_c.green));
	    xcol_out->blue = MIN(65535, (int) (contrast * (double) get_c.blue));
#undef MIN
	}
    } else
	xcol_out->red = xcol_out->green = xcol_out->blue = 0;
}

/* ARGSUSED */
static void
AllocTopShadowPixel(Widget new)
{
    XColor set_c;
    SmeThreeDObject tdo = (SmeThreeDObject) new;
    Display *dpy = XtDisplayOfObject(new);
    Screen *scn = XtScreenOfObject(new);
    Colormap cmap = DefaultColormapOfScreen(scn);

    XawSme3dComputeTopShadowRGB(new, &set_c);
    (void) XAllocColor(dpy, cmap, &set_c);
    tdo->sme_threeD.top_shadow_pixel = set_c.pixel;
}

/* ARGSUSED */
void
XawSme3dComputeBottomShadowRGB(new, xcol_out)
     Widget new;
     XColor *xcol_out;
{
    if (XtIsSubclass(new, smeThreeDObjectClass)) {
	SmeThreeDObject tdo = (SmeThreeDObject) new;
	Widget w = XtParent(new);
	XColor get_c;
	double contrast;
	Display *dpy = XtDisplayOfObject(new);
	Screen *scn = XtScreenOfObject(new);
	Colormap cmap = DefaultColormapOfScreen(scn);

	get_c.pixel = w->core.background_pixel;
	if (get_c.pixel == WhitePixelOfScreen(scn) ||
	    get_c.pixel == BlackPixelOfScreen(scn)) {
	    contrast = tdo->sme_threeD.bot_shadow_contrast / 100.0;
	    xcol_out->red = (unsigned short) (contrast * 65535.0);
	    xcol_out->green = (unsigned short) (contrast * 65535.0);
	    xcol_out->blue = (unsigned short) (contrast * 65535.0);
	} else {
	    XQueryColor(dpy, cmap, &get_c);
	    contrast = (100 - tdo->sme_threeD.bot_shadow_contrast) / 100.0;
	    xcol_out->red = (unsigned short) (contrast * get_c.red);
	    xcol_out->green = (unsigned short) (contrast * get_c.green);
	    xcol_out->blue = (unsigned short) (contrast * get_c.blue);
	}
    } else
	xcol_out->red = xcol_out->green = xcol_out->blue = 0;
}

/* ARGSUSED */
static void
AllocBotShadowPixel(Widget new)
{
    XColor set_c;
    SmeThreeDObject tdo = (SmeThreeDObject) new;
    Display *dpy = XtDisplayOfObject(new);
    Screen *scn = XtScreenOfObject(new);
    Colormap cmap = DefaultColormapOfScreen(scn);

    XawSme3dComputeBottomShadowRGB(new, &set_c);
    (void) XAllocColor(dpy, cmap, &set_c);
    tdo->sme_threeD.bot_shadow_pixel = set_c.pixel;
}

/* ARGSUSED */
static void
ClassPartInitialize(WidgetClass wc)
{
    SmeThreeDClassRec *tdwc = (SmeThreeDClassRec *) wc;
    SmeThreeDClassRec *super =
    (SmeThreeDClassRec *) tdwc->rect_class.superclass;

    if (tdwc->sme_threeD_class.shadowdraw == XtInheritXawSme3dShadowDraw)
	tdwc->sme_threeD_class.shadowdraw = super->sme_threeD_class.shadowdraw;
}

/* ARGSUSED */
static void
Initialize(
	      Widget request GCC_UNUSED,
	      Widget new,
	      ArgList args GCC_UNUSED,
	      Cardinal *num_args GCC_UNUSED)
{
    SmeThreeDObject w = (SmeThreeDObject) new;
    Screen *scr = XtScreenOfObject(new);
    XGCValues gcv;

    if (w->sme_threeD.be_nice_to_cmap || DefaultDepthOfScreen(scr) == 1) {
	AllocTopShadowPixmap(new);
	AllocBotShadowPixmap(new);
    } else {
	if (w->sme_threeD.top_shadow_pixel == w->sme_threeD.bot_shadow_pixel) {
	    AllocTopShadowPixel(new);
	    AllocBotShadowPixel(new);
	}
	w->sme_threeD.top_shadow_pxmap = w->sme_threeD.bot_shadow_pxmap = 0;
    }
    AllocTopShadowGC(new);
    AllocBotShadowGC(new);
    AllocEraseGC(new);
    /* alloc highlight back (move this out from here if it get's bigger) */
    w->sme_threeD.top_half_shadow_pixel = WhitePixelOfScreen(XtScreen(new));
    gcv.foreground = w->sme_threeD.top_half_shadow_pixel;
    w->sme_threeD.top_half_shadow_GC = XtGetGC(new, GCForeground, &gcv);
}

static void
Destroy(Widget gw)
{
    SmeThreeDObject w = (SmeThreeDObject) gw;
    XtReleaseGC(gw, w->sme_threeD.top_shadow_GC);
    XtReleaseGC(gw, w->sme_threeD.top_half_shadow_GC);
    XtReleaseGC(gw, w->sme_threeD.bot_shadow_GC);
    XtReleaseGC(gw, w->sme_threeD.erase_GC);
    if (w->sme_threeD.top_shadow_pxmap)
	XFreePixmap(XtDisplayOfObject(gw), w->sme_threeD.top_shadow_pxmap);
    if (w->sme_threeD.bot_shadow_pxmap)
	XFreePixmap(XtDisplayOfObject(gw), w->sme_threeD.bot_shadow_pxmap);
}

/* ARGSUSED */
static Boolean
SetValues(
	     Widget gcurrent,
	     Widget grequest GCC_UNUSED,
	     Widget gnew,
	     ArgList args GCC_UNUSED,
	     Cardinal *num_args GCC_UNUSED)
{
    SmeThreeDObject current = (SmeThreeDObject) gcurrent;
    SmeThreeDObject new = (SmeThreeDObject) gnew;
    Boolean redisplay = FALSE;
    Boolean alloc_top_pixel = FALSE;
    Boolean alloc_bot_pixel = FALSE;
    Boolean alloc_top_pixmap = FALSE;
    Boolean alloc_bot_pixmap = FALSE;

    if (new->sme_threeD.shadow_width != current->sme_threeD.shadow_width)
	redisplay = TRUE;
    if (new->sme_threeD.be_nice_to_cmap != current->sme_threeD.be_nice_to_cmap) {
	if (new->sme_threeD.be_nice_to_cmap) {
	    alloc_top_pixmap = TRUE;
	    alloc_bot_pixmap = TRUE;
	} else {
	    alloc_top_pixel = TRUE;
	    alloc_bot_pixel = TRUE;
	}
	redisplay = TRUE;
    }
    if (!new->sme_threeD.be_nice_to_cmap &&
	new->sme_threeD.top_shadow_contrast != current->sme_threeD.top_shadow_contrast)
	alloc_top_pixel = TRUE;
    if (!new->sme_threeD.be_nice_to_cmap &&
	new->sme_threeD.bot_shadow_contrast != current->sme_threeD.bot_shadow_contrast)
	alloc_bot_pixel = TRUE;
    if (alloc_top_pixel)
	AllocTopShadowPixel(gnew);
    if (alloc_bot_pixel)
	AllocBotShadowPixel(gnew);
    if (alloc_top_pixmap)
	AllocTopShadowPixmap(gnew);
    if (alloc_bot_pixmap)
	AllocBotShadowPixmap(gnew);
    if (!new->sme_threeD.be_nice_to_cmap &&
	new->sme_threeD.top_shadow_pixel != current->sme_threeD.top_shadow_pixel)
	alloc_top_pixel = TRUE;
    if (!new->sme_threeD.be_nice_to_cmap &&
	new->sme_threeD.bot_shadow_pixel != current->sme_threeD.bot_shadow_pixel)
	alloc_bot_pixel = TRUE;
    if (new->sme_threeD.be_nice_to_cmap) {
	if (alloc_top_pixmap) {
	    XtReleaseGC(gcurrent, current->sme_threeD.top_shadow_GC);
	    AllocTopShadowGC(gnew);
	    redisplay = True;
	}
	if (alloc_bot_pixmap) {
	    XtReleaseGC(gcurrent, current->sme_threeD.bot_shadow_GC);
	    AllocBotShadowGC(gnew);
	    redisplay = True;
	}
    } else {
	if (alloc_top_pixel) {
	    if (new->sme_threeD.top_shadow_pxmap) {
		XFreePixmap(XtDisplayOfObject(gnew), new->sme_threeD.top_shadow_pxmap);
		new->sme_threeD.top_shadow_pxmap = (Pixmap) NULL;
	    }
	    XtReleaseGC(gcurrent, current->sme_threeD.top_shadow_GC);
	    AllocTopShadowGC(gnew);
	    redisplay = True;
	}
	if (alloc_bot_pixel) {
	    if (new->sme_threeD.bot_shadow_pxmap) {
		XFreePixmap(XtDisplayOfObject(gnew), new->sme_threeD.bot_shadow_pxmap);
		new->sme_threeD.bot_shadow_pxmap = (Pixmap) NULL;
	    }
	    XtReleaseGC(gcurrent, current->sme_threeD.bot_shadow_GC);
	    AllocBotShadowGC(gnew);
	    redisplay = True;
	}
    }
    return (redisplay);
}

/* ARGSUSED */
static void
_XawSme3dDrawShadows(Widget gw)
{
    SmeThreeDObject tdo = (SmeThreeDObject) gw;
    Dimension s = tdo->sme_threeD.shadow_width;

    /*
     * draw the shadows using the core part width and height,
     * and the threeD part shadow_width.
     *
     *  no point to do anything if the shadow_width is 0 or the
     *  widget has not been realized.
     */
    if ((s > 0) && XtIsRealized(gw)) {

	Dimension h = tdo->rectangle.height;
	Dimension w = tdo->rectangle.width;
	Dimension x = (Dimension) tdo->rectangle.x;
	Dimension y = (Dimension) tdo->rectangle.y;
	Display *dpy = XtDisplayOfObject(gw);
	Window win = XtWindowOfObject(gw);

	/* draw only the background */
	XFillRectangle(dpy, win, tdo->sme_threeD.top_half_shadow_GC,
		       x, y, w, h);
	return;
    }
}
