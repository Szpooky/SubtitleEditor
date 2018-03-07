//
//  SENode.h
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENode : NSObject

//@property (nonatomic, assign)   SEDuration          duration;

@property (nonatomic, assign)   double              startTime;
@property (nonatomic, assign)   double              endTime;
@property (nonatomic, strong)   NSString*           text;
@property (nonatomic, assign)   BOOL                textProblem;
@property (nonatomic, assign)   NSUInteger          error;
@property (nonatomic, assign)   BOOL                selected;
@property (nonatomic, weak)     id                  boxView;

- (NSString*)stringValue;
- (BOOL)conflictWithNode:(SENode*)node;
//- (void)undo;

@end
