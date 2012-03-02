//
//  GHCommit.h
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHCommit : NSObject
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *committer_date;
@property(nonatomic, copy) NSString *committer_name;

-(id)initWithDictionary:(NSDictionary *)dictFromJSON;
+(NSArray *)commitsFromJSON:(NSData *)jsonData;
-(NSString *)summaryDescription;
-(NSString *)detailDescription;
@end
