#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>

#import "Ball.h"
#import "ObjectiveChipmunk.h"
#import "Paddle.h"
#import "AntiBall.h"
#import "Cannon.h"
#import "BackgroundAudio.h"
#import "AudioClip.h"

@interface MCPongViewController : UIViewController 
{
	CADisplayLink *displayLink;
	
	IBOutlet UIImageView * scoreImageView;
	ChipmunkSpace *space;
	
	CGPoint touchStart;
	
	// To calculate and display FPS
	CFTimeInterval lastTimeStamp;
	unsigned int framesThisSecond;
	UILabel *fpsLabel;
	UILabel *loserLabel;
	UILabel *winnerLabel;
    UILabel *popLabel;
    UILabel *scoreLabel;
    
    UIView *screenGameOver;
	
	Paddle * paddle1;
	Paddle * paddle2;
    
    int score1; 
    int score2;
    BOOL scoreFlag;
    NSMutableSet *scoredBalls;
    NSMutableSet *balls;
    NSMutableSet *boomBalls;
    BOOL boomFlag;
    NSTimer *scoreTimer;
    
    Cannon *cannon;
    
    BOOL flStopped;
    BackgroundAudio *bg;
    AudioClip *bounceSound;
    AudioClip *padSound;
    AudioClip *score1Sound;
    AudioClip *score2Sound;
    AudioClip *annahilationSound;
    AudioClip *airWarningSound;
    BOOL flDidAirWarning;
    
}

-(void) postSolveCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space;
- (bool)beginBallAntiBallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space;
- (void)postBallAntiBallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space;

-(void) addNewBall:(cpVect)position :(cpVect)velocity;
-(void) spawnBall;
-(void) delaySpawn;
-(void) addNewAntiBall:(cpVect)position :(cpVect)velocity;
-(void) spawnAntiBall;
-(void) reapBall:(Ball *)theBall;
-(void) scoreBall:(Ball *)theBall;
-(void) gameOver;
-(void) restart;
-(void) startGame;
-(void) backgroundSound;

-(void)cleanBall:(Ball *)theBall;

@property(assign,nonatomic) int score1;
@property(assign,nonatomic) int score2;
@property(assign,nonatomic) BOOL scoreFlag;
@property(assign,nonatomic) BOOL boomFlag;
@property(assign,nonatomic) BOOL flStopped;
@property(assign,nonatomic) BOOL flDidAirWarning;
@property(nonatomic,retain) NSMutableSet *scoredBalls;
@property(nonatomic,retain) NSMutableSet *balls;
@property(nonatomic,retain) NSMutableSet *boomBalls;
@property(nonatomic,retain) NSTimer *scoreTimer;
@property(nonatomic,retain) Cannon *cannon;
@property(nonatomic,retain)     BackgroundAudio *bg;
@property(nonatomic, retain) AudioClip *bounceSound;
@property(nonatomic, retain) AudioClip *padSound;
@property(nonatomic, retain) AudioClip *score1Sound;
@property(nonatomic, retain) AudioClip *score2Sound;
@property(nonatomic, retain) AudioClip *annahilationSound;
@property(nonatomic, retain) AudioClip *airWarningSound;
@property(nonatomic, retain) UIView *screenGameOver;



@end
