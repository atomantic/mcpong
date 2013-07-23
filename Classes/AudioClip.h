//
//  AudioClip.h
//  MCPong
//
//  Created by erics on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioClip : NSObject <AVAudioPlayerDelegate> {
    AVAudioPlayer *player;
 
}
@property(nonatomic,retain)  AVAudioPlayer *player;
    
-(id) initWithFile:(NSString *)filename ofType:(NSString *)ext;
-(void) play;
-(void)stop;
-(void)setVolume:(float)vol;
-(void)setNumberOfLoops:(int)loops;


@end
