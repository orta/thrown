//
//  Thrown_tooAppDelegate.h
//  Thrown too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright ortatherox.com 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "XMLLevelLoader.h"
#import "cocos2d.h"
#import "chipmunk.h"
#import "HUDLayer.h"


@class HUDLayer;

@interface GameLayer : Layer {
  XMLLevelLoader *levelLoader;
  HUDLayer * hud;
  UIScrollView * myScrollView;
  
  cpBody * player;
  cpVect arrowPoint;
  
  bool showArrow;
  bool firstRun;
  int lives;
  CGRect ignoreInputRect;
  NSString *nextLevel;
  NSURL *currentLevelURL;
}

@property (nonatomic, retain) NSString *nextLevel;
@property (nonatomic, retain) HUDLayer *hud;
@property (nonatomic, retain) NSURL* currentLevelURL;

-(void) gotoNextLevel;
-(void) reloadLevel;
-(void) playerStationaryCheck: (ccTime) delta;
-(void) step: (ccTime) dt;
-(void) loadLevelAtURL:(NSURL*) url;
-(void) fire;
@end


@interface Thrown_tooAppDelegate : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate> {
	UIWindow *window;
}
@end

