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

#import "QueryTests.h"
#import "FRQuery_project.h"
#import "FRPerson.h"

@interface FRQuery (FRInvalidQueryBinding)
@property (nonatomic, readonly) id doNotExistThings;
@end

@implementation QueryTests

- (void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:0.0]; // hack for getting tests to run all the way through each time
}

- (void)testSimpleSyntaxExamples {
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	[coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
	[context setPersistentStoreCoordinator:coordinator];
	id people = nil;
	
	// create a simple query
	people = context.query.people[@"name = 'John'"];

	// create a query with a bunch of different conditions
	people = context.query.people[@{
		@"name__contains": @"an",
		@"age__gt": @(10),
		@"age_lte": @(60),
	}];
	
	// sort all people by name ascending
	people = context.query.people[@"^name"];

	// sort all people by age descending
	people = context.query.people[@"^-age"];
}

//- (void)testContextAdditions {
//	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
//	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
//	[coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
//	[context setPersistentStoreCoordinator:coordinator];
//	NSEntityDescription *personEntity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
//	
//	NSManagedObject *person1 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person1 setValue:@"John" forKey:@"name"];
//	[person1 setValue:@(25) forKey:@"age"];
//
//	NSManagedObject *person2 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person2 setValue:@"Tracy" forKey:@"name"];
//	[person2 setValue:@(48) forKey:@"age"];
//
//	NSManagedObject *person3 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person3 setValue:@"Bill" forKey:@"name"];
//	[person3 setValue:@(52) forKey:@"age"];
//
//	id people = context.query.people[@"^age"];
//	STAssertEqualObjects(people, (@[person1, person2, person3]), nil);
//	
//	people = context.query[@"people"][@"^age"];
//	STAssertEqualObjects(people, (@[person1, person2, person3]), nil);
//
//	id books = context.query[@"books"];
//	id indexes = context.query[@"indexes"];
//	if (books || indexes) {} // avoid compiler warnings
//
//	id invalid = nil;
//	STAssertThrows((invalid = context.query[@"^age"]), nil);
//	STAssertThrows((invalid = context.query.doNotExistThings), nil);
//	STAssertThrows((invalid = context.query[@(1)]), nil);
//	STAssertThrows((invalid = context.query[@{}]), nil);
//	STAssertThrows((invalid = context.query[@"asdf"]), nil);
//	STAssertThrows((invalid = context.query.fetchRequest), nil);
//	STAssertThrows((invalid = context.query[@"indexs"]), nil);
//}

//- (void)testQueriesDirectly {
//	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
//	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
//	[coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
//	[context setPersistentStoreCoordinator:coordinator];
//	NSEntityDescription *personEntity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
//	
//	NSManagedObject *person1 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person1 setValue:@"John" forKey:@"name"];
//	[person1 setValue:@(25) forKey:@"age"];
//	
//	id query = [FRQuery queryWithEntity:personEntity managedObjectContext:context];
//	STAssertEqualObjects([query objectAtIndex:0], person1, nil);
//	STAssertTrue([query isEqual:@[person1]], nil);
//	STAssertTrue([query isEqualToArray:@[person1]], nil);
//	STAssertTrue([@[person1] isEqual:query], nil);
//	STAssertTrue([@[person1] isEqualToArray:query], nil);
//	STAssertEqualObjects(query, @[person1], nil);
//	STAssertEqualObjects(@[person1], query, nil);
//	STAssertTrue([query isKindOfClass:[NSArray class]], nil);
//	STAssertEqualObjects([query fetchRequest].entity, personEntity, nil);
//	STAssertEqualObjects([query fetchRequest].sortDescriptors, nil, nil);
//
//	NSManagedObject *person2 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person2 setValue:@"Susan" forKey:@"name"];
//	[person2 setValue:@(43) forKey:@"age"];
//	
//	id filterQuery = [query filterQuery:@"age > 40"];
//	STAssertEquals([filterQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(filterQuery, @[person2], nil);
//	
//	id checkEvaluationQuery = [query filterQuery:@"age > 40"];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	checkEvaluationQuery = [checkEvaluationQuery filterQuery:@"age > 50"];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	checkEvaluationQuery = [checkEvaluationQuery sortQueryByKey:@"name" ascending:NO selector:@selector(caseInsensitiveCompare:)];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery description];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery debugDescription];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery descriptionWithLocale:[NSLocale currentLocale]];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery descriptionWithLocale:[NSLocale currentLocale] indent:1];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery respondsToSelector:@selector(description)];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery respondsToSelector:@selector(debugDescription)];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery respondsToSelector:@selector(descriptionWithLocale:)];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery respondsToSelector:@selector(descriptionWithLocale:indent:)];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[NSString stringWithFormat:@"%@", checkEvaluationQuery];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery fetchRequest];
//	STAssertFalse([checkEvaluationQuery isEvaluated], nil);
//	[checkEvaluationQuery count]; // array method should cause eval
//	STAssertTrue([checkEvaluationQuery isEvaluated], nil);
//
//	NSManagedObject *person3 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person3 setValue:@"Allan" forKey:@"name"];
//	[person3 setValue:@(13) forKey:@"age"];
//
//	id sortQuery = [query sortQueryByKey:@"age" ascending:YES];
//	STAssertEquals([sortQuery count], (NSUInteger)3, nil);
//	STAssertEqualObjects(sortQuery, (@[person3, person1, person2]), nil);
//
//	id limitQuery = [sortQuery limitQuery:2];
//	STAssertEquals([limitQuery count], (NSUInteger)2, nil);
//	STAssertEqualObjects(limitQuery, (@[person3, person1]), nil);
//	
//	NSManagedObject *person4 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person4 setValue:@"Gene" forKey:@"name"];
//	[person4 setValue:@(72) forKey:@"age"];
//
//	id filterChainQuery = [filterQuery filterQuery:@"age < 70"];
//	STAssertEquals([filterChainQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(filterChainQuery, @[person2], nil);
//	
//	id subscriptedQuery = query[@"age < 70"][@"^name"]; // ascending
//	STAssertEquals([subscriptedQuery count], (NSUInteger)3, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person1, person2]), nil);
//	
//	subscriptedQuery = [query filterQuery:@"age < %@", @(70)][@"^-name"]; // descending
//	STAssertEquals([subscriptedQuery count], (NSUInteger)3, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person2, person1, person3]), nil);
//	
//	// test dictionary based methods
//	subscriptedQuery = query[@{ @"age__lte" : @(43) }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)3, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person1, person2]), nil);
//
//	subscriptedQuery = query[@{ @"age__lt" : @(43) }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)2, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person1]), nil);
//
//	subscriptedQuery = query[@{ @"age__gte" : @(70) }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//	
//	subscriptedQuery = query[@{ @"age__gt" : @(43) }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{ @"age__exact" : @(72) }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{ @"age" : @(72) }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{ @"name__contains" : @"an" }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)2, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person2]), nil);
//
//	subscriptedQuery = query[@{ @"name__contains[cd]" : @"Añ" }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)2, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person2]), nil);
//
//	subscriptedQuery = query[@{ @"name__beginswith" : @"Ge" }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{ @"name__beginswith[cd]" : @"GE" }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{ @"name__endswith" : @"ne" }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{ @"name__endswith[cd]" : @"nE" }][@"^name"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)1, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person4]), nil);
//
//	subscriptedQuery = query[@{}][@"^age"];
//	STAssertEquals([subscriptedQuery count], (NSUInteger)4, nil);
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person1, person2, person4]), nil);
//
//	// test invalid queries & method calls
//	STAssertThrows((subscriptedQuery = query[@{@"name__asdf": @(true)}]), nil);
//	STAssertThrows((subscriptedQuery = query[@{@"name__contains__contains": @(true)}]), nil);
//	STAssertThrows((subscriptedQuery = query[@{@(1) : @(1)}]), nil);
//	STAssertThrows((subscriptedQuery = query[@(1)]), nil);
//	STAssertThrows(([query length]), nil);
//	
//	// test multiple sort
//	NSManagedObject *person5 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person5 setValue:@"Gene" forKey:@"name"];
//	[person5 setValue:@(73) forKey:@"age"];
//	NSManagedObject *person6 = [[NSManagedObject alloc] initWithEntity:personEntity insertIntoManagedObjectContext:context];
//	[person6 setValue:@"Gene" forKey:@"name"];
//	[person6 setValue:@(25) forKey:@"age"];
//
//	subscriptedQuery = query[@"^age,-name"];
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person1, person6, person2, person4, person5]), nil);
//
//	subscriptedQuery = query[@"^-age,-name"];
//	STAssertEqualObjects(subscriptedQuery, (@[person5, person4, person2, person1, person6, person3]), nil);
//
//	subscriptedQuery = query[@"^-age,name"];
//	STAssertEqualObjects(subscriptedQuery, (@[person5, person4, person2, person6, person1, person3]), nil);
//
//	subscriptedQuery = query[@"^name,age"];
//	STAssertEqualObjects(subscriptedQuery, (@[person3, person6, person4, person5, person1, person2]), nil);
//
//	subscriptedQuery = query[@"^-name,age"];
//	STAssertEqualObjects(subscriptedQuery, (@[person2, person1, person6, person4, person5, person3]), nil);
//
//	subscriptedQuery = query[@"^-name,-age"];
//	STAssertEqualObjects(subscriptedQuery, (@[person2, person1, person5, person4, person6, person3]), nil);
//}

@end
