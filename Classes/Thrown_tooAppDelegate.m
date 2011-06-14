//
//  Thrown_tooAppDelegate.m
//  Thrown too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright ortatherox.com 2009. All rights reserved.
//

#import "Thrown_tooAppDelegate.h"
#import "Globals.h"
#import "OpenGL_Internal.h"
#import <AudioToolbox/AudioServices.h>

#define DEBUG_MODE 1
#define MAP_DEACCEL 0.85
#define MAP_BORDER 80

//References to debug rendering methods
extern void drawCircleShape(cpShape *shape);
extern void drawSegmentShape(cpShape *shape);
extern void drawPolyShape(cpShape *shape);
extern void drawObject(void *ptr, void *unused);
// Helpers
extern void make_scenery_line(cpFloat x, cpFloat y, cpFloat x2, cpFloat y2, uint type);
extern void make_cpv_scenery_line(cpVect v1, cpVect v2);
extern void make_scenery_box(cpFloat x, cpFloat y, cpFloat width, cpFloat height );


extern cpBody * createPlayer() ;
extern void move_player(cpVect point);
extern void relaxPlayer();
extern void bleed();

extern int reachedExit(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);
extern int playerSpiked(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);
extern int returnZero(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);

int numberOfThrows = 1;
int totalNumberOfThrows = 1;

// obj-c classes
void * gameLayer;
void * hudLayer; 

int gameMode;
cpSpace *space;
cpBody *staticBody;

cpBody *head;
cpBody *arm1;
cpBody *arm2;
cpBody *chest;

cpVect mapScrollVelocity;
cpVect mapSize;

cpVect oldScrollingPosition;
cpVect oldFinger1Position;
cpVect oldFinger2Position;


float player_origin_x = 0;
float player_origin_y = 0;
//SystemSoundID kSound_Puck = 1024;

uint exitCount = 0;

//main cocos2d rendering loop, this has to be streamlined
// e.g dont add logs here :/
static void eachShape(void *ptr, void* unused){
	cpShape *shape = (cpShape*) ptr;
	Sprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		[sprite setPosition: cpv( body->p.x, body->p.y)];
		[sprite setRotation: RADIANS_TO_DEGREES( -body->a )];
	}
}



@implementation GameLayer

@synthesize nextLevel;
@synthesize hud;
@synthesize currentLevelURL;

-(id) init
{
	[super init];

	isTouchEnabled = YES;
	isAccelerometerEnabled = YES;
	gameLayer = self;
  gameMode = kGame_Rest;
  firstRun = true;
  CGSize wins = [[Director sharedDirector] winSize];
  ignoreInputRect = CGRectMake(0, wins.height -90 , wins.width, 90);
  
  srand([[NSDate date] timeIntervalSince1970]);
  
	cpInitChipmunk();	
  
  NSBundle*	bundle = [NSBundle mainBundle];
  [self loadLevelAtURL:[NSURL fileURLWithPath: [bundle pathForResource:@"level7" ofType:@"xml"]]];
  [self schedule: @selector(step:)];
  return self;
}

-(void) playerStationaryCheck: (ccTime) delta {
  static cpVect oldChestP;
  static int finishCount = 0;
  cpVect diff = cpvsub(oldChestP, chest->p);
  if(abs(diff.x) <= 2.5){
    if(abs(diff.y) <= 2.5){
      finishCount++;
      if(finishCount==5){
        if(exitCount > 500){
          [hud showNextButton];
          gameMode = kGame_Rest;
        }
        relaxPlayer();
        exitCount = 0;
        numberOfThrows--;
        gameMode = kGame_Rest;
        finishCount = 0;
        [self unschedule:@selector(playerStationaryCheck:)];            
        lives--;
        
        if(numberOfThrows == 0){   
          if(lives == 0){
            [self reloadLevel];
            return;
          }
          numberOfThrows = totalNumberOfThrows;
          move_player(cpv(player_origin_x, player_origin_y));
          cpBodySetAngle(player, 0);
          gameMode = kGame_Rest;
          
        }else{
          NSString * throws = [NSString stringWithFormat:@"%i throws", numberOfThrows];
          if(numberOfThrows == 1) throws = [NSString stringWithFormat:@"1 throw"];
          [hud setThrowLabel:throws];            
        }
      }
    }
  }
  oldChestP = chest->p;
}

- (void) reloadLevel {
  [self loadLevelAtURL:currentLevelURL];
}

-(void) loadLevelAtURL:(NSURL*) url {
  //create a new world.
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [self setCurrentLevelURL:url];
  if(firstRun == false){
    // kill old chipmunk objects
    cpSpaceFreeChildren(space);
    cpSpaceFree(space);
    cpBodyFree(staticBody);
  }
  
  firstRun = false;
  exitCount = 0;
  lives = 1;
  
  space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, 20.0, 999);
	space->gravity = cpv(0, -200);
  
  staticBody = cpBodyNew(INFINITY, INFINITY);  
  
  player =  createPlayer();
  cpBodySetMass(player, 0.3);
  
  
  levelLoader = [[XMLLevelLoader alloc] init];
  [levelLoader retain];
  [levelLoader setGame:self];
	NSError *parseError = nil;
  [levelLoader parseXMLFileAtURL:url parseError:&parseError];
  
  NSString * throws = [NSString stringWithFormat:@"%i throws", numberOfThrows];
  if(numberOfThrows == 1) throws = [NSString stringWithFormat:@"1 throw"];
  [hud setThrowLabel:throws];
  
  [levelLoader release];        
  [pool release];
  
  // This happened twice so it's worth noting, collision_type is for these functions
  //  and group is for avoiding collisions grah!
  cpSpaceAddCollisionPairFunc(space, kColl_Player, kColl_Exit, &reachedExit, nil);
  cpSpaceAddCollisionPairFunc(space, kColl_Player, kColl_Spikes, &playerSpiked, nil);
  cpSpaceAddCollisionPairFunc(space, kColl_Player, kColl_Blood, &returnZero, nil);  
  
  gameMode = kGame_Rest;
  [self setPosition:cpv(0,0)];
  
}

-(void) draw {
  
  if(mapScrollVelocity.x > 0.5 || mapScrollVelocity.x < -0.5 ){
    cpVect newPos = [self position];
    newPos.x += mapScrollVelocity.x;
    mapScrollVelocity.x *= MAP_DEACCEL;
    if(newPos.x < -MAP_BORDER ){
      newPos.x = -MAP_BORDER;
    }
    if(newPos.x > (mapSize.x - 480) + MAP_BORDER){
      newPos.x = (mapSize.x - 480) + MAP_BORDER;
    }
    [self setPosition:newPos];
  }
  
  if(mapScrollVelocity.y > 0.5 || mapScrollVelocity.y < -0.5 ){
    cpVect newPos = [self position];
    newPos.y += mapScrollVelocity.y;
    mapScrollVelocity.y *= MAP_DEACCEL;
    if(newPos.y < -MAP_BORDER ){
      newPos.y = -MAP_BORDER;
    }
    if(newPos.y > (mapSize.y - 320) + MAP_BORDER){
      newPos.y = (mapSize.y - 320) + MAP_BORDER;
    }
    [self setPosition:newPos];
    
  }
  
#ifdef DEBUG_MODE
  glColor4f(1.0, 1.0, 1.0, 1.0);
  cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
  glColor4f(1.0, 1.0, 1.0, 0.7);
  cpSpaceHashEach(space->staticShapes, &drawObject, NULL);
  if(gameMode == kGame_Aiming){
    glColor4f(0.8, 1.0, 0.76, 1.0);  
    glLineWidth(2.0f);
    drawLine( player->p.x, player->p.y, arrowPoint.x, arrowPoint.y );
    
    //  TODO: Figure out why this doesnt work properly
    //    cpFloat angle =  RADIANS_TO_DEGREES( cpvtoangle( cpvsub( arrowPoint, player->p)));
    //    cpVect arrowSide1 =  cpvmult( cpvforangle( DEGREES_TO_RADIANS(angle + 60) ), 30);
    //    cpVect arrowSide2 =  cpvmult( cpvforangle( DEGREES_TO_RADIANS(angle - 60) ), 30);
    //
    //    drawLine( arrowPoint.x, arrowPoint.y,arrowPoint.x + arrowSide1.x,arrowPoint.y + arrowSide1.y );
    //    drawLine( arrowPoint.x, arrowPoint.y,arrowPoint.x + arrowSide2.x,arrowPoint.y + arrowSide2.y );
    
    glLineWidth(1.0f);
    glColor4f(1.0, 1.0, 1.0, 0.7);
    
  }
#endif
}  


-(void) step: (ccTime) delta {
	int steps = 2;
	cpFloat dt = delta/(cpFloat)steps;
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
  
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
  if(gameMode == kGame_Spiked){
    if((rand() % 3) == 1){
      bleed();
    }
  }
} 

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
  
  UITouch *myTouch = [touches anyObject];
  CGPoint location = [myTouch locationInView: [myTouch view]];
  if([touches count] ==2){
    //these are inverted!!
    cpVect screenRelativeTouchPosition = cpv(location.y, location.x);
    cpVect newPos = cpvsub( oldScrollingPosition, screenRelativeTouchPosition );
    oldScrollingPosition = screenRelativeTouchPosition;
    // inverse to make it feel like your sliding it around
    newPos.x *= -1;
    newPos.y *= -1;
    
    mapScrollVelocity = newPos;
  }
  
  for (myTouch in touches) {   
    location = [[Director sharedDirector] convertCoordinate: location];
    if(CGRectContainsPoint(ignoreInputRect, location)){
      break;
    }
    // into game coords...
    if([touches count] == 1){
      
      if(gameMode == kGame_Aiming){
        arrowPoint = cpv (location.x, location.y);
      }   
    }
  }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *myTouch in touches) { 
    CGPoint location = [myTouch locationInView: [myTouch view]];
    oldScrollingPosition =  cpv(location.y, location.x);
    location = [[Director sharedDirector] convertCoordinate: location];
    if(CGRectContainsPoint(ignoreInputRect, location)){
      break;
    }
    
    if(gameMode == kGame_Rest){ // take us into aiming
      gameMode = kGame_Aiming;
      arrowPoint = cpv (location.x, location.y);
      [hud showFireButton];
    }
    if(gameMode == kGame_Aiming){
      arrowPoint = cpv (location.x, location.y);
    }      
  }  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void) gotoNextLevel{
  NSBundle*	bundle = [NSBundle mainBundle];
  [self loadLevelAtURL:[NSURL fileURLWithPath: [bundle pathForResource:nextLevel ofType:@"xml"]]];
}

-(void) fire{
  gameMode = kGame_Fired;
  //rotate body to be the direction fired
  cpFloat movementPadding = 0.7;
  [hud hideHUD];
  cpBodySetAngle(player, RADIANS_TO_DEGREES(cpvtoangle(cpvsub( arrowPoint, player->p)) + 90 ) );
  cpBodyApplyImpulse(player, cpvmult(cpvsub( arrowPoint, player->p), movementPadding), cpvzero);
  [self schedule: @selector(playerStationaryCheck:) interval: 1];
}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration{	
  static float prevX=0, prevY=0;	
#define kFilterFactor 0.05
  
  float accelX = acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
  float accelY = acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
  
  prevX = accelX;
  prevY = accelY;
  
  cpVect v = cpv( accelX, accelY);
  
  v = cpvrotate(v, cpv(0,1));
  [[hud fireButton] setRotation: RADIANS_TO_DEGREES( cpvtoangle(v)) + 180];
  // 	space->gravity = cpvmult(v, 200);
}

-(void)setPsuedoBackground: (NSURL *) url{
  NSLog(@"TODO... maybe");  
}

-(void) dealloc
{
	[super dealloc];
}
@end

@implementation Thrown_tooAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// NEW: Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	//[window setMultipleTouchEnabled:YES];

	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] attachInWindow:window];
  
  
	Scene *scene = [Scene node];
  
  //  these numbers are magick?!
  [scene setPosition:cpv(-542, 2)];
  HUDLayer *hud = [HUDLayer node];  
  GameLayer *game = [GameLayer node];
  [game setHud:hud];
  [hud setGame:game];
  
  // add both hud and game, making the hud always show above the game
  [scene add: hud z:1];
  [scene add: game z:0];
	
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   
	[window makeKeyAndVisible];
	
	[[Director sharedDirector] runWithScene: scene];

}
-(void)dealloc
{
	[super dealloc];
}
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

@end
