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

#import "FRQueryBinding_project.h"
#import "FRQuery_project.h"

// this IMP is defined for later use to dynamically add a method. see below for details about why this actually is an
// IMP even though it doesn't have the IMP type. always remember to include the implicit self (id) and _cmd (SEL)
// arguments at the beginning of your IMP definition. any additional arguments come after those.
static id FRQueryCreateBoundQuery(id self, SEL _cmd);

@interface NSManagedObject (FRQueryPluralization)
+ (NSString *)pluralizeKey:(NSString *)key;
@end

@implementation FRQuery (FRQueryBinding)

+ (id)queryWithManagedObjectContext:(NSManagedObjectContext *)context {
	return [FRQuery queryWithEntity:nil managedObjectContext:context];
}

- (NSEntityDescription *)entityForMethodName:(SEL)name {
	NSEntityDescription *entity = objc_getAssociatedObject(self, name); // check cache
	
	if (!entity) { // lookup entity and cache
		NSManagedObjectContext *context = self->_managedObjectContext;
		NSPersistentStoreCoordinator *coordinator = [context persistentStoreCoordinator];
		NSManagedObjectModel *model = [coordinator managedObjectModel];
		NSString *pluralName = [NSStringFromSelector(name) capitalizedString];
		
		for (NSEntityDescription *possible in [model entities]) {
			NSString *possibleName = [possible name];
			Class entityClass = NSClassFromString([possible managedObjectClassName]);
			NSString *possiblePluralName = [[entityClass pluralizeKey:possibleName] capitalizedString];
			if ([pluralName isEqualToString:possiblePluralName]) {
				entity = possible;
				break;
			}
		}
		objc_setAssociatedObject(self, name, entity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return entity;
}

- (void)handleUnknownEntityWithName:(NSString *)name {
	[NSException raise:NSInternalInconsistencyException format:
	 @"Could not resolve an entity from the selector (%@) to bind a query. If the plural name of your class does "
	 @"not simply have an (s) suffix, implement a category method +[NSManagedObject pluralize<Key>] to return %@ (or "
	 @"implement this method in your custom subclass).",
	 name, name];
}

- (NSMethodSignature *)resolveBindingMethod:(SEL)name {
	NSMethodSignature *signature = nil;
	
	// dynamically add a method if binding achievable. if not, throw an exception that makes it clear that something
	// is going wrong with the query system and that there may be a way for the programmer to recover from the problem.
	// note that it would be possible to simply skip the step of dynamically resolving these methods. however, this
	// would potentially cause performance problems. the runtime would have to create an invocation for the unresolved
	// method each time and pass that off to the forwarding mechanism of this class. with the method added, the message
	// sending system in objective-c is able to cache information related to the method and very quickly call it in the
	// future. this pattern is used a fair amount by Apple throughout the Cocoa frameworks. another way to handle
	// dynamic method resolution is to use +[NSObject resolveInstanceMethod:] and/or +[NSObject resolveClassMethod:].
	// in this case, information is needed from managed object context associated with the query instance, so these
	// class methods were not an option.
	if ([self entityForMethodName:name]) { signature = [self createBindingMethod:name]; }
	else { [self handleUnknownEntityWithName:NSStringFromSelector(name)]; }
	
	return signature;
}

- (NSMethodSignature *)createBindingMethod:(SEL)name {
	// though we could hand code the objective-c types for a method, this is error prone. it is safer to choose a
	// method that has the same type encoding and use that as a prototype for the method being added. also, methods
	// that are added need be of type IMP. IMP simply means that the method takes id and SEL as the first two
	// arguments and returns a value. it can take any additional arguments (it can also return non-id types as many
	// objective-c methods do). our simple function adheres to that, but must still be cast to IMP to avoid compiler
	// warnings as the compiler does not see them as the same. the details of the IMP's arguments are held in the
	// type encoding which the runtime uses in various ways. it's important to get right.
	Method prototype = class_getInstanceMethod([FRQuery class], @selector(unevaluatedQuery));
	const char *types = method_getTypeEncoding(prototype);
	class_addMethod([FRQuery class], name, (IMP)FRQueryCreateBoundQuery, types);
	return [NSMethodSignature signatureWithObjCTypes:types];
}

- (id)boundQueryWithKey:(NSString *)key {
	id value = nil;
	
	SEL selector = NSSelectorFromString(key);
	[self resolveBindingMethod:selector]; // ensure method is defined before getting the imp
	id (*imp)(id self, SEL _cmd) = (void *)class_getMethodImplementation(object_getClass(self), selector);
	value = imp(self, selector);
	
	return value;
}

static id FRQueryCreateBoundQuery(id self, SEL _cmd) {
	// this is the actual imp that gets added for resolved binding methods. when it's called, we still don't really
	// know much about what we need to do to actually create a bound query. that means that we need to actually look
	// up which entity this is for. fortunately, this is easy to do because when the method gets called, the hidden
	// _cmd argument will contain the selector. for instance, when you call context.query.people, the context query
	// will be unbound, and the call to people will eventually result in this method being called with @selector(people)
	// as the _cmd argument (after a possible method resolution). @selector(people) is all we need to once again look
	// up the entity.
	FRQuery *query = self;
	NSEntityDescription *entity = [self entityForMethodName:_cmd];
	NSManagedObjectContext *context = query->_managedObjectContext;
	FRQuery *result = nil;
	if (entity) { result = [FRQuery queryWithEntity:entity managedObjectContext:context]; }
	else {
		// it's still possible that even though this method has been resolved, that we're now being called on a
		// different managed object context, so we'll throw an exception here to help the programmer.
		[self handleUnknownEntityWithName:NSStringFromSelector(_cmd)];
	}
	return result;
}

@end


#pragma mark -
#pragma mark managed object extension methods
// ----------------------------------------------------------------------------------------------------
// managed object extension methods
// ----------------------------------------------------------------------------------------------------

@implementation NSManagedObject (FRQueryPluralization)

// there are many other ways in which this pluralization could be done, but for this example providing a dynamic method
// lookup based on the key name is illustrative of a standard pattern used by Apple. this is very similar to the way
// that +[NSObject keyPathsForValuesAffectingValueForKey] uses helper methods to simplify the way developers return
// these key paths.
+ (NSString *)pluralizeKey:(NSString *)key {
	NSString *result = nil;
	SEL selector = NSSelectorFromString([NSString stringWithFormat:@"pluralize%@", [key capitalizedString]]);
	if ([self respondsToSelector:selector]) {
		// we need to look up the method implementation because of ARC. simply using performSelector: causes a warning
		// because ARC doesn't know what to do with the return type. this simple workaround casts the resulting IMP to
		// the proper type, and then calls it.
		result = ((NSString *(*)(id,SEL))[(id)self methodForSelector:selector])(self, selector);
	}
	else { result = [NSString stringWithFormat:@"%@s", key]; }
	return result;
}

@end
