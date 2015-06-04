//
//  NSString+URLEncodingAdditions.m
//  vb
//
//  Created by 马权 on 6/2/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "NSString+URLEncodingAdditions.h"

@implementation NSString (URLEncodingAdditions)

- (NSString *)URLEncodedString
{
    NSString *result = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)self,
                                                                                              NULL,
                                                                                              CFSTR("!*'();:@&=+$,/?%#[] "),
                                                                                              kCFStringEncodingUTF8));
    return result;
}

- (NSString*)URLDecodedString
{
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                              (CFStringRef)self,
                                                                              CFSTR(""),
                                                                              kCFStringEncodingUTF8));
    return result;  
}

@end
