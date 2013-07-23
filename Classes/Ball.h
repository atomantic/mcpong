#import <Foundation/Foundation.h>

#import "ObjectiveChipmunk.h"

@interface Ball : NSObject <ChipmunkObject> 
{
	UIImageView *imageView;
	
	ChipmunkBody *body;
    float direction;
	NSSet *chipmunkObjects;
}

@property (readonly) UIImageView *imageView;
@property (assign, nonatomic) float direction;
@property (readonly) NSSet *chipmunkObjects;

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity;
-(float)getRadius;
-(CGPoint)getPosition;
- (void)updatePosition;
-(NSString*)getFile;

@end
