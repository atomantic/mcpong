//
//  AudioClip.m
//  MCPong
//
//  Created by erics on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioClip.h"


@implementation AudioClip
@synthesize player;

-(id) initWithFile:(NSString *)filename ofType:(NSString *)ext{
    if ((self=[super init])){
        NSError *error;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:ext];  
        NSData *audioData = [NSData dataWithContentsOfFile:filePath];  
        
        self.player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
        if (error) {
            return self;
        }
        [self setNumberOfLoops:0];
        [self setVolume:1.0];
    }
    return self;
}

-(void) play{
    [self.player play];
}
-(void) stop{
    [self.player stop];
}
-(void)setVolume:(float)vol{
    [player setVolume:vol];   
}
-(void)setNumberOfLoops:(int)loops{
    [player setNumberOfLoops: loops ];
}
@end


