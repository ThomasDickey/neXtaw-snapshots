/*

Copyright 2015 by Thomas E. Dickey
Copyright (c) 1996 by Alfredo Kojima
Copyright (c) 1989, 1994  X Consortium

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

*/

/*
 * Author:  Chris Peterson, MIT X Consortium.
 * Much code taken from X11R3 String and Disk Sources.
 */

/*
 * TextSrc.c - TextSrc object. (For use with the text widget).
 *
 */

#include "private.h"

#include <X11/IntrinsicP.h>
#include <X11/StringDefs.h>
#include <X11/Xutil.h>
#include "XawInit.h"
#include "TextSrcP.h"
#include <X11/Xmu/Atoms.h>
#include <X11/Xmu/CharSet.h>
#include "XawI18n.h"
#include <stdio.h>
#include <ctype.h>

/****************************************************************
 *
 * Full class record constant
 *
 ****************************************************************/

/* Private Data */

#define offset(field) XtOffsetOf(TextSrcRec, textSrc.field)
static XtResource resources[] =
{
    {XtNeditType, XtCEditType, XtREditMode, sizeof(XawTextEditType),
     offset(edit_mode), XtRString, "read"},
};
/* *INDENT-OFF* */
static void ClassInitialize(void);
static void ClassPartInitialize(WidgetClass);
static void SetSelection(Widget, XawTextPosition, XawTextPosition, Atom);
static void CvtStringToEditMode(XrmValuePtr, Cardinal*, XrmValuePtr, XrmValuePtr);
static Boolean ConvertSelection(Widget, Atom *, Atom *, Atom *, XtPointer *, unsigned long *, int *);
static XawTextPosition Search(Widget, XawTextPosition, XawTextScanDirection, XawTextBlock *);
static XawTextPosition Scan(Widget, XawTextPosition, XawTextScanType, XawTextScanDirection, int, Boolean);
static XawTextPosition Read(Widget, XawTextPosition, XawTextBlock *, int);
static int Replace(Widget, XawTextPosition, XawTextPosition, XawTextBlock *);
/* *INDENT-ON* */

#define SuperClass		(&objectClassRec)
TextSrcClassRec textSrcClassRec =
{
    {
/* core_class fields */
    /* superclass               */ (WidgetClass) SuperClass,
    /* class_name               */ "TextSrc",
    /* widget_size              */ sizeof(TextSrcRec),
    /* class_initialize         */ ClassInitialize,
    /* class_part_initialize    */ ClassPartInitialize,
    /* class_inited             */ FALSE,
    /* initialize               */ NULL,
    /* initialize_hook          */ NULL,
    /* realize                  */ NULL,
    /* actions                  */ NULL,
    /* num_actions              */ 0,
    /* resources                */ resources,
    /* num_resources            */ XtNumber(resources),
    /* xrm_class                */ NULLQUARK,
    /* compress_motion          */ FALSE,
    /* compress_exposure        */ FALSE,
    /* compress_enterleave      */ FALSE,
    /* visible_interest         */ FALSE,
    /* destroy                  */ NULL,
    /* resize                   */ NULL,
    /* expose                   */ NULL,
    /* set_values               */ NULL,
    /* set_values_hook          */ NULL,
    /* set_values_almost        */ NULL,
    /* get_values_hook          */ NULL,
    /* accept_focus             */ NULL,
    /* version                  */ XtVersion,
    /* callback_private         */ NULL,
    /* tm_table                 */ NULL,
    /* query_geometry           */ NULL,
    /* display_accelerator      */ NULL,
    /* extension                */ NULL,
    },
/* textSrc_class fields */
    {
    /* Read                     */ Read,
    /* Replace                  */ Replace,
    /* Scan                     */ Scan,
    /* Search                   */ Search,
    /* SetSelection             */ SetSelection,
    /* ConvertSelection         */ ConvertSelection
    }
};

WidgetClass textSrcObjectClass = (WidgetClass) & textSrcClassRec;

static void
ClassInitialize(void)
{
    XawInitializeWidgetSet();
    XtAddConverter(XtRString, XtREditMode, CvtStringToEditMode, NULL, 0);
}

static void
ClassPartInitialize(WidgetClass wc)
{
    TextSrcObjectClass t_src, superC;

    t_src = (TextSrcObjectClass) wc;
    superC = (TextSrcObjectClass) t_src->object_class.superclass;

    /*
     * We don't need to check for null super since we'll get to TextSrc
     * eventually.
     */
    if (t_src->textSrc_class.Read == XtInheritRead)
	t_src->textSrc_class.Read = superC->textSrc_class.Read;

    if (t_src->textSrc_class.Replace == XtInheritReplace)
	t_src->textSrc_class.Replace = superC->textSrc_class.Replace;

    if (t_src->textSrc_class.Scan == XtInheritScan)
	t_src->textSrc_class.Scan = superC->textSrc_class.Scan;

    if (t_src->textSrc_class.Search == XtInheritSearch)
	t_src->textSrc_class.Search = superC->textSrc_class.Search;

    if (t_src->textSrc_class.SetSelection == XtInheritSetSelection)
	t_src->textSrc_class.SetSelection = superC->textSrc_class.SetSelection;

    if (t_src->textSrc_class.ConvertSelection == XtInheritConvertSelection)
	t_src->textSrc_class.ConvertSelection =
	    superC->textSrc_class.ConvertSelection;
}

/************************************************************
 *
 * Class specific methods.
 *
 ************************************************************/

/*	Function Name: Read
 *	Description: This function reads the source.
 *	Arguments: w - the TextSrc Object.
 *                 pos - position of the text to retreive.
 * RETURNED        text - text block that will contain returned text.
 *                 length - maximum number of characters to read.
 *	Returns: The number of characters read into the buffer.
 */
/* ARGSUSED */
static XawTextPosition
Read(
	Widget w,
	XawTextPosition pos GCC_UNUSED,
	XawTextBlock * text GCC_UNUSED,
	int length GCC_UNUSED)
{
    XtAppError(XtWidgetToApplicationContext(w),
	       "TextSrc Object: No read function is defined.");

    return ((XawTextPosition) 0);	/* for gcc -Wall and lint */
}

/*	Function Name: Replace.
 *	Description: Replaces a block of text with new text.
 *	Arguments: src - the Text Source Object.
 *                 startPos, endPos - ends of text that will be removed.
 *                 text - new text to be inserted into buffer at startPos.
 *	Returns: XawEditError.
 */
/*ARGSUSED*/
static int
Replace(
	   Widget w GCC_UNUSED,
	   XawTextPosition startPos GCC_UNUSED,
	   XawTextPosition endPos GCC_UNUSED,
	   XawTextBlock * text GCC_UNUSED)
{
    return (XawEditError);
}

/*	Function Name: Scan
 *	Description: Scans the text source for the number and type
 *                   of item specified.
 *	Arguments: w - the TextSrc Object.
 *                 position - the position to start scanning.
 *                 type - type of thing to scan for.
 *                 dir - direction to scan.
 *                 count - which occurance if this thing to search for.
 *                 include - whether or not to include the character found in
 *                           the position that is returned.
 *	Returns: EXITS WITH AN ERROR MESSAGE.
 *
 */
/* ARGSUSED */
static
  XawTextPosition
Scan(
	Widget w,
	XawTextPosition position GCC_UNUSED,
	XawTextScanType type GCC_UNUSED,
	XawTextScanDirection dir GCC_UNUSED,
	int count GCC_UNUSED,
	Boolean include GCC_UNUSED)
{
    XtAppError(XtWidgetToApplicationContext(w),
	       "TextSrc Object: No SCAN function is defined.");

    return ((XawTextPosition) 0);	/* for gcc -Wall and lint */
}

/*	Function Name: Search
 *	Description: Searchs the text source for the text block passed
 *	Arguments: w - the TextSource Object.
 *                 position - the position to start scanning.
 *                 dir - direction to scan.
 *                 text - the text block to search for.
 *	Returns: XawTextSearchError.
 */
/* ARGSUSED */
static XawTextPosition
Search(
	  Widget w GCC_UNUSED,
	  XawTextPosition position GCC_UNUSED,
	  XawTextScanDirection dir GCC_UNUSED,
	  XawTextBlock * text GCC_UNUSED)
{
    return (XawTextSearchError);
}

/*	Function Name: ConvertSelection
 *	Description: Dummy selection converter.
 *	Arguments: w - the TextSrc object.
 *                 selection - the current selection atom.
 *                 target    - the current target atom.
 *                 type      - the type to conver the selection to.
 * RETURNED        value, length - the return value that has been converted.
 * RETURNED        format    - the format of the returned value.
 *	Returns: TRUE if the selection has been converted.
 *
 */
/* ARGSUSED */
static Boolean
ConvertSelection(
		    Widget w GCC_UNUSED,
		    Atom *selection GCC_UNUSED,
		    Atom *target GCC_UNUSED,
		    Atom *type GCC_UNUSED,
		    XtPointer *value GCC_UNUSED,
		    unsigned long *length GCC_UNUSED,
		    int *format GCC_UNUSED)
{
    return (FALSE);
}

/*	Function Name: SetSelection
 *	Description: allows special setting of the selection.
 *	Arguments: w - the TextSrc object.
 *                 left, right - bounds of the selection.
 *                 selection - the selection atom.
 *	Returns: none
 */
/* ARGSUSED */
static void
SetSelection(
		Widget w GCC_UNUSED,
		XawTextPosition left GCC_UNUSED,
		XawTextPosition right GCC_UNUSED,
		Atom selection GCC_UNUSED)
{
    /* This space intentionally left blank. */
}

#define done(address, type) \
        { toVal->size = sizeof(type); toVal->addr = (XPointer) address; }

/* ARGSUSED */
static void
CvtStringToEditMode(
		       XrmValuePtr args GCC_UNUSED,
		       Cardinal *num_args GCC_UNUSED,
		       XrmValuePtr fromVal,
		       XrmValuePtr toVal)
{
    static XawTextEditType editType;
    static XrmQuark QRead, QAppend, QEdit;
    XrmQuark q;
    char lowerName[BUFSIZ];
    static Boolean inited = FALSE;

    if (!inited) {
	QRead = XrmPermStringToQuark(XtEtextRead);
	QAppend = XrmPermStringToQuark(XtEtextAppend);
	QEdit = XrmPermStringToQuark(XtEtextEdit);
	inited = TRUE;
    }

    if (strlen((char *) fromVal->addr) >= sizeof(lowerName)) {
	XtStringConversionWarning((char *) fromVal->addr, XtREditMode);
	return;
    }
    XmuCopyISOLatin1Lowered(lowerName, (char *) fromVal->addr);
    q = XrmStringToQuark(lowerName);

    if (q == QRead)
	editType = XawtextRead;
    else if (q == QAppend)
	editType = XawtextAppend;
    else if (q == QEdit)
	editType = XawtextEdit;
    else {
	XtStringConversionWarning((char *) fromVal->addr, XtREditMode);
	return;
    }
    done(&editType, XawTextEditType);
    return;
}

/************************************************************
 *
 * Public Functions.
 *
 ************************************************************/

/*	Function Name: XawTextSourceRead
 *	Description: This function reads the source.
 *	Arguments: w - the TextSrc Object.
 *                 pos - position of the text to retreive.
 * RETURNED        text - text block that will contain returned text.
 *                 length - maximum number of characters to read.
 *	Returns: The number of characters read into the buffer.
 */
XawTextPosition
XawTextSourceRead(Widget w, XawTextPosition pos, XawTextBlock * text,
		  int length)
{
    TextSrcObjectClass class = (TextSrcObjectClass) w->core.widget_class;

    if (!XtIsSubclass(w, textSrcObjectClass))
	XtErrorMsg("bad argument", "textSource", "XawError",
		   "XawTextSourceRead's 1st parameter must be subclass of asciiSrc.",
		   NULL, NULL);

    return ((*class->textSrc_class.Read) (w, pos, text, length));
}

/*	Function Name: XawTextSourceReplace.
 *	Description: Replaces a block of text with new text.
 *	Arguments: src - the Text Source Object.
 *                 startPos, endPos - ends of text that will be removed.
 *                 text - new text to be inserted into buffer at startPos.
 *	Returns: XawEditError or XawEditDone.
 */
/*ARGSUSED*/
int
XawTextSourceReplace(Widget w, XawTextPosition startPos,
		     XawTextPosition endPos, XawTextBlock * text)
{
    TextSrcObjectClass class = (TextSrcObjectClass) w->core.widget_class;

    if (!XtIsSubclass(w, textSrcObjectClass))
	XtErrorMsg("bad argument", "textSource", "XawError",
		   "XawTextSourceReplace's 1st parameter must be subclass of asciiSrc.",
		   NULL, NULL);

    return ((*class->textSrc_class.Replace) (w, startPos, endPos, text));
}

/*	Function Name: XawTextSourceScan
 *	Description: Scans the text source for the number and type
 *                   of item specified.
 *	Arguments: w - the TextSrc Object.
 *                 position - the position to start scanning.
 *                 type - type of thing to scan for.
 *                 dir - direction to scan.
 *                 count - which occurance if this thing to search for.
 *                 include - whether or not to include the character found in
 *                           the position that is returned.
 *	Returns: The position of the text.
 *
 */
XawTextPosition
XawTextSourceScan(Widget w, XawTextPosition position,
		  XawTextScanType type, XawTextScanDirection dir,
		  int count,
		  Boolean include)
{
    TextSrcObjectClass class = (TextSrcObjectClass) w->core.widget_class;

    if (!XtIsSubclass(w, textSrcObjectClass))
	XtErrorMsg("bad argument", "textSource", "XawError",
		   "XawTextSourceScan's 1st parameter must be subclass of asciiSrc.",
		   NULL, NULL);

    return ((*class->textSrc_class.Scan) (w, position, type, dir, count, include));
}

/*	Function Name: XawTextSourceSearch
 *	Description: Searchs the text source for the text block passed
 *	Arguments: w - the TextSource Object.
 *                 position - the position to start scanning.
 *                 dir - direction to scan.
 *                 text - the text block to search for.
 *	Returns: The position of the text we are searching for or
 *               XawTextSearchError.
 */
XawTextPosition
XawTextSourceSearch(Widget w, XawTextPosition position,
		    XawTextScanDirection dir,
		    XawTextBlock * text)
{
    TextSrcObjectClass class = (TextSrcObjectClass) w->core.widget_class;

    if (!XtIsSubclass(w, textSrcObjectClass))
	XtErrorMsg("bad argument", "textSource", "XawError",
		   "XawTextSourceSearch's 1st parameter must be subclass of asciiSrc.",
		   NULL, NULL);

    return ((*class->textSrc_class.Search) (w, position, dir, text));
}

/*	Function Name: XawTextSourceConvertSelection
 *	Description: Dummy selection converter.
 *	Arguments: w - the TextSrc object.
 *                 selection - the current selection atom.
 *                 target    - the current target atom.
 *                 type      - the type to conver the selection to.
 * RETURNED        value, length - the return value that has been converted.
 * RETURNED        format    - the format of the returned value.
 *	Returns: TRUE if the selection has been converted.
 *
 */
Boolean
XawTextSourceConvertSelection(Widget w, Atom *selection, Atom *target,
			      Atom *type, XtPointer *value,
			      unsigned long *length, int *format)
{
    TextSrcObjectClass class = (TextSrcObjectClass) w->core.widget_class;

    if (!XtIsSubclass(w, textSrcObjectClass))
	XtErrorMsg("bad argument", "textSource", "XawError",
		   "XawTextSourceConvertSelectionXawTextSourceConvertSelection's 1st parameter must be subclass of asciiSrc.",
		   NULL, NULL);

    return ((*class->textSrc_class.ConvertSelection) (w, selection, target, type,
						      value, length, format));
}

/*	Function Name: XawTextSourceSetSelection
 *	Description: allows special setting of the selection.
 *	Arguments: w - the TextSrc object.
 *                 left, right - bounds of the selection.
 *                 selection - the selection atom.
 *	Returns: none
 */
void
XawTextSourceSetSelection(Widget w, XawTextPosition left,
			  XawTextPosition right, Atom selection)
{
    TextSrcObjectClass class = (TextSrcObjectClass) w->core.widget_class;

    if (!XtIsSubclass(w, textSrcObjectClass))
	XtErrorMsg("bad argument", "textSource", "XawError",
		   "'s 1st parameter must be subclass of asciiSrc.",
		   NULL, NULL);

    (*class->textSrc_class.SetSelection) (w, left, right, selection);
}

/********************************************************************
 *
 *      External Functions for Multi Text.
 *
 ********************************************************************/

/*
 * TextFormat():
 *   returns the format of text: FMT8BIT or FMTWIDE.
 *
 */
XrmQuark
_XawTextFormat(TextWidget tw)
{
    return (((TextSrcObject) (tw->text.source))->textSrc.text_format);
}

/* _XawTextWCToMB():
 *   convert the wchar string to external encoding.
 *   The caller is responsible for freeing both the source and ret string.
 *
 * wstr       - source wchar string.
 * len_in_out - lengh of string.
 *              As In, length of source wchar string, measured in wchar.
 *              As Out, length of returned string.
 */
char *
_XawTextWCToMB(d, wstr, len_in_out)
     Display *d;
     wchar_t *wstr;
     int *len_in_out;

{
    XTextProperty textprop;
    if (XwcTextListToTextProperty(d, (wchar_t **) &wstr, 1,
				  XTextStyle, &textprop) < Success) {
	XtWarningMsg("convertError", "textSource", "XawError",
		     "Non-character code(s) in buffer.", NULL, NULL);
	*len_in_out = 0;
	return (NULL);
    }
    *len_in_out = (int) textprop.nitems;
    return ((char *) textprop.value);
}

/* _XawTextMBToWC():
 *   convert the string to internal processing codeset WC.
 *   The caller is responsible for freeing both the source and ret string.
 *
 * str        - source string.
 * len_in_out - lengh of string.
 *              As In, it is length of source string.
 *              As Out, it is length of returned string, measured in wchar.
 */
wchar_t *
_XawTextMBToWC(d, str, len_in_out)
     Display *d;
     char *str;
     int *len_in_out;
{
    if (*len_in_out == 0) {
	return (NULL);
    } else {
	XTextProperty textprop;
	char *buf;
	wchar_t **wlist, *wstr;
	int count;
	buf = XtMalloc((unsigned) (*len_in_out + 1));
	if (!buf) {
	    XtErrorMsg("convertError", "multiSourceCreate", "XawError",
		       "No Memory", NULL, NULL);
	    *len_in_out = 0;
	    return (NULL);	/* The above function doesn't really return. */
	}
	strncpy(buf, str, (size_t) *len_in_out);
	*(buf + *len_in_out) = '\0';
	if (XmbTextListToTextProperty(d, &buf, 1, XTextStyle, &textprop)
	    != Success) {
	    XtWarningMsg("convertError", "textSource", "XawError",
			 "No Memory, or Locale not supported.", NULL, NULL);
	    XtFree(buf);
	    *len_in_out = 0;
	    return (NULL);
	}
	XtFree(buf);
	if (XwcTextPropertyToTextList(d, &textprop,
				      (wchar_t ***) &wlist, &count) != Success) {
	    XtWarningMsg("convertError", "multiSourceCreate", "XawError",
			 "Non-character code(s) in source.", NULL, NULL);
	    *len_in_out = 0;
	    return (NULL);
	}
	wstr = wlist[0];
	*len_in_out = (int) wcslen(wstr);
	XtFree((XtPointer) wlist);
	return (wstr);
    }
}
