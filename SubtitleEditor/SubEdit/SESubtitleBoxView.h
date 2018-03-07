//
//  SESubtitleBoxView.h
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEView.h"

#define BOX_HEIGHT 30.0
#define BOX_ORIGIN_Y 108.0
#define SPEED_SCALE 10.0

enum dragType
{
    DragTypeNone =0,
    DragTypeLeft = 1,
    DragTypeRight = 2,
    DragTypeCenter = 3,
    
    DragTypeRightMouse = 4,
    DragTypeOtherMouse = 5
};


@interface SESubtitleBoxView : SEView

@property (nonatomic, assign)   SENode*     node;
@property (nonatomic, assign)   NSUInteger  dragType;

- (void)update;
- (void)updateError;

@end
