//
//  HUDLayer.m
//  Thrown
//
//  Created by orta on 27/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

extern int numberOfThrows;
extern int gameMode;
extern void * hudLayer; 

@implementation HUDLayer

@synthesize game, fireButton;


-(id) init {
	[super init];
	isTouchEnabled = YES;
  hudLayer = self;
  wins = [[Director sharedDirector] winSize];

  fireButton = [Sprite spriteWithFile:@"go.png"];
  [fireButton setPosition:cpv(900, 900)];
  [self add:fireButton];
  
  nextButton = [Sprite spriteWithFile:@"nextlevel.png"];
  [nextButton setPosition:cpv(900, 900)];
  [self add:nextButton];
  
  resetButton = [Sprite spriteWithFile:@"refresh.png"];
  [resetButton setPosition:cpv( 30, wins.height - 30)];   
  resetButtonRect = CGRectMake( 30, wins.height - 30, 60, 60);
  [self add:resetButton];
  
  throwLabel = [Label labelWithString:@"Throws: 1" dimensions:CGSizeMake(180,40) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:24];
  [throwLabel setRGB:255 :255 :255];
  [self showThrowLabel];
  [self add:throwLabel];
  
  
  return self;
}

- (void) hideHUD{
  [fireButton setPosition:cpv(999,999)];
  fireButtonRect = CGRectMake(0, 0, 0, 0);
  [throwLabel setPosition:cpv(999,999)];
  [nextButton setPosition:cpv(999,999)];
  nextButtonRect = CGRectMake(0, 0, 0, 0);
}

- (void) setLevelComplete: (int) value{
  if(value > 500) value = 500;
  int percentage = value/45;
  // we crack it up to 11 baby.
  if(percentage == currentPercentage){
    return;
  }
  // 0,0 is bottom right
  // 320,0 is bottom left
  drawLine(20, 461, 20, 359);
  drawLine(20, 359, 40, 359);
  drawLine(40, 461, 40, 359);
  drawLine(20, 461, 40, 461);
  
  if(percentage == 11){
    #define thumb_width 25
    #define thumb_height 30
    #define thumb_xoffset 320
    #define thumb_yoffset 20
        
    //  y x, y2 x2 (after rotation)
    drawLine(thumb_yoffset, thumb_xoffset, thumb_yoffset, thumb_xoffset+thumb_width);
    drawLine(thumb_yoffset+thumb_height, thumb_xoffset+thumb_width, thumb_yoffset, thumb_xoffset+thumb_width);
    drawLine(thumb_yoffset+thumb_height, thumb_xoffset + 15, thumb_yoffset+thumb_height, thumb_xoffset+thumb_width);
    drawLine(thumb_yoffset+thumb_height, thumb_xoffset + 15, thumb_yoffset+thumb_height- 10, thumb_xoffset + 15);
    drawLine(thumb_yoffset+thumb_height- 10, thumb_xoffset + 15, thumb_yoffset+thumb_height- 10, thumb_xoffset);
    drawLine(thumb_yoffset+thumb_height- 10, thumb_xoffset, thumb_yoffset, thumb_xoffset);
    // finger gaps
    drawLine(thumb_yoffset+13, thumb_xoffset, thumb_yoffset+13, thumb_xoffset+8);
    drawLine(thumb_yoffset+9, thumb_xoffset, thumb_yoffset+9, thumb_xoffset+8);
    drawLine(thumb_yoffset+5, thumb_xoffset, thumb_yoffset+5, thumb_xoffset+8);
    percentage = 10;
  }
  
  
  for (int i = 0; i < percentage; i++) {
    int xoff =  451 - i*10;
    int width = 8;
    drawLine(22, xoff, 22, xoff+width);
    drawLine(38, xoff+width, 22, xoff+width);
    drawLine(38, xoff+width, 38, xoff);
    drawLine(38, xoff, 22, xoff);
  }
}

- (void) setThrowLabel:(NSString * ) value{
  [throwLabel setString:value];  
  [self showThrowLabel];
}

- (void) showThrowLabel{
  [throwLabel setPosition:cpv(60, 300)];
}

- (void) hideThrowLabel{
  [throwLabel setPosition:cpv(-60, 300)]; 
}

- (void) showFireButton{
  [fireButton setPosition:cpv(wins.width -30, wins.height-30)];   
  fireButtonRect = CGRectMake(wins.width -60, wins.height-60, 60, 60);
}

- (void) hideFireButton{
  [fireButton setPosition:cpv(wins.width +100, wins.height+100)];   
  fireButtonRect = CGRectMake(0,0, 0, 0);
}

- (void) showNextButton{
  [nextButton setPosition:cpv(wins.width -130, wins.height-30)];   
  nextButtonRect = CGRectMake(wins.width -180, wins.height-60, 60, 60);
}

- (void) hideNextButton{
  [nextButton setPosition:cpv(wins.width +90, wins.height+30)];   
  nextButtonRect = CGRectMake(0,0, 0, 0);
}

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
  
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *myTouch in touches) { 
    CGPoint location = [myTouch locationInView: [myTouch view]];
    location = [[Director sharedDirector] convertCoordinate: location];
    if(CGRectContainsPoint(resetButtonRect, location)){
      [game reloadLevel];
    }
    if(gameMode == kGame_Aiming || gameMode == kGame_Rest){
      if(CGRectContainsPoint(fireButtonRect, location)){
        [game fire];  
        return;
      }
      if(CGRectContainsPoint(nextButtonRect, location)){
        [game gotoNextLevel]; 
        return;
      }
    }    
  }  
}

@end
