//
//  GHCommit.m
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GHCommit.h"

@implementation GHCommit
@synthesize message = _message;
@synthesize url = _url;
@synthesize committer_date = _committer_date;
@synthesize committer_name = _committer_name;

-(id)initWithDictionary:(NSDictionary *)dictFromJSON
{
    self = [super init];
    if (self) {
        NSObject *commitObj = [dictFromJSON objectForKey:@"commit"];
        if ([commitObj isKindOfClass:[NSDictionary class]]) {
            _message = [(NSDictionary *)commitObj objectForKey:@"message"];
            _url = [(NSDictionary *)commitObj objectForKey:@"url"];
        }
        
        NSObject *committerObj = [(NSDictionary *)commitObj objectForKey:@"committer"];
        if ([committerObj isKindOfClass:[NSDictionary class]]) {
            _committer_name = [(NSDictionary *)committerObj objectForKey:@"name"];
            _committer_date = [(NSDictionary *)committerObj objectForKey:@"date"];
        }
    }
    
    return self;
}

-(id)init {
    return [self initWithDictionary:nil];
}

-(NSString *)summaryDescription
{
    return _message;
}

-(NSString *)detailDescription
{
    return [NSString stringWithFormat:@"%@ %@ %@", _committer_name, _committer_date, _url];
}

+(NSArray *)commitsFromJSON:(NSData *)jsonData
{
    NSError *parseError;
    NSObject *parsedObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    
    if (parsedObj == nil) {
        NSLog(@"Error parsing JSON: %@", [parseError localizedDescription]);
        return nil;
    }
    
    if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSArray *parsedCommits = (NSArray *)parsedObj;
        NSMutableArray *ghCommits = [[NSMutableArray alloc] initWithCapacity:[parsedCommits count]];
        for (NSObject *event in parsedCommits) {
            if ([event isKindOfClass:[NSDictionary class]]) {
                GHCommit *newCommit = [[GHCommit alloc] initWithDictionary:(NSDictionary *)event];
                [ghCommits addObject:newCommit];
                NSLog(@"Commit %@", newCommit);
            }
            NSLog(@"Number of commits: %d", [ghCommits count]);
        }
        return ghCommits;
    } else {
        return nil;
    }
}

@end
