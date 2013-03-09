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

@class
	FRQuery;

@interface NSManagedObjectContext (FRContextAdditions)

/*!
 \brief		Gets an unbound query for the context
 \details	After calling this method, you must bind the query by calling the plural form of your entity name on the
			query. This necessitates defining a binding method in an FRQuery extension with your plural name. Once
			called, your query is bound and ready to use. For instance, if you had an Article entity, you would do the
			following:
 
				@interface FRQuery (FRArticleQueryBinding)
				@property (nonatomic, readonly) id articles;
				@end
 
				id articles = context.query.articles[@"^date"];
 
			You must not provide a definition for the binding method. The method is resolved automatically at runtime.
			Alternatively, you can simply obtain a bound query through a keyed subscript:
 
 				id articles = context.query[@"articles"][@"^date"];
 
			Using unbound queries will result in an exception being thrown.
 */
@property (nonatomic, readonly) FRQuery *query;

@end
