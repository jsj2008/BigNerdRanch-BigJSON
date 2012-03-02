//
//  GHEvent.m
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GHEvent.h"

@implementation GHEvent
@synthesize repo_name = _repo_name;
@synthesize repo_url = _repo_url;
@synthesize username = _username;
@synthesize avatar_url = _avatar_url;
@synthesize avatar_image = _avatar_image;

-(id)initWithDictionary:(NSDictionary *)dictFromJSON
{
    self = [super init];
    if (self) {
        NSObject *repoObj = [dictFromJSON objectForKey:@"repo"];
        if ([repoObj isKindOfClass:[NSDictionary class]]) {
            _repo_name = [(NSDictionary *)repoObj objectForKey:@"name"];
            _repo_url = [(NSDictionary *)repoObj objectForKey:@"url"];
        }
        
        NSObject *actorObj = [dictFromJSON objectForKey:@"actor"];
        if ([actorObj isKindOfClass:[NSDictionary class]]) {
            _username = [(NSDictionary *)actorObj objectForKey:@"login"];
            _avatar_url = [(NSDictionary *)actorObj objectForKey:@"avatar_url"];
        }
    }
    return self;
}

-(id)init {
    return [self initWithDictionary:nil];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@", [super description], _repo_name, _username];
}

+(NSArray *)eventsFromJSON:(NSData *)jsonData
{
    NSError *parseError;
    NSObject *parsedObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    
    if (parsedObj == nil) {
        NSLog(@"Error parsing JSON: %@", [parseError localizedDescription]);
        return nil;
    }
    
    if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSArray *parsedEvents = (NSArray *)parsedObj;
        NSMutableArray *ghEvents = [[NSMutableArray alloc] initWithCapacity:[parsedEvents count]];
        for (NSObject *event in parsedEvents) {
            if ([event isKindOfClass:[NSDictionary class]]) {
                GHEvent *newEvent = [[GHEvent alloc] initWithDictionary:(NSDictionary *)event];
                [ghEvents addObject:newEvent];
                NSLog(@"Event %@", newEvent);
            }
            NSLog(@"Number of events: %d", [ghEvents count]);
        }
        return ghEvents;
    } else {
        return nil;
    }
}

@end
