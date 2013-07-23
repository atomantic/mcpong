//
//  Cannon.m
//  MCPong
//
//  Created by erics on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cannon.h"

#define RADIUS 100.0f

@implementation Cannon

@synthesize imageView;
@synthesize chipmunkObjects;
@synthesize direction;
@synthesize rotating;

- (void)updatePosition 
{
    if (self.rotating){
        direction = direction + 1.0;
        imageView.transform =  CGAffineTransformConcat(CGAffineTransformMakeRotation(direction * ((float)M_PI / 180.0f)), CGAffineTransformMakeTranslation(body.pos.x - RADIUS, body.pos.y - RADIUS));
    }
                                                   
}

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity
{
	if((self = [super init]))
	{
		UIImage *image = [UIImage imageNamed:[self getFile]];		
		imageView = [[UIImageView alloc] initWithImage:image];
		
        direction = 45.0;
        self.rotating = YES;
		// Set up Chipmunk objects.
		cpFloat mass = 10000000.0f;
		
		// Center of mass is center of ball
		cpVect offset;
		offset.x = 0;
		offset.y = 0;
		
		cpFloat moment = cpMomentForCircle(mass, 0, RADIUS, offset);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = position;
		body.vel = velocity;
		
		ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:RADIUS offset:offset];
		
		// So it will bounce forever
		shape.elasticity = 1.0f;
		shape.friction = 0.0f;
		
		shape.collisionType = [self class];
		shape.data = self;
		
		chipmunkObjects = [ChipmunkObjectFlatten(body, shape, nil) retain];
	}
	
	return self;
}

-(NSString*)getFile{
    return @"turret.png";
}

- (float)getRadius{
    return RADIUS;
}

-(CGPoint) getPosition{
    return CGPointMake(body.pos.x, body.pos.y);
}

-(void) stopRotating{
    self.rotating = NO;
}
-(void) startRotating{
    self.rotating = YES;
}

- (void) dealloc
{
	[imageView release];
	[body release];
	[chipmunkObjects release];
	
	[super dealloc];
}

@end

