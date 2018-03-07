//
//  SEMoviewView.h
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface SEMoviewView : AVPlayerView

@property (nonatomic) CGFloat volume;

- (BOOL)isPlaying;

- (BOOL)loadMovieWithURL:(NSURL*)url;

- (void)closeMovie;

- (void)seekToSeconds:(double)seconds;

@end

