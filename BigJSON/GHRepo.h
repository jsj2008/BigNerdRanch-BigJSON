//
//  GHRepo.h
//  BigJSON
//
//  Created by sam_smith5 on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHRepo : NSObject

@property(nonatomic, copy) NSString *owner;
@property(nonatomic, copy) NSString *language;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSDate *createdDate;

-(id)initWithDictionary:(NSDictionary *)dictFromJSON;
+(NSArray *)reposFromJSON:(NSData *)jsonData;

@end
