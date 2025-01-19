/***********************************************************

Copyright 2015,2025 by Thomas E. Dickey
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

Except as contained in this notice, the name of the X Consortium shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from the X Consortium.

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

/*
 * TextSrcP.h - Private definitions for TextSrc object
 *
 */

#ifndef _XawTextSrcP_h
#define _XawTextSrcP_h
/* *INDENT-OFF* */

/***********************************************************************
 *
 * TextSrc Object Private Data
 *
 ***********************************************************************/

#include <X11/neXtaw/TextSrc.h>
#include <X11/neXtaw/TextP.h>	/* This source works with the Text widget. */

/************************************************************
 *
 * New fields for the TextSrc object class record.
 *
 ************************************************************/

typedef struct {
  XtPointer		next_extension;
  XrmQuark		record_type;
  long			version;
  Cardinal		record_size;
  int			(*Input)(void);
} TextSrcExtRec, *TextSrcExt;

typedef struct _TextSrcClassPart {
  XawTextPosition	(*Read)(Widget, XawTextPosition, XawTextBlock *, int);
  int			(*Replace)(Widget, XawTextPosition, XawTextPosition, XawTextBlock *);
  XawTextPosition	(*Scan)(Widget, XawTextPosition, XawTextScanType, XawTextScanDirection, int, Boolean);
  XawTextPosition       (*Search)(Widget, XawTextPosition, XawTextScanDirection, XawTextBlock *);
  void                  (*SetSelection)(Widget, XawTextPosition, XawTextPosition, Atom selection);
  Boolean		(*ConvertSelection)(Widget, Atom *, Atom *, Atom *, XtPointer *, unsigned long *, int *);
} TextSrcClassPart;

/* Full class record declaration */
typedef struct _TextSrcClassRec {
    ObjectClassPart     object_class;
    TextSrcClassPart	textSrc_class;
} TextSrcClassRec;

extern TextSrcClassRec textSrcClassRec;

/* New fields for the TextSrc object record */
typedef struct {
    /* resources */
  XawTextEditType	edit_mode;
  XrmQuark		text_format;	/* 2 formats: FMT8BIT for Ascii */
					/*            FMTWIDE for ISO 10646 */
} TextSrcPart;

/****************************************************************
 *
 * Full instance record declaration
 *
 ****************************************************************/

typedef struct _TextSrcRec {
  ObjectPart    object;
  TextSrcPart	textSrc;
} TextSrcRec;

/******************************************************************
 *
 * Semiprivate declarations of functions used in other modules
 *
 ******************************************************************/

char* _XawTextWCToMB(
    Display* /* d */,
    wchar_t* /* wstr */,
    int*     /* len_in_out */
);

wchar_t* _XawTextMBToWC(
    Display*  /* d */,
    char*     /* str */,
    int*      /* len_in_out */
);

/************************************************************
 *
 * Private declarations.
 *
 ************************************************************/

#define XtInheritInput                ((int(*)(void)) _XtInherit)
#define XtInheritRead                 ((XawTextPosition(*)(Widget, XawTextPosition, XawTextBlock *, int)) _XtInherit)
#define XtInheritReplace              ((int(*)(Widget, XawTextPosition, XawTextPosition, XawTextBlock *)) _XtInherit)
#define XtInheritScan                 ((XawTextPosition(*)(Widget, XawTextPosition, XawTextScanType, XawTextScanDirection, int, Boolean)) _XtInherit)
#define XtInheritSearch               ((XawTextPosition(*)(Widget, XawTextPosition, XawTextScanDirection, XawTextBlock *)) _XtInherit)
#define XtInheritSetSelection         ((void(*)(Widget, XawTextPosition, XawTextPosition, Atom selection)) _XtInherit)
#define XtInheritConvertSelection     ((Boolean(*)(Widget, Atom *, Atom *, Atom *, XtPointer *, unsigned long *, int *)) _XtInherit)

#define XtTextSrcExtVersion	      1
#define XtTextSrcExtTypeString        "XT_TEXTSRC_EXT"

/* *INDENT-ON* */

#endif /* _XawTextSrcP_h */
