//
//  SEStringEncoding.h
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEStringEncoding : NSObject

+ (NSMutableArray*)encodingArray;
+ (NSInteger)indexOfEncoding:(NSStringEncoding)encoding inArray:(NSArray*)array;

+ (NSString*)preproccessSubtitle:(NSString*)subtitle toArray:(NSMutableArray*)array; //return error string

@end
