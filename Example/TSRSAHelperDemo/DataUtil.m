//
//  DataUtil.m
//  TheoFetion
//
//  Created by 张神 on 2010-10-28.
//  Copyright 2010 Theosoft. All rights reserved.
//

#import "DataUtil.h"
#include <zlib.h>

@implementation NSData (NSDataExtension)

- (NSData *)Base64Encode{
	//Point to start of the data and set buffer sizes
	NSInteger inLength = [self length];
	NSInteger outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
	const char *inputBuffer = [self bytes];
	char *outputBuffer = malloc(outLength);
	outputBuffer[outLength] = 0;
	
	//64 digit code
	static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	//start the count
	int cycle = 0;
	int inpos = 0;
	int outpos = 0;
	char temp = '\0';
	
	//Pad the last to bytes, the outbuffer must always be a multiple of 4
	outputBuffer[outLength-1] = '=';
	outputBuffer[outLength-2] = '=';
	
	/* http://en.wikipedia.org/wiki/Base64
	 Text content   M           a           n
	 ASCII          77          97          110
	 8 Bit pattern  01001101    01100001    01101110
	 
	 6 Bit pattern  010011  010110  000101  101110
	 Index          19      22      5       46
	 Base64-encoded T       W       F       u
	 */
	
	
	while (inpos < inLength){
		switch (cycle) {
			case 0:
				outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
				cycle = 1;
				break;
			case 1:
				temp = (inputBuffer[inpos++]&0x03)<<4;
				outputBuffer[outpos] = Encode[temp];
				cycle = 2;
				break;
			case 2:
				outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
				temp = (inputBuffer[inpos++]&0x0F)<<2;
				outputBuffer[outpos] = Encode[temp];
				cycle = 3;                  
				break;
			case 3:
				outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
				cycle = 4;
				break;
			case 4:
				outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
				cycle = 0;
				break;                          
			default:
				cycle = 0;
				break;
		}
	}
	return [NSData dataWithBytes:outputBuffer length:strlen(outputBuffer)];
}

@end
