#import "MCPongViewController.h"
#import "SimpleSound.h"

#define TEST_BALL_COUNT 200
#define DEBUG_MODE false
#define SCORE_LIMIT 7

@implementation MCPongViewController

static NSString *borderType = @"borderType";
static cpFloat frand_unit(){return 2.0f*((cpFloat)rand()/(cpFloat)RAND_MAX) - 1.0f;}

@synthesize score1;
@synthesize score2;
@synthesize scoreFlag;
@synthesize scoredBalls;
@synthesize balls;
@synthesize boomFlag;
@synthesize boomBalls;
@synthesize cannon;
@synthesize scoreTimer;
@synthesize flStopped;
@synthesize bg;
@synthesize bounceSound;
@synthesize score1Sound;
@synthesize score2Sound;
@synthesize padSound;
@synthesize annahilationSound;
@synthesize airWarningSound;
@synthesize flDidAirWarning;
@synthesize screenGameOver;

- (void)viewDidLoad 
{
	[super viewDidLoad];
    self.scoredBalls = [NSMutableSet set];
    self.balls = [NSMutableSet set];
    self.boomBalls = [NSMutableSet set];
	
	space = [[ChipmunkSpace alloc] init];

    
    // background
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"grid.png"]];
    UIImageView *background2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"grid2.png"]];
    background.frame = self.view.bounds; 
    background2.frame = self.view.bounds; 
    [self.view addSubview:background];
    [self.view addSubview:background2];
    
//#[UIImageView animateWithDuration:10.0 delay:0.0 options:UIViewAnimationOptionRepeat & UIViewAnimationOptionAllowUserInteraction
//                          animations:^{background2.alpha=0.0; background2.alpha=1.0;} completion:^(BOOL f){}];
    
    CABasicAnimation *backgroundAnimationIAmDescriptiveYayAutoComplete = [CABasicAnimation animationWithKeyPath:@"opacity"];
    backgroundAnimationIAmDescriptiveYayAutoComplete.fromValue = [NSNumber numberWithInt:1];
    backgroundAnimationIAmDescriptiveYayAutoComplete.toValue = [NSNumber numberWithInt:0];
    backgroundAnimationIAmDescriptiveYayAutoComplete.duration = 5;
    backgroundAnimationIAmDescriptiveYayAutoComplete.repeatCount = 1e10f;
    backgroundAnimationIAmDescriptiveYayAutoComplete.autoreverses = YES;
    [background2.layer addAnimation:backgroundAnimationIAmDescriptiveYayAutoComplete forKey:@"opacity"];
        
    self.view.multipleTouchEnabled = YES;
    
	
	// Setup boundary at screen edges
	[space addBounds:self.view.bounds thickness:10.0f elasticity:1.03f friction:1.01f 
			  layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:borderType];
	
	// Collision handler for ball - border
	[space addCollisionHandler:self
						 typeA:[Ball class] typeB:borderType
						 begin:@selector(beginWallCollision:space:)
					  preSolve:nil
					 postSolve:@selector(postSolveCollision:space:)						
					  separate:nil
	 ];

    [space addCollisionHandler:self
						 typeA:[AntiBall class] typeB:[Ball class]
						 begin:@selector(beginBallAntiBallCollision:space:)
                      preSolve:nil
					 postSolve:@selector(postBallAntiBallCollision:space:)						
					  separate:nil
	 ];

    [space addCollisionHandler:self
						 typeA:[Ball class] typeB:[Paddle class]
						 begin:nil
                      preSolve:nil
					 postSolve:@selector(postPoodlePaddleBattleCollision:space:)						
					  separate:nil
	 ];

	// Setup FPS label
    if(DEBUG_MODE){
        framesThisSecond = 0;
        CGRect  labelRect = CGRectMake(10, 0, 100, 30);
        fpsLabel = [[UILabel alloc] initWithFrame:labelRect];
        fpsLabel.text = @"0 FPS";
        [self.view addSubview:fpsLabel];
    }
	
    // Setup Score label
	CGRect  scoreLabelRect = CGRectMake(
                                        -180,
                                        (int)(self.view.frame.size.height/2.0f)-100, 
                                        500, 
                                        200
                                        );
    
	scoreLabel = [[UILabel alloc] initWithFrame:scoreLabelRect];
    [scoreLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:128.0]];
    scoreLabel.textAlignment = UITextAlignmentCenter;
	scoreLabel.text = @"0:0";
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.transform = CGAffineTransformMakeRotation(90 * ((float)M_PI / 180.0f));
    scoreLabel.alpha = 0;
    scoreLabel.userInteractionEnabled = NO;
    [self.view addSubview:scoreLabel];
  
    cannon = [[Cannon alloc] initWithPosition:cpv(368.0, 504.0) Velocity: cpv(0.0,0.0)];
	[self.view addSubview:cannon.imageView];
	[space add:cannon];    
    
	paddle1 = [[Paddle alloc] initWithPosition:cpv(368.0,68.0) Dimensions:cpv(110.0, 32.0)];
	[self.view addSubview:paddle1.imageView];
	[space add:paddle1];
	
	paddle2 = [[Paddle alloc] initWithPosition:cpv(368.0,940.0) Dimensions:cpv(110.0, 32.0)];
	[self.view addSubview:paddle2.imageView];
	[space add:paddle2];
    
    
    [paddle1 addTarget:self action:@selector(paddle1jump) forControlEvents:UIEventTypeTouches];
    
    
    [paddle2 addTarget:self action:@selector(paddle2jump) forControlEvents:UIEventTypeTouches];
    


    self.bg = [[BackgroundAudio alloc] initWithFile:@"happyuphere" ofType:@"mp3"];
    self.bounceSound = [[AudioClip alloc] initWithFile:@"bounce" ofType:@"wav"];    
    self.score1Sound = [[AudioClip alloc] initWithFile:@"score" ofType:@"wav"];    
    self.score2Sound = [[AudioClip alloc] initWithFile:@"score2" ofType:@"wav"];    
    self.padSound = [[AudioClip alloc] initWithFile:@"padbounce" ofType:@"wav"];    
    self.annahilationSound = [[AudioClip alloc] initWithFile:@"annahilation" ofType:@"wav"];    
    self.airWarningSound = [[AudioClip alloc] initWithFile:@"airwarning" ofType:@"wav"];    

    [self startGame];
}

-(void) backgroundSound{
    

}

- (void) startGame{
    score1 = 0;
    score2 = 0;
    scoreFlag = false;
    boomFlag = false;
    flStopped = false;
    flDidAirWarning = false;
    [self.bg play];
    self.scoreTimer = [NSTimer scheduledTimerWithTimeInterval:7.5 target:self selector:@selector(delaySpawn) userInfo:NULL repeats:YES];
       
    [self spawnBall];
}


- (void)postSolveCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space 
{
	// Only play sound on first frame of the collision
	if(cpArbiterIsFirstContact(arbiter)) {	
        [self.bounceSound play];
	}
}


- (bool)beginWallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, theBall, border);
	
	//Paddle * p = paddle.data;
    Ball * b = theBall.data;
    
    
    if (([b getPosition].y < [b getRadius]+1) || 
        ([b getPosition].y > self.view.bounds.size.height - [b getRadius] -2 )){
        [self scoreBall:b];
        return false;            
    }
    return true;    
}


- (void)postPoodlePaddleBattleCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space 
{
	// Only play sound on first frame of the collision
	if(cpArbiterIsFirstContact(arbiter)) 
	{	
		[self.padSound play];
	}
}

- (void)postBallAntiBallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space 
{
	// Only play sound on first frame of the collision
	if(cpArbiterIsFirstContact(arbiter)) 
	{	
        [self.annahilationSound play];
	}
}




- (bool)beginBallAntiBallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, theAntiBall, theBall);
	
	//Paddle * p = paddle.data;
    Ball *b = theBall.data;
    AntiBall *ab= theAntiBall.data;
    
    [self.boomBalls addObject:b];
    [self.boomBalls addObject:ab];
    self.boomFlag = true;
    
    return true;    
}



- (void)viewDidAppear:(BOOL)animated
{
	// Set up the display link to control the timing of the animation.
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)update
{
    if (self.flStopped){
        return;
    }
	// Update FPS
	if ( framesThisSecond == 0 ) 
	{
		lastTimeStamp = CFAbsoluteTimeGetCurrent();
		framesThisSecond++;
	}
	else 
	{
		CFTimeInterval elapsed = (CFAbsoluteTimeGetCurrent() - lastTimeStamp);
		if ( elapsed < 1 )
		{
			framesThisSecond++;
		}
		else
		{
			NSString *str = [NSString stringWithFormat:@"%d FPS", framesThisSecond];
			fpsLabel.text = str;
			framesThisSecond = 0;
		}
	}
    
	// Update Physics space
	cpFloat dt = displayLink.duration * displayLink.frameInterval;
	[space step:dt];
	
    if (scoreFlag) {
        for (Ball *ball in self.scoredBalls){
            [self reapBall:ball];
            [self delaySpawn];
            if ([balls count] > 2){
                if (!self.flDidAirWarning){
                    self.flDidAirWarning = true;
                    [self.airWarningSound play];
                }
                [self spawnAntiBall];
            }
        }
        [self.scoredBalls removeAllObjects];  
        self.scoreFlag = false;
    }
    if (boomFlag) {
        for (Ball *ball in self.boomBalls){
            // UNDONE   Boom. 
            [self reapBall:ball];
        }
    }
    
    for (Ball *ball in balls){
        [ball updatePosition];
    }

    [paddle1 updatePosition];
	[paddle2 updatePosition];
    [cannon updatePosition];
	// Update ball positions to match the physics bodies
	
}

- (void)viewDidDisappear:(BOOL)animated 
{
	[displayLink invalidate];
	[scoreImageView release];
	displayLink = nil;
}

- (void)dealloc 
{
	[space release];
	[scoreLabel release];
	[paddle1 release];
	[paddle2 release];
	if(DEBUG_MODE){
        [fpsLabel release];
    }
	[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	touchStart = [touch locationInView:self.view];
	
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
		if (point.y > self.view.frame.size.height/2.0f) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
		else {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
		if (point.y > self.view.frame.size.height/2.0f) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
		else {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
        
	}
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
		if (point.y > self.view.frame.size.height/2.0f) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
		else {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		
	}
}

- (void)addNewBall:(cpVect)position :(cpVect)velocity 
{
    Ball *ball = [[Ball alloc] initWithPosition:position Velocity:velocity];	
    
	// Add to view, physics space, our list
	[self.view addSubview:ball.imageView];
    [balls addObject:ball];
    [space add:ball];		
}

- (void)addNewAntiBall:(cpVect)position :(cpVect)velocity 
{
    AntiBall *ball = [[AntiBall alloc] initWithPosition:position Velocity:velocity];	
    
	// Add to view, physics space, our list
	[self.view addSubview:ball.imageView];
    [balls addObject:ball];
    [space add:ball];		
}

-(void)delaySpawn{
    [self.cannon stopRotating];
    NSTimer *trigger = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
                                                      selector:@selector(spawnBall) userInfo:NULL repeats:NO];
    NSTimer *cannonStart = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.cannon 
                                                          selector:@selector(startRotating) userInfo:NULL repeats:NO];
}

-(void) spawnBall{
    float angle = cannon.direction * ((float)M_PI / 180.0f);    
   	cpVect position = cpv(368.0, 504.0);
    cpVect velocity = cpvmult(cpv(cos(angle), sin(angle)), 500.0f);
    [self addNewBall:position :velocity]; 
    [self.view bringSubviewToFront:cannon.imageView];
}

-(void) spawnAntiBall{
	CGRect frame = self.view.frame;
   	cpVect position = cpv(rand() % (int)frame.size.width, rand() % (int)frame.size.height);
    cpVect velocity = cpvmult(cpv(frand_unit(), MAX(frand_unit(),0.2)), 400.0f);
    [self addNewAntiBall:position :velocity]; 
}


-(void)reapBall:(Ball *)theBall{
    [theBall.imageView removeFromSuperview];
    //NSLog(@"removing %@",theBall);
    [space remove:theBall];
    [balls removeObject:theBall];
    [boomBalls removeObject:theBall];
}

-(void)cleanBall:(Ball *)theBall {
    [theBall.imageView removeFromSuperview];
    [space remove:theBall];   
}

-(void)scoreBall:(Ball *)theBall{
    if ([theBall getPosition].y < (self.view.bounds.size.height /2)){
        self.score1++;
        [self.score1Sound play];
    } else {
        self.score2++;
        [self.score2Sound play];
    }

    self.scoreFlag = true;
    //NSLog(@"adding %@",theBall);
    [self.scoredBalls addObject:theBall];
    scoreLabel.text = [NSString stringWithFormat:@"%d : %d", self.score2, self.score1];
    if (scoreLabel.alpha ==0.0) {
        [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^{scoreLabel.alpha = 1.0;} 
                         completion:^(BOOL finished){}]; 
    }                         
    if (self.score1 >= SCORE_LIMIT || self.score2 >= SCORE_LIMIT) {
        [self gameOver];
    }
}
-(void) gameOver{
    self.flStopped = true;
    [self.bg stop];
    [self.scoreTimer invalidate];
    self.scoreTimer = nil;
    UIView *gameOverScreen = [[UIView alloc] initWithFrame:(CGRectMake(0, 0,(int)(self.view.frame.size.width),(int)(self.view.frame.size.height)))];
    
    [self.view addSubview:gameOverScreen];
    
    [self.view bringSubviewToFront:gameOverScreen];
    
    UIView *gameOverScreenBG = [[UIView alloc] initWithFrame:(CGRectMake(0, 0,(int)(self.view.frame.size.width),(int)(self.view.frame.size.height)))];
    gameOverScreenBG.backgroundColor = [UIColor greenColor];
    gameOverScreenBG.alpha = 0.2;
    [gameOverScreen addSubview:gameOverScreenBG];
    //NSLog(@"score 1 %d",self.score1);
    //NSLog(@"score 2 %d",self.score2);

    loserLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0,(int)(self.view.frame.size.width),200))];
    [loserLabel setFont:[UIFont fontWithName:@"Helvetica" size:128.0]];
    loserLabel.textAlignment = UITextAlignmentCenter;
    loserLabel.text = @"YOU LOSE!";
    loserLabel.textColor = [UIColor whiteColor];
    loserLabel.backgroundColor = [UIColor clearColor];    
    [gameOverScreen addSubview:loserLabel];
    loserLabel.transform = CGAffineTransformMakeRotation(180 * ((float)M_PI / 180.0f));  
    
    winnerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, (int)(self.view.frame.size.height)-200,(int)(self.view.frame.size.width),200))];
    [winnerLabel setFont:[UIFont fontWithName:@"Helvetica" size:128.0]];
    winnerLabel.textAlignment = UITextAlignmentCenter;
    winnerLabel.text = @"YOU WIN!";
    winnerLabel.textColor = [UIColor whiteColor];
    winnerLabel.backgroundColor = [UIColor clearColor];
    [gameOverScreen addSubview:winnerLabel];
    
    
    // replay button
    
    UIButton *replayBtn = [[UIButton alloc] initWithFrame:(CGRectMake((int)(self.view.frame.size.width)/2-100, (int)(self.view.frame.size.height)/2+100,200,100))];
    replayBtn.bounds = replayBtn.frame;
    [replayBtn setTitle:@"Replay?" forState:UIControlStateNormal];

    
    [replayBtn addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];

    
    [gameOverScreen addSubview: replayBtn];
    [gameOverScreen bringSubviewToFront:replayBtn];
    
    if(self.score1 < self.score2){
        gameOverScreen.transform = CGAffineTransformMakeRotation(180 * ((float)M_PI / 180.0f));    
    }
    self.screenGameOver = gameOverScreen;
    
}
-(void) restart{
    for (Ball * ball in balls) {
        [self cleanBall:ball];
    }
    
    [self.screenGameOver removeFromSuperview];
    scoreLabel.text = @"0 : 0";
    scoreLabel.alpha = 0.0;
    
    [self.balls removeAllObjects];
    [self.scoredBalls removeAllObjects];
    [self.boomBalls removeAllObjects];
    [self startGame];
}


@end