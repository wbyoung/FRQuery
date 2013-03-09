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

/*!
 \brief		Query object for accessing data
 \details	A query object is a lazily evaluated object that provides a simple interface for retrieving Core Data
			managed objects. They are essentially immutable containers that encapsulate the rules of a fetch request,
			evaluating the request on demand and only when necessary. All operations that alter the request return a
			new, unevaluated query object.
			Queries also act as an array proxy. The query will remain unevaluated until it is accessed as an array. Once
			the query (array proxy) is enumerated, has its count checked, has an index accessed, etc., the query will be
			evaluated and the resulting contents frozen for later access. The query will alter its contents. To refetch
			data with the same rules, you should create a new, unevaluated query.
			Note that like many other proxy objects in Core Data, it is essential that you only use this on thread or
			queue in which the managed object context operates. Queries are easily created from a context. See
			NSManagedObjectContext::query (in FRContextAdditions).
 */
@interface FRQuery : NSProxy

/*!
 \brief		Easy interface for working with query objects
 \details	The keyed subscript interface provides many features to queries in a very simple interface. Five different
			types of key can be used with different results: predicate objects, dictionary predicates, string
			predicates, sorting strings, and binding strings.
 
			Predicate objects allow you to add a predicate to the filter chain:
 
				query[[NSPredicate predicateWithFormat:@"name = 'Brittany'"]]
 
			Dictionary predicates allow you to use a dictionary to add a predicate to the filter chain:
 
				query[@{
					@"name__beginswith": @"Brit",
					@"age__gt": @(10),
					@"age_lte": @(60),
				}];
 
			Dictionary predicates support comparisons by including a double underscore followed by the comparison name.
			The following comparisons are supported:
 
				exact  (==) Equality comparison. Exact comparison is implied if no comparison is included.
				gte    (>=) Greater than or equal to.
				gt      (>) Greater than.
				lte     (<) Less than.
				lt     (<=) Less than or equal to.
				contains    Contains. See NSPredicate for details on contains options.
				beginswith  Begins with. See NSPredicate for details on begins with options.
				endswith	Ends with. See NSPredicate for details on ends with options.
 
			String based predicates allow you to add a predicate to the filter chain:
 
				query[@"name = 'Benedict'"]
 
			Sorting strings allow you to apply sort descriptors to the query. The string must begin with a caret to
			differentiate it from a string based predicate. You can sort ascending by simply providing the key path
			for the sort. For descending order, prefix the name with a minus sign. Sorting by multiple keys is possible
			by joining the keys with a comma:
 
				query[@"^name"] (name ascending)
				query[@"^-name"] (name descending)
				query[@"^-name,age"] (name descending, age ascending)
				query[@"^name,-age"] (name ascending, age descending)
 
			Binding strings allow you to bind unbound queries to an entity without defining a binding method. This is
			described in more detail in the managed object context additions (FRContextAdditions) where an example is
			also provided.
 */
- (id)objectForKeyedSubscript:(id)key;

/*!
 \brief		Filter a query
 \details	Return a new query object filtered according to the given predicate. Filters are chained, so this continues
			to narrow down the set of objects. For example these two are equivalent:
 
				[[query filterQuery:@"name = 'Sara'"] filterQuery:@"age > 25"]
				[query filterQuery:@"name = 'Sara' and age > 25"]
 
			For more complex predicates, use the keyed subscripting support.
 */
- (id)filterQuery:(NSString *)format, ...;

/*!
 \brief		Sort a query
 \details	Return a new query object sorted according the the descriptors. Sort descriptors are not chained, so this
			new query will be sorted only by the given descriptors.
 */
- (id)sortQueryByDescriptors:(NSArray *)sortDescriptors;

/*!
 \brief		Sort a query
 \details	Return a new query object sorted according the the key in the given order. Sort descriptors are not chained,
			so this new query will be sorted only by this key.
 */
- (id)sortQueryByKey:(NSString *)key ascending:(BOOL)ascending;

/*!
 \brief		Sort a query
 \details	Return a new query object sorted according the the key in the given order with the selector. Sort
			descriptors are not chained, so this new query will be sorted only by this key.
 */
- (id)sortQueryByKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector;

/*!
 \brief		Limit a query
 \details	Return a new query object limited to the given value. Limits are not chained, so this new query will fetch
			this many objects when evaluated.
 */
- (id)limitQuery:(NSUInteger)limit;

/*!
 \brief		Check if the query is evaluated
 \details	Check if the query has been evaluated yet.
 */
- (BOOL)isEvaluated;

/*!
 \brief		An unevaluated query
 \details	You can use this to create a new query that hasn't been evaluated from one that has (or even one that hasn't
			yet been evaluated). This is useful to re-evaluate a query or create a new query to pass along somewhere
			else. Note that since all operations copy queries, it's also possible to create an unevaluated query with
			something like query[@{}], but this method is preferred.
 */
- (id)unevaluatedQuery;

/*!
 \brief		The fetch request that this query represents
 \details	This gets the fetch request that this query represents. This is useful if you want to alter the fetch
			request in ways that the query interface does not allow. Getting the fetch request will not cause the query
			to be evaluated, but is still invalid for unbound queries.
 */
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;

@end
