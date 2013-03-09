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

#import "FRQuery.h"

/*!
 \brief		Query binding
 \details	Methods in the main class file work together with this class to resolve and bind the query as needed. The
			methods in this file should not be used by any class that is not supporting the query system (hence the
			project suffix on the header file).
 */
@interface FRQuery (FRQueryBinding)

/*!
 \brief		Create an unbound query
 \details	This creates an unbound query with the given managed object context.
 */
+ (id)queryWithManagedObjectContext:(NSManagedObjectContext *)context;

/*!
 \brief		Dynamically resolve a method
 \details	This method attempts to resolve the a binding method based on the given selector name. If successful, it
			will return a method signature for the resolved method. The method looks through the managed object model
			associated with the receiver's context to determine if it should resolve the binding method. The method will
			be resolved if the selector name is the plural form of any entity's name in the object model.
 */
- (NSMethodSignature *)resolveBindingMethod:(SEL)name;

/*!
 \brief		Bind a query by key
 \details	This method allows binding a query by key rather than by calling a method. It results in basically the same
			thing, though.
 */
- (id)boundQueryWithKey:(NSString *)key;

@end
