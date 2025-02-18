/*
 * $XTermId: TraversalP.h,v 1.5 2015/01/09 10:18:49 tom Exp $
 *
 * Copyright 2015  Thomas E. Dickey
 */

/*

Copyright (c) 1999  X Consortium

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

*/

#ifndef	XawTraversalP_h
#define	XawTraversalP_h

#include "Traversal.h"



	/* Class method which may be added to any widget class that
	 * will accept focus.  Accepts focus any time the widget
	 * is sensitive and otherwise eligible.
	 */

extern	Boolean	XawAcceptFocus(
    Widget, Time *
);



	/* Action procedures which should be called by any class which
	 * wishes to participate in the keyboard traversal protocol.
	 *
	 * Procedures are:
	 *
	 *	Next		transfer focus to next eligible widget
	 *	Previous	transfer focus to previous eligible widget
	 *	Home		transfer focus to first eligible widget
	 *	End		transfer focus to last eligible widget
	 *	Take		transfer focus to this widget.
	 *	NextGroup	transfer focus to next in this local group
	 *	PreviousGroup	transfer focus to previous in this local group
	 *	HomeGroup	transfer focus to first in this local group
	 *	EndGroup	transfer focus to last in this local group
	 *	EnterWindow	react to enter-window
	 *	LeaveWindow	react to leave-window
	 *
	 * A "local group" is similar to the Motif "tab group".  Local
	 * groups are all widgets under a single manager widget.  Typically,
	 * arrow keys would navigate within a local group, whereas tab keys
	 * would navigate globally.
	 *
	 * If XawFocusPolicy is XawFocusPointer, this action proc ignores
	 * all keyboard traversal operations; thus creating the old
	 * behavior.
	 *
	 * Actions taken by EnterWindow and LeaveWindow depend on the
	 * XawFocusPolicy resource:
	 *	XawFocusPointer:	Sets focus window to PointerRoot
	 *	XawFocusKey:		Sets focus window to PointerRoot
	 *	XawFocusSet:		leaves focus unchanged.
	 */

extern	void	XawFocusNextAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusPreviousAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusHomeAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusEndAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusTakeAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusNextGroupAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusPreviousGroupAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusHomeGroupAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusEndGroupAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusEnterWindowAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);

extern	void	XawFocusLeaveWindowAction(
    Widget w,
    XEvent *event,
    String *params,
    Cardinal *num_params
);


#endif	/* XawTraversalP_h */
