//
//  AsynTask.h
//  TheoFetion
//
//  Created by 张神 on 11-1-14.
//  Copyright 2011 Theosoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AsynTask : NSObject {
	id _result;
	NSError *_error;
	id _delegate;
	SEL _delegateSelector;
	
	NSURL *_url;
	NSData *_postData;
	
	NSURLConnection*      _connection;
	NSHTTPURLResponse*    _urlResponse;
	NSMutableData*        _responseData;
	
}

@property (nonatomic, retain) id result;
@property (nonatomic, retain) NSError *error;

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSData *postData;

- (void)setDelegate:(id)delegate selector:(SEL)selector;
- (void)setParams:(NSString *)first, ...;
- (void)setParamString:(NSString *)wholeString;
- (void)run;
- (void)cancel;
- (void)drain;

+ (NSString *)userAgent;
+ (void)setUserAgent:(NSString *)agent;

@end
