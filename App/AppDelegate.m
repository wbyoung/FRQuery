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

#import "AppDelegate.h"
#import "FRPerson.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	// set up the core data stack
    NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *documents = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *storeURL = [[documents lastObject] URLByAppendingPathComponent:@"Query.sqlite"];
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		NSLog(@"Core Data setup error: %@", error);
		[NSException raise:NSInternalInconsistencyException format:@"Core Data save error: %@", error];
    }
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[context setPersistentStoreCoordinator:coordinator];
	[self setManagedObjectContext:context];
	[self setPersistentStoreCoordinator:coordinator];

	// though the application displays a message saying it does nothing, it actually creates one chained query just to
	// show that it only executes one fetch request (one SQL request) for that query. the Core Data SQL debug flag is
	// enabled for this application.
//	NSLog(@"--------------------------------------------------------------------------------------------------------");
//	id people = context.query.people[@"age >= 13"][@"age < 20"];
//	NSLog(@"Created a query: %@", people);
//	NSLog(@"Executed a query and got results: %@", [people copy]);
//	NSLog(@"--------------------------------------------------------------------------------------------------------");

	// create a window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
	self.window.rootViewController = [[UIViewController alloc] init];

	// create a label with some text so people know to run the tests and look at the code
	NSString *mainText = NSLocalizedString(@"This application does nothing.\n\n", nil);
	NSDictionary *mainAttributes = @{
		NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:1],
		NSFontAttributeName: [UIFont systemFontOfSize:30],
	};
	NSString *extraText = NSLocalizedString(@"Please run the tests with \u2318U and explore the code.", nil);
	NSDictionary *extraAttributes = @{
		NSForegroundColorAttributeName: [UIColor colorWithWhite:0.75 alpha:1],
		NSFontAttributeName: [UIFont systemFontOfSize:22],
	};
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
	[text appendAttributedString:[[NSAttributedString alloc] initWithString:mainText attributes:mainAttributes]];
	[text appendAttributedString:[[NSAttributedString alloc] initWithString:extraText attributes:extraAttributes]];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.window.bounds, 40, 40)];
	label.backgroundColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	label.attributedText = text;
	
	// show the window
	[self.window.rootViewController.view addSubview:label];
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Core Data save error: %@", error);
		[NSException raise:NSInternalInconsistencyException format:@"Core Data save error: %@", error];
	}
}

@end
