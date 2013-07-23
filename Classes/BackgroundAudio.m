//
//  BackgroundAudio.m
//  MCPong
//
//  Created by erics on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackgroundAudio.h"

@implementation BackgroundAudio 

-(id) initWithFile:(NSString *)filename ofType:(NSString *)ext{
    if ((self=[super initWithFile:filename ofType:ext])){
        [self setNumberOfLoops: -1 ];
        [self setVolume:0.1];
    }
    return self;
    
}

@end
