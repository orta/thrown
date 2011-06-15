//
//  GameLayer.h
//  Thrown too
//
//  Created by orta therox on 14/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMLLevelLoader.h"
#import "cocos2d.h"
#import "chipmunk.h"
#import "HUDLayer.h"

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
