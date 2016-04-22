//
//  NSString+TSRSAHelper.h
//  Pods
//
//  Created by Johnson on 16/4/22.
//
//

#import <Foundation/Foundation.h>

@interface NSString (TSRSAHelper)

- (NSData *)encryptUsingKey:(SecKeyRef)key error:(NSError **)err;

- (NSString *)tsMD5;

@end
