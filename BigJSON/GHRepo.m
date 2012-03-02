//
//  GHRepo.m
//  BigJSON
//
//  Created by sam_smith5 on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GHRepo.h"

@implementation GHRepo
@synthesize owner, language, name, createdDate;

static NSDateFormatter *isoDateFormatter = nil;

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@) %@", name, language, owner];
}

-(id)initWithDictionary:(NSDictionary *)dictFromJSON
{
    self = [super init];
    if (self) {
        name = [dictFromJSON valueForKeyPath:@"name"];
        owner = [dictFromJSON valueForKeyPath:@"owner.login"];
        language = [dictFromJSON valueForKeyPath:@"language"];
        
        // Parse date
        if (!isoDateFormatter) {
            isoDateFormatter = [[NSDateFormatter alloc] init];
            [isoDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
        }
        NSString *dateStr = [[dictFromJSON valueForKeyPath:@"created_at"] substringToIndex:18];
        createdDate = [isoDateFormatter dateFromString:dateStr];
    }
    
    return self;
}

+(NSArray *)reposFromJSON:(NSData *)jsonData
{
    NSError *parseError;
    NSObject *parsedObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    
    if (parseError) {
        NSLog(@"Error parsing JSON: %@", parseError);
        return nil;
    }
    
    if ([parsedObj isKindOfClass:[NSArray class]]) {
        NSArray *parsedEvents = (NSArray *)parsedObj;
        NSMutableArray *ghEvents = [[NSMutableArray alloc] init];
        for (NSObject *event in parsedEvents) {
            if ([event isKindOfClass:[NSDictionary class]]) {
                NSDictionary *repoDict = (NSDictionary *)event;
                GHRepo *newEvent = [[GHRepo alloc] initWithDictionary:repoDict];
                [ghEvents addObject:newEvent];
            }
        }
        return ghEvents;
    } else {
        return nil;
    }
}

@end
