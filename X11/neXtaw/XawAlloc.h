/*
 * Cleanup 2015 - TD
 */
#define XtStackAlloc(size, stack_cache_array)     	\
	((unsigned)(size) <= sizeof(stack_cache_array)  \
	 ?  (XtPointer)(stack_cache_array)              \
	 :  XtMalloc((unsigned)(size)))

#define XtStackFree(pointer, stack_cache_array) \
	if ((pointer) != ((XtPointer)(stack_cache_array))) \
		XtFree(pointer)
