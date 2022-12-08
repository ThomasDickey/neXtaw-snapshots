/***********************************************************

Copyright (c) 2015,2022 by Thomas E. Dickey
Copyright (c) 1999 by Carlos A M dos Santos
Copyright (c) 1996 by Alfredo Kojima
Copyright (c) 1987, 1988, 1994  X Consortium

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization. 

Copyright 1987, 1988 by Digital Equipment Corporation, Maynard, Massachusetts.

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its 
documentation for any purpose and without fee is hereby granted, 
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in 
supporting documentation, and that the name of Digital not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.  

DIGITAL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
DIGITAL BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

******************************************************************/

#include "private.h"

#include <stdio.h>

#include <X11/Xatom.h>
#include <X11/IntrinsicP.h>
#include <X11/StringDefs.h>
#include "XawInit.h"
#include "AsciiSinkP.h"
#include "AsciiSrcP.h"		/* For source function defs. */
#include "TextP.h"		/* I also reach into the text widget. */

#ifdef GETLASTPOS
#undef GETLASTPOS		/* We will use our own GETLASTPOS. */
#endif

#define GETLASTPOS XawTextSourceScan(source, (XawTextPosition) 0, XawstAll, XawsdRight, 1, TRUE)
/* *INDENT-OFF* */
static void Initialize(Widget, Widget, ArgList, Cardinal *);
static void Destroy(Widget);
static Boolean SetValues(Widget, Widget, Widget, ArgList, Cardinal *);
static int MaxLines(Widget, Dimension);
static int MaxHeight(Widget, int);
static void SetTabs(Widget , int , short *);

static void DisplayText(Widget, Position, Position, XawTextPosition, XawTextPosition, Boolean);
static void InsertCursor(Widget, Position, Position, XawTextInsertState);
static void FindPosition(Widget, XawTextPosition, int, int, Boolean, XawTextPosition *, int *, int *);
static void FindDistance(Widget, XawTextPosition, int, XawTextPosition, int *, XawTextPosition *, int *);
static void Resolve(Widget, XawTextPosition, int, int, XawTextPosition *, XawTextPosition *);
static void GetCursorBounds(Widget, XRectangle *);
/* *INDENT-ON* */

#define offset(field) XtOffsetOf(AsciiSinkRec, ascii_sink.field)

static XtResource resources[] =
{
    {XtNfont, XtCFont, XtRFontStruct, sizeof(XFontStruct *),
     offset(font), XtRString, DeConst(XtDefaultFont)},
    {XtNecho, XtCOutput, XtRBoolean, sizeof(Boolean),
     offset(echo), XtRImmediate, (XtPointer) True},
    {XtNblinkInterval, XtCBlinkInterval, XtRDimension, sizeof(unsigned long),
     offset(blink_interval), XtRImmediate, (XtPointer) 600},
    {XtNdisplayNonprinting, XtCOutput, XtRBoolean, sizeof(Boolean),
     offset(display_nonprinting), XtRImmediate, (XtPointer) True},
};
#undef offset

#define SuperClass		(&textSinkClassRec)
AsciiSinkClassRec asciiSinkClassRec =
{
    {
/* core_class fields */
    /* superclass               */ (WidgetClass) SuperClass,
    /* class_name               */ "AsciiSink",
    /* widget_size              */ sizeof(AsciiSinkRec),
    /* class_initialize         */ XawInitializeWidgetSet,
    /* class_part_initialize    */ NULL,
    /* class_inited             */ FALSE,
    /* initialize               */ Initialize,
    /* initialize_hook          */ NULL,
    /* obj1                     */ NULL,
    /* obj2                     */ NULL,
    /* obj3                     */ 0,
    /* resources                */ resources,
    /* num_resources            */ XtNumber(resources),
    /* xrm_class                */ NULLQUARK,
    /* obj4                     */ FALSE,
    /* obj5                     */ FALSE,
    /* obj6                     */ FALSE,
    /* obj7                     */ FALSE,
    /* destroy                  */ Destroy,
    /* obj8                     */ NULL,
    /* obj9                     */ NULL,
    /* set_values               */ SetValues,
    /* set_values_hook          */ NULL,
    /* obj10                    */ NULL,
    /* get_values_hook          */ NULL,
    /* obj11                    */ NULL,
    /* version                  */ XtVersion,
    /* callback_private         */ NULL,
    /* obj12                    */ NULL,
    /* obj13                    */ NULL,
    /* obj14                    */ NULL,
    /* extension                */ NULL
    },
/* text_sink_class fields */
    {
    /* DisplayText              */ DisplayText,
    /* InsertCursor             */ InsertCursor,
    /* ClearToBackground        */ XtInheritClearToBackground,
    /* FindPosition             */ FindPosition,
    /* FindDistance             */ FindDistance,
    /* Resolve                  */ Resolve,
    /* MaxLines                 */ MaxLines,
    /* MaxHeight                */ MaxHeight,
    /* SetTabs                  */ SetTabs,
    /* GetCursorBounds          */ GetCursorBounds
    },
/* ascii_sink_class fields */
    {
    /* unused                   */ 0
    }
};

WidgetClass asciiSinkObjectClass = (WidgetClass) & asciiSinkClassRec;

/* Utilities */

static int
CharWidth(
	     Widget w,
	     int x,
	     unsigned char c)
{
    int i, width, nonPrinting;
    AsciiSinkObject sink = (AsciiSinkObject) w;
    XFontStruct *font = sink->ascii_sink.font;
    Position *tab;

    if (c == XawLF)
	return (0);

    if (c == XawTAB) {
	/* Adjust for Left Margin. */
	x -= ((TextWidget) XtParent(w))->text.margin.left;

	if (x >= (int) XtParent(w)->core.width)
	    return 0;
	for (i = 0, tab = sink->text_sink.tabs;
	     i < sink->text_sink.tab_count; i++, tab++) {
	    if (x < *tab) {
		if (*tab < (int) XtParent(w)->core.width)
		    return *tab - x;
		else
		    return 0;
	    }
	}
	return 0;
    }

    if ((nonPrinting = (c < (unsigned char) XawSP))) {
	if (sink->ascii_sink.display_nonprinting) {
	    c = (unsigned char) (c + '@');
	} else {
	    c = XawSP;
	    nonPrinting = False;
	}
    }

    if (font->per_char &&
	(c >= font->min_char_or_byte2 && c <= font->max_char_or_byte2))
	width = font->per_char[c - font->min_char_or_byte2].width;
    else
	width = font->min_bounds.width;

    if (nonPrinting)
	width += CharWidth(w, x, (unsigned char) '^');

    return width;
}

/*	Function Name: PaintText
 *	Description: Actually paints the text into the windoe.
 *	Arguments: w - the text widget.
 *                 gc - gc to paint text with.
 *                 x, y - location to paint the text.
 *                 buf, len - buffer and length of text to paint.
 *	Returns: the width of the text painted, or 0.
 *
 * NOTE:  If this string attempts to paint past the end of the window
 *        then this function will return zero.
 */

static Dimension
PaintText(
	     Widget w,
	     GC gc,
	     Position x, Position y,
	     unsigned char *buf,
	     int len)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    TextWidget ctx = (TextWidget) XtParent(w);

    Position max_x;
    Dimension width = (Dimension) XTextWidth(sink->ascii_sink.font,
					     (char *) buf, len);
    max_x = (Position) ctx->core.width;

    if (((int) width) <= -x)	/* Don't draw if we can't see it. */
	return (width);

    XDrawImageString(XtDisplay(ctx), XtWindow(ctx), gc,
		     (int) x, (int) y, (char *) buf, len);
    if ((((Position) width + x) > max_x) && (ctx->text.margin.right != 0)) {
	x = (Position) (ctx->core.width - ctx->text.margin.right);
	width = (Dimension) ctx->text.margin.right;
	XFillRectangle(XtDisplay((Widget) ctx), XtWindow((Widget) ctx),
		       sink->ascii_sink.normgc, (int) x,
		       (int) y - sink->ascii_sink.font->ascent,
		       (unsigned int) width,
		       (unsigned int) (sink->ascii_sink.font->ascent +
				       sink->ascii_sink.font->descent));
	return (0);
    }
    return (width);
}

/* Sink Object Functions */

/*
 * This function does not know about drawing more than one line of text.
 */

static void
DisplayText(
	       Widget w,
	       Position x, Position y,
	       XawTextPosition pos1, XawTextPosition pos2,
	       Boolean highlight)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    Widget source = XawTextGetSource(XtParent(w));
    unsigned char buf[BUFSIZ];

    int j, k;
    XawTextBlock blk;
    GC gc = highlight ? sink->ascii_sink.invgc : sink->ascii_sink.normgc;
    GC invgc = highlight ? sink->ascii_sink.normgc : sink->ascii_sink.invgc;

    if (!sink->ascii_sink.echo)
	return;

    y = (Position) (y + sink->ascii_sink.font->ascent);
    for (j = 0; pos1 < pos2;) {
	pos1 = XawTextSourceRead(source, pos1, &blk, (int) (pos2 - pos1));
	for (k = 0; k < blk.length; k++) {
	    if (j >= BUFSIZ) {	/* buffer full, dump the text. */
		x = (Position) (x + PaintText(w, gc, x, y, buf, j));
		j = 0;
	    }
	    buf[j] = (unsigned char) blk.ptr[k];
	    if (buf[j] == XawLF)	/* line feeds ('\n') are not printed. */
		continue;

	    else if (buf[j] == '\t') {
		Position temp = 0;
		Dimension width;

		if ((j != 0) && ((temp = (Position) PaintText(w, gc, x, y,
							      buf, j)) == 0))
		    return;

		x = (Position) (x + temp);
		width = (Dimension) CharWidth(w, x, (unsigned char) '\t');
		XFillRectangle(XtDisplayOfObject(w), XtWindowOfObject(w),
			       invgc, (int) x,
			       (int) y - sink->ascii_sink.font->ascent,
			       (unsigned int) width,
			       (unsigned int) (sink->ascii_sink.font->ascent +
					       sink->ascii_sink.font->descent));
		x = (Position) (x + width);
		j = -1;
	    } else if (buf[j] < (unsigned char) ' ') {
		if (sink->ascii_sink.display_nonprinting) {
		    buf[j + 1] = (unsigned char) (buf[j] + '@');
		    buf[j] = '^';
		    j++;
		} else
		    buf[j] = ' ';
	    }
	    j++;
	}
    }
    if (j > 0)
	(void) PaintText(w, gc, x, y, buf, j);
}

#define insertCursor_width 5

/*	Function Name: GetCursorBounds
 *	Description: Returns the size and location of the cursor.
 *	Arguments: w - the text object.
 * RETURNED        rect - an X rectangle to return the cursor bounds in.
 *	Returns: none.
 */

static void
GetCursorBounds(
		   Widget w,
		   XRectangle * rect)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;

    rect->width = (unsigned short) insertCursor_width;
    rect->height = (unsigned short) (sink->ascii_sink.font->ascent
				     + sink->ascii_sink.font->descent);
    rect->x = (short) (sink->ascii_sink.cursor_x - (rect->width / 2));
    rect->y = (short) (sink->ascii_sink.cursor_y - rect->height);
}

/*
 * The following procedure manages the "insert" cursor.
 */

static void
InsertCursor(
		Widget w,
		Position x, Position y,
		XawTextInsertState state)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    Widget text_widget = XtParent(w);
    XRectangle rect;

    sink->ascii_sink.cursor_x = x;
    sink->ascii_sink.cursor_y = y;

    rect.width = (unsigned short) insertCursor_width;
    rect.height = (unsigned short) (sink->ascii_sink.font->ascent
				    + sink->ascii_sink.font->descent);

    rect.x = (short) (x - (rect.width / 2));
    rect.y = (short) (y - rect.height);

    if (state != sink->ascii_sink.laststate && XtIsRealized(text_widget)) {
	XDrawLine(XtDisplay(text_widget), XtWindow(text_widget),
		  sink->ascii_sink.xorgc, rect.x + rect.width / 2,
		  rect.y, rect.x + rect.width / 2, rect.y + rect.height - 1);
    }
    sink->ascii_sink.laststate = state;
}

/*
 * Given two positions, find the distance between them.
 */

static void
FindDistance(
		Widget w,
		XawTextPosition fromPos,	/* First position. */
		int fromx,	/* Horizontal location of first position. */
		XawTextPosition toPos,	/* Second position. */
		int *resWidth,	/* Distance between fromPos and resPos. */
		XawTextPosition * resPos,	/* Actual second position used. */
		int *resHeight)	/* Height required. */
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    Widget source = XawTextGetSource(XtParent(w));

    XawTextPosition inx, lastPos;
    unsigned char c;
    XawTextBlock blk;

    /* we may not need this */
    lastPos = GETLASTPOS;
    XawTextSourceRead(source, fromPos, &blk, (int) (toPos - fromPos));
    *resWidth = 0;
    for (inx = fromPos; inx != toPos && inx < lastPos; inx++) {
	if (inx - blk.firstPos >= blk.length)
	    XawTextSourceRead(source, inx, &blk, (int) (toPos - fromPos));
	c = (unsigned char) blk.ptr[inx - blk.firstPos];
	*resWidth += CharWidth(w, fromx + *resWidth, c);
	if (c == XawLF) {
	    inx++;
	    break;
	}
    }
    *resPos = inx;
    *resHeight = sink->ascii_sink.font->ascent + sink->ascii_sink.font->descent;
}

static void
FindPosition(
		Widget w,
		XawTextPosition fromPos,	/* Starting position. */
		int fromx,	/* Horizontal location of starting position. */
		int width,	/* Desired width. */
		Boolean stopAtWordBreak,	/* Whether the resulting position should be at
						   a word break. */
		XawTextPosition * resPos,	/* Resulting position. */
		int *resWidth,	/* Actual width used. */
		int *resHeight)	/* Height required. */
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    Widget source = XawTextGetSource(XtParent(w));

    XawTextPosition lastPos, inx, whiteSpacePosition = 0;
    int lastWidth = 0, whiteSpaceWidth = 0;
    Boolean whiteSpaceSeen;
    unsigned char c;
    XawTextBlock blk;

    lastPos = GETLASTPOS;

    XawTextSourceRead(source, fromPos, &blk, BUFSIZ);
    *resWidth = 0;
    whiteSpaceSeen = FALSE;
    c = 0;
    for (inx = fromPos; *resWidth <= width && inx < lastPos; inx++) {
	lastWidth = *resWidth;
	if (inx - blk.firstPos >= blk.length)
	    XawTextSourceRead(source, inx, &blk, BUFSIZ);
	c = (unsigned char) blk.ptr[inx - blk.firstPos];
	*resWidth += CharWidth(w, fromx + *resWidth, c);

	if ((c == XawSP || c == XawTAB) && *resWidth <= width) {
	    whiteSpaceSeen = TRUE;
	    whiteSpacePosition = inx;
	    whiteSpaceWidth = *resWidth;
	}
	if (c == XawLF) {
	    inx++;
	    break;
	}
    }
    if (*resWidth > width && inx > fromPos) {
	*resWidth = lastWidth;
	inx--;
	if (stopAtWordBreak && whiteSpaceSeen) {
	    inx = whiteSpacePosition + 1;
	    *resWidth = whiteSpaceWidth;
	}
    }
    if (inx == lastPos && c != XawLF)
	inx = lastPos + 1;
    *resPos = inx;
    *resHeight = sink->ascii_sink.font->ascent + sink->ascii_sink.font->descent;
}

static void
Resolve(
	   Widget w,
	   XawTextPosition pos,
	   int fromx, int width,
	   XawTextPosition * leftPos, XawTextPosition * rightPos)
{
    int resWidth, resHeight;
    Widget source = XawTextGetSource(XtParent(w));

    FindPosition(w, pos, fromx, width, FALSE, leftPos, &resWidth, &resHeight);
    if (*leftPos > GETLASTPOS)
	*leftPos = GETLASTPOS;
    *rightPos = *leftPos;
}

static void
GetGC(
	 AsciiSinkObject sink)
{
    XtGCMask valuemask = (GCFont |
			  GCGraphicsExposures | GCForeground | GCBackground);
    XGCValues values;

    values.font = sink->ascii_sink.font->fid;
    values.graphics_exposures = (Bool) FALSE;
    values.foreground = sink->text_sink.foreground;
    values.background = sink->text_sink.background;
    sink->ascii_sink.normgc = XtGetGC((Widget) sink, valuemask, &values);

    values.foreground = sink->text_sink.background;
    values.background = sink->text_sink.foreground;
    sink->ascii_sink.invgc = XtGetGC((Widget) sink, valuemask, &values);

    values.function = GXxor;
    values.background = (unsigned long) 0L;	/* (pix ^ 0) = pix */
    values.foreground = (sink->text_sink.background ^
			 sink->text_sink.foreground);
    values.line_width = 2;
    valuemask = GCGraphicsExposures | GCFunction | GCForeground | GCBackground
	| GCLineWidth;

    sink->ascii_sink.xorgc = XtGetGC((Widget) sink, valuemask, &values);
}

/***** Public routines *****/

/*	Function Name: Initialize
 *	Description: Initializes the TextSink Object.
 *	Arguments: request, new - the requested and new values for the object
 *                                instance.
 *	Returns: none.
 *
 */

/* ARGSUSED */
static void
Initialize(
	      Widget request GCC_UNUSED, Widget new,
	      ArgList args GCC_UNUSED,
	      Cardinal *num_args GCC_UNUSED)
{
    AsciiSinkObject sink = (AsciiSinkObject) new;

    GetGC(sink);
    sink->ascii_sink.insertCursorOn = None;
    sink->ascii_sink.laststate = XawisOff;
    sink->ascii_sink.lastlaststate = XawisOff;
    sink->ascii_sink.blinking = False;
    sink->ascii_sink.cursor_x = sink->ascii_sink.cursor_y = 0;

    if (sink->ascii_sink.blink_interval <= 0)
	sink->ascii_sink.timer_id = (XtIntervalId) 0;
    else
	sink->ascii_sink.timer_id =
	    XtAppAddTimeOut(XtWidgetToApplicationContext((Widget) sink),
			    (unsigned long) sink->ascii_sink.blink_interval,
			    _Xaw_BlinkCursor,
			    (XtPointer) ((Widget) sink));
}

/*	Function Name: Destroy
 *	Description: This function cleans up when the object is 
 *                   destroyed.
 *	Arguments: w - the AsciiSink Object.
 *	Returns: none.
 */

static void
Destroy(
	   Widget w)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;

    if (sink->ascii_sink.timer_id != (XtIntervalId) 0)
	XtRemoveTimeOut(sink->ascii_sink.timer_id);
    XtReleaseGC(w, sink->ascii_sink.normgc);
    XtReleaseGC(w, sink->ascii_sink.invgc);
    XtReleaseGC(w, sink->ascii_sink.xorgc);
    if (sink->ascii_sink.insertCursorOn != None)
	XFreePixmap(XtDisplayOfObject(w), sink->ascii_sink.insertCursorOn);
}

/*	Function Name: SetValues
 *	Description: Sets the values for the AsciiSink
 *	Arguments: current - current state of the object.
 *                 request - what was requested.
 *                 new - what the object will become.
 *	Returns: True if redisplay is needed.
 */

/* ARGSUSED */
static Boolean
SetValues(
	     Widget current, Widget request GCC_UNUSED, Widget new,
	     ArgList args GCC_UNUSED,
	     Cardinal *num_args GCC_UNUSED)
{
    AsciiSinkObject w = (AsciiSinkObject) new;
    AsciiSinkObject old_w = (AsciiSinkObject) current;

    if (w->ascii_sink.font != old_w->ascii_sink.font
	|| w->text_sink.background != old_w->text_sink.background
	|| w->text_sink.foreground != old_w->text_sink.foreground) {
	XtReleaseGC((Widget) w, w->ascii_sink.normgc);
	XtReleaseGC((Widget) w, w->ascii_sink.invgc);
	XtReleaseGC((Widget) w, w->ascii_sink.xorgc);
	GetGC(w);
	((TextWidget) XtParent(new))->text.redisplay_needed = True;
    } else {
	if ((w->ascii_sink.echo != old_w->ascii_sink.echo) ||
	    (w->ascii_sink.display_nonprinting !=
	     old_w->ascii_sink.display_nonprinting))
	    ((TextWidget) XtParent(new))->text.redisplay_needed = True;
    }

    return False;
}

/*	Function Name: MaxLines
 *	Description: Finds the Maximum number of lines that will fit in
 *                   a given height.
 *	Arguments: w - the AsciiSink Object.
 *                 height - height to fit lines into.
 *	Returns: the number of lines that will fit.
 */

/* ARGSUSED */
static int
MaxLines(
	    Widget w,
	    Dimension height)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    int font_height;

    font_height = sink->ascii_sink.font->ascent + sink->ascii_sink.font->descent;
    return (((int) height) / font_height);
}

/*	Function Name: MaxHeight
 *	Description: Finds the Minium height that will contain a given number 
 *                   lines.
 *	Arguments: w - the AsciiSink Object.
 *                 lines - the number of lines.
 *	Returns: the height.
 */

/* ARGSUSED */
static int
MaxHeight(
	     Widget w,
	     int lines)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;

    return (lines * (sink->ascii_sink.font->ascent +
		     sink->ascii_sink.font->descent));
}

/*	Function Name: SetTabs
 *	Description: Sets the Tab stops.
 *	Arguments: w - the AsciiSink Object.
 *                 tab_count - the number of tabs in the list.
 *                 tabs - the text positions of the tabs.
 *	Returns: none
 */

static void
SetTabs(
	   Widget w,
	   int tab_count,
	   short *tabs)
{
    AsciiSinkObject sink = (AsciiSinkObject) w;
    int i;
    Atom XA_FIGURE_WIDTH;
    unsigned long figure_width = 0;
    XFontStruct *font = sink->ascii_sink.font;

/*
 * Find the figure width of the current font.
 */

    XA_FIGURE_WIDTH = XInternAtom(XtDisplayOfObject(w), "FIGURE_WIDTH", FALSE);
    if ((XA_FIGURE_WIDTH != None) &&
	((!XGetFontProperty(font, XA_FIGURE_WIDTH, &figure_width)) ||
	 (figure_width == 0))) {
	if (font->per_char && font->min_char_or_byte2 <= '$' &&
	    font->max_char_or_byte2 >= '$')
	    figure_width = (unsigned long) font->per_char['$' -
							  font->min_char_or_byte2].width;
	else
	    figure_width = (unsigned long) font->max_bounds.width;
    }

    if (tab_count > sink->text_sink.tab_count) {
	sink->text_sink.tabs = (Position *) (void *)
	    XtRealloc((void *) sink->text_sink.tabs,
		      (Cardinal) ((size_t) tab_count * sizeof(Position)));
	sink->text_sink.char_tabs = (short *) (void *)
	    XtRealloc((void *) sink->text_sink.char_tabs,
		      (Cardinal) ((size_t) tab_count * sizeof(short)));
    }

    for (i = 0; i < tab_count; i++) {
	sink->text_sink.tabs[i] = (Position) ((unsigned long) tabs[i] * figure_width);
	sink->text_sink.char_tabs[i] = tabs[i];
    }

    sink->text_sink.tab_count = tab_count;

#ifndef NO_TAB_FIX
    {
	TextWidget ctx = (TextWidget) XtParent(w);
	ctx->text.redisplay_needed = True;
	_XawTextBuildLineTable(ctx, ctx->text.lt.top, TRUE);
    }
#endif
}

/* blink cursor */
void
_Xaw_BlinkCursor(
		    XtPointer client_data,
		    XtIntervalId * idp GCC_UNUSED)
{
#define BLINK_ON 1
#define BLINK_OFF 0
    AsciiSinkObject sink = (AsciiSinkObject) client_data;
    static int call_data;
    unsigned long interval;

    /* fprintf(stderr, "_Xaw_BlinkCursor\n"); */
    if (call_data == BLINK_ON) {
	call_data = BLINK_OFF;
	interval = sink->ascii_sink.blink_interval / 2;
    } else {
	call_data = BLINK_ON;
	interval = sink->ascii_sink.blink_interval;
    }
#if 0
    if (XtIsRealized(XtParent((Widget) sink))) {
/*	if (!ctx->text.hasfocus) {
	    printf("nofoc\n");
	    if (!sink->ascii_sink.lastlaststate) {
		InsertCursor ((Widget)sink, sink->ascii_sink.cursor_x,
				sink->ascii_sink.cursor_y);
	    }
	} else*/  {
	    printf("bli %i\n", sink->ascii_sink.laststate);
	    if (!sink->ascii_sink.laststate) {
		if (!sink->ascii_sink.blinking) {
		    sink->ascii_sink.blinking = True;
		    sink->ascii_sink.lastlaststate = XawisOn;
		}
		printf("%i\n", sink->ascii_sink.lastlaststate);
		sink->ascii_sink.lastlaststate = !sink->ascii_sink.lastlaststate;
		InsertCursor((Widget) sink, sink->ascii_sink.cursor_x,
			     sink->ascii_sink.cursor_y);
	    } else if (sink->ascii_sink.lastlaststate) {
		printf("disablin\n");
		InsertCursor((Widget) sink, sink->ascii_sink.cursor_x,
			     sink->ascii_sink.cursor_y);
		sink->ascii_sink.lastlaststate = XawisOff;
		sink->ascii_sink.blinking = False;
	    }
	}
    }

    sink->ascii_sink.timer_id =
	XtAppAddTimeOut(XtWidgetToApplicationContext((Widget) sink),
			(unsigned long) interval,
			_Xaw_BlinkCursor,
			client_data);
#endif
}
