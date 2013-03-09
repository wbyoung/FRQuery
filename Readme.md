# Simple Core Data Queries

This repository includes code demonstrating use of the Objective-C runtime to simplify queries for Core Data objects.

The code allows you to query for objects using lazily evaluated query objects. This is very similar to the way that object relational mapping frameworks in other languages work. The following examples show a little bit of what is possible with this extension to Core Data:


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

The resulting objects all act both as query objects, but also are array proxies, so you can enumerate them to quickly gain access to the results.

This example was created to accompany [a presentation](http://wbyoung.github.com/objective_c_runtime.pdf). There are no known issues with it, but please thoroughly test anything you use from this example before using it in production.
