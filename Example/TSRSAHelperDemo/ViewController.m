//
//  ViewController.m
//  TSRSAHelperDemo
//
//  Created by Johnson on 16/4/22.
//  Copyright © 2016年 Theosoft. All rights reserved.
//

#import "ViewController.h"
#import "TSRSAHelper.h"
#import "AsynTask.h"
#import "NSString+TSRSAHelper.h"
#import "DataUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *plainStr = @"Just a test!";
    NSLog(@"Orignal str: %@", plainStr);
    
    //This is a test public key to encrypt
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"Theoservice" ofType:@"cer"];
    SecKeyRef key = [TSRSAHelper getPublicKeyFromCertPath:certPath];
    NSError *err = noErr;
    NSData *encrypted = [plainStr encryptUsingKey:key error:&err];
    if (err != noErr) {
        NSLog(@"Encrypt error!");
    }
    AsynTask *task = [self validateEncryptedData:encrypted];
    [task setDelegate:self selector:@selector(validateFinished:)];
    [task run];
}

- (AsynTask *)validateEncryptedData:(NSData *)encrypted
{
    AsynTask *task = [[AsynTask alloc] init];
    //The server has the test private key to decrypt
    task.url = [NSURL URLWithString:@"http://www.theopad.com/decrypt.php"];
    NSString *requestStirng = @"msg=";
    NSMutableData *postData = [NSMutableData dataWithData:[requestStirng dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *bString = [encrypted Base64Encode];
//    NSLog(@"encrypted: %@", [[NSString alloc] initWithData:bString encoding:NSASCIIStringEncoding]);
    [postData appendData:bString];
//    NSLog(@"postData: %@", postData);
    
    task.postData = postData;
    return task;
}

- (void)validateFinished:(AsynTask *)task
{
    if (task.result) {
        //We got the decrypted string from server
        NSString *content = [[NSString alloc] initWithData:task.result encoding:NSUTF8StringEncoding];
        NSLog(@"This is what you encrypted: %@", content);
    }
    else {
        NSLog(@"Error: %@", @([task.error code]));
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
