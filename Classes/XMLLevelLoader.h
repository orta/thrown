//
//  XMLLevelLoader.h
//  Thrown
//
//  Created by orta on 23/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class GameLayer;

@interface XMLLevelLoader : NSObject {
  GameLayer * game;
}
- (void) parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error ;
- (void) setGame: (GameLayer *)game;
@end
