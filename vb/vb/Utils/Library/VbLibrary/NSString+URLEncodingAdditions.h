//
//  NSString+URLEncodingAdditions.h
//  vb
//
//  Created by 马权 on 6/2/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncodingAdditions)

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end
