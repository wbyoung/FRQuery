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
#import "FRQuery_project.h"
#import "FRQueryBinding_project.h"

@interface FRQuery () {
	NSArray *_objects;
	NSEntityDescription *_entity;
	NSArray *_sortDescriptors;
	NSPredicate *_predicate;
	NSUInteger _fetchLimit;
	NSFetchRequest *_fetchRequest;
}
@end

@implementation FRQuery

+ (id)queryWithEntity:(NSEntityDescription *)entity managedObjectContext:(NSManagedObjectContext *)context {
	FRQuery *query = [FRQuery alloc];
	query->_managedObjectContext = context;
	query->_entity = entity;
	return query;
}


#pragma mark -
#pragma mark method forwarding
// ----------------------------------------------------------------------------------------------------
// method forwarding
// ----------------------------------------------------------------------------------------------------

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//	id target = nil;
//	if (!_entity) {} // unbound, can't forward to target
//	else {
//		[self _evaluateIfNeeded];
//		target = _objects;
//	}
//	return target;
//}

- (void)forwardInvocation:(NSInvocation *)invocation {
	if (!_entity) {} // unbound, simply re-invoke
	else {
		[self _evaluateIfNeeded];
		[invocation setTarget:_objects];
	}
	[invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature *signature = nil;
	if (!_entity) { signature = [self resolveBindingMethod:selector]; } // unbound, resolve method
	else { signature = [NSArray instanceMethodSignatureForSelector:selector]; }
	return signature;
}


#pragma mark -
#pragma mark evaluation
// ----------------------------------------------------------------------------------------------------
// evaluation
// ----------------------------------------------------------------------------------------------------

- (void)_validateBinding {
	if (!_entity) {
		[NSException raise:NSInternalInconsistencyException format:
		 @"Cannot use an unbound query. First bind this query to an entity by calling a method on it with "
		 @"the plural name of your entity (i.e. call articles if your entity is named Article)."];
	}
}

- (void)_evaluateIfNeeded {
	if (_objects) { return; }
	
	[self _validateBinding];
	
	NSFetchRequest *request = [self fetchRequest];
	_objects = [_managedObjectContext executeFetchRequest:request error:NULL];
}


#pragma mark -
#pragma mark standard object methods (overrides)
// ----------------------------------------------------------------------------------------------------
// standard object methods (overrides)
// ----------------------------------------------------------------------------------------------------

- (NSString *)description {
	NSString *entity = _entity ? [_entity name] : @"unbound";
	id count = _objects ? @([_objects count]) : @"?";
	return [NSString stringWithFormat:@"<FRQuery: %@ with %@ objects>", entity, count];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale { return [self description]; }
- (NSString *)descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)level { return [self description]; }
- (NSString *)debugDescription { return [self description]; }

- (BOOL)isEqual:(id)object {
	// proxy objects define equality by default, so we need to make sure that we redefine it to be based on our actual
	// target object. if we don't do this, the proxy will consider objects equal based on pointer equality.
	[self _evaluateIfNeeded];
	return [_objects isEqual:object];
}

- (BOOL)respondsToSelector:(SEL)selector {
	// calling super results in an attempt to forward the responds to selector call using standard method forwarding.
	// this would cause evaluation of our query, and for descriptionWithLocale: (which is checked sometimes for string
	// formatting), we don't want that to happen.
	return
		selector == @selector(description) ||
		selector == @selector(debugDescription) ||
		selector == @selector(descriptionWithLocale:) ||
		selector == @selector(descriptionWithLocale:indent:) ||
		
		[super respondsToSelector:selector];
}

- (void)doesNotRecognizeSelector:(SEL)selector {
	// raise and log an error that's more like the standard unrecognized selector error instead of the proxy version
	NSString *format = @"-[FRQuery %@]: unrecognized selector sent to instance %p";
	NSString *reason = [NSString stringWithFormat:format, NSStringFromSelector(selector), self];
	NSLog(@"%@", reason);
	[[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
}


#pragma mark -
#pragma mark query building
// ----------------------------------------------------------------------------------------------------
// query building
// ----------------------------------------------------------------------------------------------------

- (BOOL)isEvaluated { return _objects != nil; }

- (id)unevaluatedQuery {
	[self _validateBinding];
	
	FRQuery *query = [FRQuery alloc];
	query->_objects = nil;
	query->_fetchRequest = nil;
	query->_managedObjectContext = _managedObjectContext;
	query->_entity = _entity;
	query->_sortDescriptors = [_sortDescriptors copy];
	query->_predicate = [_predicate copy];
	query->_fetchLimit = _fetchLimit;
	return query;
}

- (NSFetchRequest *)fetchRequest {
	[self _validateBinding];
	
	if (!_fetchRequest) {
		_fetchRequest = [[NSFetchRequest alloc] init];
		[_fetchRequest setEntity:_entity];
		[_fetchRequest setPredicate:_predicate];
		[_fetchRequest setSortDescriptors:_sortDescriptors];
		[_fetchRequest setFetchLimit:_fetchLimit];
	}
	return _fetchRequest;
}

- (id)sortQueryByDescriptors:(NSArray *)sortDescriptors {
	FRQuery *query = [self unevaluatedQuery];
	query->_sortDescriptors = sortDescriptors;
	query->_fetchRequest = nil;
	return query;
}

- (id)sortQueryByKey:(NSString *)key ascending:(BOOL)ascending {
	return [self sortQueryByKey:key ascending:ascending selector:NULL];
}

- (id)sortQueryByKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector {
	return [self sortQueryByDescriptors:
			@[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending selector:selector]]];
}


- (id)limitQuery:(NSUInteger)limit {
	FRQuery *query = [self unevaluatedQuery];
	query->_fetchLimit = limit;
	query->_fetchRequest = nil;
	return query;
}

- (id)filterQueryUsingPredicate:(NSPredicate *)predicate {
	FRQuery *query = [self unevaluatedQuery];
	if (_predicate) {
		query->_predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[_predicate, predicate]];
		query->_fetchRequest = nil;
	}
	else {
		query->_predicate = predicate;
		query->_fetchRequest = nil;
	}
	
	return query;
}

- (id)filterQuery:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:args];
	va_end(args);
	
	return [self filterQueryUsingPredicate:predicate];
}

- (id)objectForKeyedSubscript:(id)key {
	if (!_entity) { return [self boundQueryWithKey:key]; } // bind if not bound yet
	
	FRQuery *query = nil;
	NSPredicate *predicate = nil;
	NSMutableArray *descriptors = [NSMutableArray array];
	
	if ([key isKindOfClass:[NSPredicate class]]) { predicate = key; }
	else if ([key isKindOfClass:[NSString class]]) {
		// handle sort ordering by checking if the string starts with a caret. a caret by itself means ascending order.
		// a caret followed by a minus sign means descending order. you can put multiple sort descriptors together like
		// so: ^name,-age.
		if ([key hasPrefix:@"^"]) {
			for (NSString *sort in [[key substringFromIndex:1] componentsSeparatedByString:@","]) {
				NSString *sortKey = sort;
				BOOL ascending = TRUE;
				if ([sortKey hasPrefix:@"-"]) {
					sortKey = [sortKey substringFromIndex:1];
					ascending = FALSE;
				}
				[descriptors addObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending]];
			}
		}
		else { // if it's not a sort, then it's just a predicate
			predicate = [NSPredicate predicateWithFormat:key argumentArray:nil];
		}
	}
	else if ([key isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dictionary = key;
		NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:[dictionary count]];
		for (NSString *spec in dictionary) {
			NSArray *components = [spec componentsSeparatedByString:@"__"];
			NSString *predicateKey = [components count] > 0 ? components[0] : nil;
			NSString *predicateCompare = [components count] > 1 ? components[1] : nil;
			id predicateValue = dictionary[spec];
			if ([components count] > 2) {
				[NSException raise:NSInternalInconsistencyException format:
				 @"Unknown query specification (contains too many __ sections): %@", spec];
			}
			
			if (predicateKey && predicateValue) {
				NSString *format = nil;
				if (predicateCompare == nil) { format = @"%K == %@"; }
				else if ([predicateCompare isEqualToString:@"exact"]) { format = @"%K == %@"; }
				else if ([predicateCompare isEqualToString:@"gte"]) { format = @"%K >= %@"; }
				else if ([predicateCompare isEqualToString:@"gt"]) { format = @"%K > %@"; }
				else if ([predicateCompare isEqualToString:@"lte"]) { format = @"%K <= %@"; }
				else if ([predicateCompare isEqualToString:@"lt"]) { format = @"%K < %@"; }
				else if ([predicateCompare isEqualToString:@"contains"]) { format = @"%K contains %@"; }
				else if ([predicateCompare isEqualToString:@"contains[c]"]) { format = @"%K contains[c] %@"; }
				else if ([predicateCompare isEqualToString:@"contains[d]"]) { format = @"%K contains[d] %@"; }
				else if ([predicateCompare isEqualToString:@"contains[cd]"] ||
						 [predicateCompare isEqualToString:@"contains[dc]"]) { format = @"%K contains[cd] %@"; }
				else if ([predicateCompare isEqualToString:@"beginswith"]) { format = @"%K beginswith %@"; }
				else if ([predicateCompare isEqualToString:@"beginswith[c]"]) { format = @"%K beginswith[c] %@"; }
				else if ([predicateCompare isEqualToString:@"beginswith[d]"]) { format = @"%K beginswith[d] %@"; }
				else if ([predicateCompare isEqualToString:@"beginswith[cd]"] ||
						 [predicateCompare isEqualToString:@"beginswith[dc]"]) { format = @"%K beginswith[cd] %@"; }
				else if ([predicateCompare isEqualToString:@"endswith"]) { format = @"%K endswith %@"; }
				else if ([predicateCompare isEqualToString:@"endswith[c]"]) { format = @"%K endswith[c] %@"; }
				else if ([predicateCompare isEqualToString:@"endswith[d]"]) { format = @"%K endswith[d] %@"; }
				else if ([predicateCompare isEqualToString:@"endswith[cd]"] ||
						 [predicateCompare isEqualToString:@"endswith[dc]"]) { format = @"%K endswith[cd] %@"; }
				else {
					[NSException raise:NSInternalInconsistencyException format:
					 @"Unknown query specification (comparison %@ not defined): %@", predicateCompare, spec];
				}
				
				if (format) {
					[predicates addObject:[NSPredicate predicateWithFormat:format, predicateKey, predicateValue]];
				}
			}
		}
		predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	}
	
	if (predicate) { query = [self filterQueryUsingPredicate:predicate]; }
	if ([descriptors count]) { query = [self sortQueryByDescriptors:descriptors]; }
	
	if (query == nil) {
		[NSException raise:NSInternalInconsistencyException format:@"Failed to create a query from %@", key];
	}
	
	return query;
}

@end
