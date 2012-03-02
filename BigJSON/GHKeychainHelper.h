//
//  GHKeychainHelper.h
//  BigJSON
//
//  Created by sam_smith5 on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHKeychainHelper : NSObject
+(NSString *)passwordForAccount:(NSString *)account found:(BOOL *)found;
+(BOOL)setPassword:(NSString *)password forAccount:(NSString *)account;
+(BOOL)updatePassword:(NSString *)password forAccount:(NSString *)account;

@end
