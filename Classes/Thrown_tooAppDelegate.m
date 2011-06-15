//
//  Thrown_tooAppDelegate.m
//  Thrown too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright ortatherox.com 2009. All rights reserved.
//

#import "Thrown_tooAppDelegate.h"
#import "cocos2d.h"
#import "Globals.h"
#import "OpenGL_Internal.h"
#import <AudioToolbox/AudioServices.h>
#import "HUDLayer.h"
#import "GameLayer.h"

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
