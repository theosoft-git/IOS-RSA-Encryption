//
//  NSString+TSRSAHelper.m
//  Pods
//
//  Created by Johnson on 16/4/22.
//
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+TSRSAHelper.h"

@implementation NSString (TSRSAHelper)

- (NSData *)encryptUsingKey:(SecKeyRef)key error:(NSError **)err
{
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = NULL;
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0x0, cipherBufferSize);
    NSData *plainTextBytes = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger blockSize = cipherBufferSize - 11;
    NSInteger numBlock = (NSInteger)ceil([plainTextBytes length] / (CGFloat)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (NSUInteger i = 0; i < numBlock; i++) {
        NSUInteger bufferSize = MIN(blockSize,[plainTextBytes length] - i * blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length], cipherBuffer,
                                        &cipherBufferSize);
        if (status == noErr) {
            NSData *encryptedBytes = [[NSData alloc]
                                       initWithBytes:(const void *)cipherBuffer
                                       length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }
        else {
            *err = [NSError errorWithDomain:@"errorDomain" code:status userInfo:nil];
            NSLog(@"encrypt:usingKey:Error: %@", @(status));
            return nil;
        }
    }
    if (cipherBuffer) {
        free(cipherBuffer);
    }
    NSLog(@"Encrypted text (%@ bytes): %@", @([encryptedData length]), [encryptedData description]);
    return encryptedData;
}

- (NSString *)tsMD5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

@end
