// 
// Copyright (c) 2013 Whitney Young
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// 

#import <objc/runtime.h>

#import "FRContextAdditions.h"
#import "FRQueryBinding_project.h"

@implementation NSManagedObjectContext (FRContextAdditions)

- (FRQuery *)query {
	// this is the only method that we have added to the managed object context. this was done to avoid naming
	// collisions on the context. a slightly more appealing query interface could have been created:
	//
	//     context.people[@"age > 21"];
	//
	// but the possibility for naming conflicts is just too great. we would be dynamically adding methods to the managed
	// object context based on information from the model, so things would be different for each application.
	// nevertheless, this would be possible. it would be a bit more tricky to do, though. you would have to add methods
	// to handle forwarding for the managed object context. to do so, you would swizzle in the implementations of
	// forwardInvocation: and methodSignatureForSelector:, then handle forwarding in the same way that FRQuery does for
	// unbound queries (dynamically resolving methods). if unable to resolve/forward methods, the original method
	// implementation would need to be called in case managed object contexts use method forwarding for any reason. so
	// while possible, the decision to expose a single unbound query was made to avoid method name collisions.
	//
	// while queries are very lightweight and we could create a new one each time this is called, this example shows off
	// how to make an on demand getter method that is implemented as a category on a class. this still does have two
	// advantages. first, it will return the same object each time it's called which is more in line with the property
	// definition (meeting programmer expectations). second, the query object actually caches some information for
	// creating bound queries, so keeping that cache around will speed up the binding process.
	// 
	// associated objects make creating on demand accessors in categories easy. here we are using _cmd, the hidden
	// second argument and the selector of this method, as a key. it's guaranteed to be unique and constant, perfect for
	// an associated object key. alternatively, a nice way to define keys is with a static global,
	// static void *kQueryKey = &(NSUInteger){0}.
	FRQuery *query = objc_getAssociatedObject(self, _cmd);
	if (query == nil) {
		query = [FRQuery queryWithManagedObjectContext:self];
		objc_setAssociatedObject(self, _cmd, query, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return query;
}

@end
