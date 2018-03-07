//
//  SETimeLineView.h
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SESubtitleBoxView.h"

@interface SETimeLineView : SEView

@property (nonatomic)           double              currentTime;        // current time in second
@property (nonatomic, readonly) NSTextField*        currentTimeLabel;

+ (NSArray*)allowedSubtitles;

- (void)reload;
- (void)update;
- (void)updateDisplay;  //call setNeedDisplay: method here and in all subview too.
- (void)jumpToTime:(double)time;
- (NSRect)makeNodeFrame:(SENode*)node;
- (void)detectVisibleConflict;
- (void)determineCurrentNode;
- (SESubtitleBoxView*)reuseSubtitleBoxByNode:(SENode*)node;

@end

