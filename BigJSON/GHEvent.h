//
//  GHEvent.h
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHEvent : NSObject
@property(nonatomic, copy) NSString *repo_name;
@property(nonatomic, copy) NSString *repo_url;
@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *avatar_url;
@property(nonatomic, copy) UIImage *avatar_image;

-(id)initWithDictionary:(NSDictionary *)dictFromJSON;
+(NSArray *)eventsFromJSON:(NSData *)jsonData;
@end
