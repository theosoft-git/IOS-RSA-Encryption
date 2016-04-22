//
//  TSRSAHelper.h
//  Pods
//
//  Created by Johnson on 16/4/22.
//
//

#import <Foundation/Foundation.h>

@interface TSRSAHelper : NSObject

+ (SecKeyRef)getPublicKeyFromCertPath:(NSString *)certPath;

@end
