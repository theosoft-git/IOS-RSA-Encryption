//
//  AsynTask.m
//  TheoFetion
//
//  Created by 张神 on 11-1-14.
//  Copyright 2011 Theosoft. All rights reserved.
//

#import "AsynTask.h"

static NSString *userAgent = nil;

@implementation AsynTask

@synthesize result = _result;
@synthesize error = _error;

@synthesize url = _url;
@synthesize postData = _postData;

- (id)initWithDelegate:(id)delegate selector:(SEL)selector {
	if(self == [self init]) {
		_delegate = delegate;
		_delegateSelector = selector;
	}
	return self;
}

- (void)setDelegate:(id)delegate selector:(SEL)selector {
	_delegate = delegate;
	_delegateSelector = selector;
}

- (void)setParams:(NSString *)first, ... {
	if(first) {
		NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"%@=", first];
		int i = 1;
		va_list ap;
		va_start(ap, first);
		NSString *s;
		while((s = va_arg(ap, NSString *))) {
			if(i % 2) {
				[str appendString:[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			} else {
				[str appendFormat:@"&%@=", s];
			}
			i++;
		}
		va_end(ap);
		[self setParamString:str];
	} else {
		self.postData = nil;
	}
}

- (void)setParamString:(NSString *)wholeString {
	self.postData = [wholeString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)run {
	if (_connection) {
		return;
	}
	NSURL *url = self.url;
	
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	[request setValue:@"UTF-8" forHTTPHeaderField:@"Charsert"];
	NSString *ua = [AsynTask userAgent];
	if(ua) {
		[request setValue:ua forHTTPHeaderField:@"User-Agent"];
		[request setValue:ua forHTTPHeaderField:@"Pragma"];
	}
	if (self.postData) {
		[request setHTTPMethod:@"POST"];
		NSData *data = self.postData;
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:data];		
	}
	
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)cancel {
	[_connection cancel];
}

- (void)drain {
	_delegate = nil;
	_delegateSelector = nil;
}

/////////////////////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  {
//	NSLog(@"接收完响应:%@",response);
	_urlResponse = (NSHTTPURLResponse *)response;
	_responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  {
//	NSLog(@"接收完数据:");
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error  {
//	NSLog(@"数据接收错误:%@",error);
	self.result = nil;
	self.error = error;
	
	[_delegate performSelector:_delegateSelector withObject:self];
	[self drain];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  {
//	NSLog(@"连接完成:%@",connection);
	if (_responseData && (_urlResponse.statusCode / 100 == 2)) {
		self.result = _responseData;
		self.error = nil;
	} else {
		NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_urlResponse.statusCode
										 userInfo:nil];
		NSLog(@"statusCode:%@", @(_urlResponse.statusCode));
		NSLog(@"didFailLoadWithError:%@", error);
		self.result = nil;
		self.error = error;
	}
	
	[_delegate performSelector:_delegateSelector withObject:self];
	[self drain];
}

///////////////////////////////////////////////////////////////////////////////////////

+ (NSString *)userAgent {
	if(userAgent == nil){
		userAgent = [@"Theosoft" copy];
	}
	return userAgent;
}

+ (void)setUserAgent:(NSString *)agent {
	if(userAgent != agent) {
		userAgent = [agent copy];
	}
}


@end
