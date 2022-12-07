/*

Copyright 2015,2022 Thomas E. Dickey
Copyright 1999 Carlos A M dos Santos
Copyright (c) 1991, 1994  X Consortium

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

#include "private.h"

#include <X11/IntrinsicP.h>
#include <X11/Xmu/WidgetNode.h>

extern WidgetClass applicationShellWidgetClass;
extern WidgetClass asciiSinkObjectClass;
extern WidgetClass asciiSrcObjectClass;
extern WidgetClass asciiTextWidgetClass;
extern WidgetClass boxWidgetClass;
extern WidgetClass clockWidgetClass;	/* Casantos, Jun 30 1999 */
extern WidgetClass commandWidgetClass;
extern WidgetClass compositeWidgetClass;
extern WidgetClass constraintWidgetClass;
extern WidgetClass coreWidgetClass;
extern WidgetClass dialogWidgetClass;
extern WidgetClass formWidgetClass;
extern WidgetClass gripWidgetClass;
extern WidgetClass labelWidgetClass;
extern WidgetClass layoutWidgetClass;
extern WidgetClass listWidgetClass;
extern WidgetClass menuButtonWidgetClass;
extern WidgetClass objectClass;
extern WidgetClass overrideShellWidgetClass;
extern WidgetClass panedWidgetClass;
extern WidgetClass pannerWidgetClass;
extern WidgetClass portholeWidgetClass;
extern WidgetClass rectObjClass;
extern WidgetClass repeaterWidgetClass;
extern WidgetClass scrollbarWidgetClass;
extern WidgetClass shellWidgetClass;
extern WidgetClass simpleMenuWidgetClass;
extern WidgetClass simpleWidgetClass;
extern WidgetClass smeBSBObjectClass;
extern WidgetClass smeLineObjectClass;
extern WidgetClass smeObjectClass;
extern WidgetClass smeThreeDObjectClass;
extern WidgetClass stripChartWidgetClass;
extern WidgetClass textSinkObjectClass;
extern WidgetClass textSrcObjectClass;
extern WidgetClass textWidgetClass;
extern WidgetClass threeDWidgetClass;
extern WidgetClass toggleWidgetClass;
extern WidgetClass topLevelShellWidgetClass;
extern WidgetClass transientShellWidgetClass;
extern WidgetClass treeWidgetClass;
extern WidgetClass vendorShellWidgetClass;
extern WidgetClass viewportWidgetClass;
extern WidgetClass wmShellWidgetClass;

#define EMPTY_OBJECT(name, class) { DeConst(name), &(class), 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
#define OBJECT_CLASS(name) EMPTY_OBJECT(#name, name ## ObjectClass)
#define WIDGET_CLASS(name) EMPTY_OBJECT(#name, name ## WidgetClass)

XmuWidgetNode XawWidgetArray[] =
{
    WIDGET_CLASS(applicationShell),
    OBJECT_CLASS(asciiSink),
    OBJECT_CLASS(asciiSrc),
    WIDGET_CLASS(asciiText),
    WIDGET_CLASS(box),
    WIDGET_CLASS(clock),
    WIDGET_CLASS(command),
    WIDGET_CLASS(composite),
    WIDGET_CLASS(constraint),
    WIDGET_CLASS(core),
    WIDGET_CLASS(dialog),
    WIDGET_CLASS(form),
    WIDGET_CLASS(grip),
    WIDGET_CLASS(label),
    WIDGET_CLASS(layout),
    WIDGET_CLASS(list),
    WIDGET_CLASS(menuButton),
    EMPTY_OBJECT("object", objectClass),
    WIDGET_CLASS(overrideShell),
    WIDGET_CLASS(paned),
    WIDGET_CLASS(panner),
    WIDGET_CLASS(porthole),
    EMPTY_OBJECT("rect", rectObjClass),
    WIDGET_CLASS(repeater),
    WIDGET_CLASS(scrollbar),
    WIDGET_CLASS(shell),
    WIDGET_CLASS(simpleMenu),
    WIDGET_CLASS(simple),
    OBJECT_CLASS(smeBSB),
    OBJECT_CLASS(smeLine),
    OBJECT_CLASS(smeThreeD),
    OBJECT_CLASS(sme),
    WIDGET_CLASS(stripChart),
    OBJECT_CLASS(textSink),
    OBJECT_CLASS(textSrc),
    WIDGET_CLASS(text),
    WIDGET_CLASS(threeD),
    WIDGET_CLASS(toggle),
    WIDGET_CLASS(topLevelShell),
    WIDGET_CLASS(transientShell),
    WIDGET_CLASS(tree),
    WIDGET_CLASS(vendorShell),
    WIDGET_CLASS(viewport),
    WIDGET_CLASS(wmShell),
};

int XawWidgetCount = XtNumber(XawWidgetArray);
