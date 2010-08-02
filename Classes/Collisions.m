//
//  Collisions.m
//  Thrown
//
//  Created by orta on 24/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "chipmunk.h"
#import "Globals.h"
#import "HUDLayer.h"

extern int gameMode;
extern uint exitCount;
extern void turnPlayerStiff();
extern void * hudLayer;
int reachedExit(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  if(gameMode == kGame_Fired){
    exitCount++;
    [(HUDLayer*) hudLayer setLevelComplete:exitCount];
  }
  return 1;
}

int playerSpiked(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  gameMode = kGame_Spiked;
  turnPlayerStiff();
  return 0;
}

int returnZero(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  return 0;
}
