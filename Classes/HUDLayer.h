//
//  HUDLayer.h
//  Thrown
//
//  Created by orta on 27/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Thrown_tooAppDelegate.h"
#import "Globals.h"

@class GameLayer;

@interface HUDLayer : Layer {
  
  GameLayer *game;
  CGSize wins;
  Sprite * fireButton;
  CGRect fireButtonRect;
  Sprite * nextButton;
  CGRect nextButtonRect;
  Label * throwLabel;
  int currentPercentage;
  

}
@property (nonatomic, retain) GameLayer *game;
@property (nonatomic, retain) Sprite *fireButton;


- (void) hideHUD;

- (void) setThrowLabel:(NSString * ) value;
- (void) showThrowLabel;
- (void) hideThrowLabel;

- (void) showNextButton;
- (void) hideNextButton;

- (void) showFireButton;
- (void) hideFireButton;

- (void) setLevelComplete: (int) value;

@end
