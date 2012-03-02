//
//  GHKeychainHelper.m
//  BigJSON
//
//  Created by sam_smith5 on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GHKeychainHelper.h"
#import <Security/Security.h>

@implementation GHKeychainHelper

+(NSMutableDictionary *)queryForAccount:(NSString *)account
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            kSecClassGenericPassword, kSecClass,
            @"com.bignerdranch.bigjson", kSecAttrService,   // com.bignerdranch.githubbrowser
            account, kSecAttrAccount, nil];
}

+(NSString *)passwordForAccount:(NSString *)account found:(BOOL *)found
{
    NSMutableDictionary *query = [GHKeychainHelper queryForAccount:account];
    [query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
    NSData *data = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (const void **)&data);
    *found = status != errSecItemNotFound;
    NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [password autorelease];
}

+(BOOL)setPassword:(NSString *)password forAccount:(NSString *)account
{
    NSData *pwData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *attrs = [GHKeychainHelper queryForAccount:account];
    [attrs setObject:pwData forKey:kSecValueData];
    [attrs setObject:kSecAttrAccessibleWhenUnlocked forKey:kSecAttrAccessible];
    OSStatus status = SecItemAdd((CFDictionaryRef)attrs, NULL);
    return status == noErr;
}

+(BOOL)updatePassword:(NSString *)password forAccount:(NSString *)account
{
    NSData *pwData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *query = [GHKeychainHelper queryForAccount:account];
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [query setObject:pwData forKey:kSecValueData];
    [attrs setObject:kSecAttrAccessibleWhenUnlocked forKey:kSecAttrAccessible];
    OSStatus status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef) attrs);
    return status == noErr;
}

@end
