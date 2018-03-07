//
//  SEView.h
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^SEDraggingCompletionBlock)(NSURL* url);


@interface SEView : NSView

@property (nonatomic, assign) BOOL      highlighted;

@property (nonatomic, strong) NSColor*  backgroundColor;

// Dragging (only files)
@property (nonatomic, strong) NSArray* allowedFileExtensions;

@property (copy) SEDraggingCompletionBlock draggingCompletionBlock;

@end
