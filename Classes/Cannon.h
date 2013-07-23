//
//  Cannon.h
//  MCPong
//
//  Created by erics on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"


@interface Cannon : NSObject <ChipmunkObject> {
	UIImageView *imageView;
	
	ChipmunkBody *body;
	NSSet *chipmunkObjects;
    float direction;
    BOOL rotating;
}

@property (readonly) UIImageView *imageView;
@property (readonly) NSSet *chipmunkObjects;
@property (assign, nonatomic) float direction;
@property (assign, nonatomic) BOOL rotating;

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity;
-(float)getRadius;
-(CGPoint)getPosition;
- (void)updatePosition;
-(NSString*)getFile;

-(void) startRotating;
-(void) stopRotating;

@end
  