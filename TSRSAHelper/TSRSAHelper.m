//
//  TSRSAHelper.m
//  Pods
//
//  Created by Johnson on 16/4/22.
//
//

#import "TSRSAHelper.h"

@implementation TSRSAHelper

+ (SecKeyRef)getPublicKeyFromCertPath:(NSString *)certPath
{
    NSData *certificateData = [[NSData alloc] initWithContentsOfFile:certPath];
    if (certificateData.length == 0) {
        return nil;
    }
    SecCertificateRef myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)certificateData);
    
    //got certificate ref..Now get public key secKeyRef reference from certificate..
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate, myPolicy, &myTrust);
    
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    return SecTrustCopyPublicKey(myTrust);
}

@end
