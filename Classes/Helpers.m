//
//  Helpers.m
//  grabbed too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright 2009 ortatherox.com. All rights reserved.
//

#import "chipmunk.h"
#import "Primitives.h"
#include <stdlib.h>
#import "Globals.h"

extern cpSpace *space;
extern cpBody *staticBody;
extern cpBody *chest;
extern cpBody *head;
extern cpBody *arm1;
extern cpBody *arm2;
extern bool removingBlood;

cpShape *chestShape;
cpShape *headShape;
cpShape *arm1Shape;
cpShape *arm2Shape;

cpBody * make_box(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
	int num = 4;
  float halfWidth = width /2;
  float halfHeight = height/2;
  
	cpVect verts[] = {
		cpv(-halfWidth,-halfHeight),
		cpv(-halfWidth, halfHeight),
		cpv( halfWidth, halfHeight),
		cpv( halfWidth,-halfHeight),
	};
	
	cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, num, verts, cpv(0,0)));
	body->p = cpv(x, y);
	cpSpaceAddBody(space, body);
	cpShape *shape = cpPolyShapeNew(body, num, verts, cpv(0,0));
	shape->e = 0.0; shape->u = 1.0;
	cpSpaceAddShape(space, shape);
	return body;
}

void make_scenery_circle(cpFloat x, cpFloat y, cpFloat radius ) {
	cpShape *shape = cpCircleShapeNew(staticBody, radius, cpv(x,y));
	shape->e = 0.1; shape->u = 1.0;
  shape -> collision_type = kColl_Scenery;
	cpSpaceAddStaticShape(space, shape);
}

void make_scenery_line(cpFloat x, cpFloat y, cpFloat x2, cpFloat y2, uint type){
  cpShape *shape;
  shape = cpSegmentShapeNew(staticBody, cpv(x,y), cpv(x2, y2), 0.0f);
	shape->e = 0.7; shape->u = 2.0;
  shape -> collision_type = type;
	cpSpaceAddStaticShape(space, shape);
}

void make_cpv_scenery_line(cpVect v1, cpVect v2){
  cpShape *shape;
  shape = cpSegmentShapeNew(staticBody, v1, v2, 0.0f);
	shape->e = 1.0; shape->u = 1.0;
  shape -> collision_type = kColl_Scenery;
	cpSpaceAddStaticShape(space, shape);
}

void make_scenery_box(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
  make_scenery_line(x , y, x + width, y , kColl_Scenery);
  make_scenery_line(x + width , y, x + width, y + height, kColl_Scenery);
  make_scenery_line(x + width, y  + height, x , y  + height, kColl_Scenery);
  make_scenery_line(x , y  + height, x , y, kColl_Scenery);
}

//lancers
void make_up_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
  int spikeCount = width/8;
  for (int i = 0; i < spikeCount; i++) {    
    make_scenery_line(x + i*8, y, x + i*8 + 4, y + height , kColl_Spikes);
    make_scenery_line(x + i*8 + 4, y + height, x + i*8 + 8, y , kColl_Spikes);
  }
}

void make_down_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
  int spikeCount = width/8;
  for (int i = 0; i < spikeCount; i++) {    
    make_scenery_line(x + i*8, y + height, x + i*8 + 4, y , kColl_Spikes);
    make_scenery_line(x + i*8 + 4, y, x + i*8 + 8, y +height, kColl_Spikes);
  }
}

void make_left_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
  int spikeCount = height/8;
  for (int i = 0; i < spikeCount; i++) {    
    make_scenery_line(x + width, y + i*8, x , y + i*8 + 4, kColl_Spikes);
    make_scenery_line(x, y + i*8 +4 , x + width, y + i*8 + 8, kColl_Spikes);
  }
}

void make_right_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
  int spikeCount = height/8;
  for (int i = 0; i < spikeCount; i++) {    
    make_scenery_line(x, y + i*8, x + width, y + i*8 + 4, kColl_Spikes);
    make_scenery_line(x + width, y + i*8 +4 , x, y + i*8 + 8, kColl_Spikes);
  }
}

void make_scenery_exit_box(cpFloat x, cpFloat y, cpFloat width, cpFloat height ) {
  make_scenery_line(x , y, x + width, y , kColl_Exit);
  make_scenery_line(x + width , y, x + width, y + height, kColl_Exit);
  make_scenery_line(x + width, y  + height, x , y  + height, kColl_Exit);
  make_scenery_line(x , y  + height, x , y, kColl_Exit);
  
}



cpBody *  createPlayer() {
  // creates all the parts of the character and returns the chest as thats
  // what the game cares for at the end of the day
  
  cpShape * shape;
	int num = 4;
  cpFloat chestMass = 15;
	cpVect verts[] = {
		cpv(-8,-12),
		cpv(-8, 12),
		cpv( 8, 12),
		cpv( 8,-12),
	};
	
	cpBody * playerChest = cpBodyNew(10.0, cpMomentForPoly(chestMass, num, verts, cpv(0,0)));
	cpSpaceAddBody(space, playerChest);
	shape = cpPolyShapeNew(playerChest, num, verts, cpv(0,0));
  shape->collision_type = kColl_Player;
	shape->e = 0.0; shape->u = 1.0;
  shape->group = kColl_Player;
  chestShape = shape;
  playerChest ->p = cpv(160,240);
	cpSpaceAddShape(space, shape);
  chest = playerChest;
	
	cpFloat radius = 10;
	cpFloat head_mass = 0.01;
  cpVect offset = cpv(0, 12);
	cpBody *playerHead = cpBodyNew(head_mass, cpMomentForCircle(head_mass, 0.0, radius, cpvzero));
	playerHead->p = cpvadd(playerChest->p, offset);
	playerHead->v = playerChest->v;
	cpSpaceAddBody(space, playerHead);
	shape = cpCircleShapeNew(playerHead, radius, cpvzero);
	shape->e = 0.0; shape->u = 2.5;
  shape->collision_type = kColl_Player;
  shape->group = kColl_Player;
  headShape = shape;
	cpSpaceAddShape(space, shape);
  // apply a small upwards force to keep the head up,
  // this may need adjusting when/if gravity is changed.
  
  // plus this adds an awesome drunkard swagger!
	cpBodyApplyForce(playerHead, cpv(0, 10), cpvzero);
  cpJoint *joint;
	joint = cpPinJointNew(playerChest, playerHead, cpv(0, 10), cpv(0, -5));
	cpSpaceAddJoint(space, joint);
  head = playerHead;
  
  cpVect armverts[] = {
		cpv(-6,-2),
		cpv(-6, 2),
		cpv( 6, 2),
		cpv( 6,-2),
	};
  
  cpBody * playerArm1 = cpBodyNew(0.1, cpMomentForPoly(0.1, num, armverts, cpv(0,0)));
  cpSpaceAddBody(space, playerArm1);
	shape = cpPolyShapeNew(playerArm1, num, armverts, cpv(0,0));
  shape->collision_type = kColl_Player;
	shape->e = 0.0; shape->u = 1.0;
  shape->group = kColl_Player;
  arm1Shape = shape;
  playerArm1 ->p = cpv(160,240);
	cpSpaceAddShape(space, shape);
  joint = cpPinJointNew(playerChest, playerArm1, cpv(5, 0), cpv(5,0));
	cpSpaceAddJoint(space, joint);
  arm1 = playerArm1;
  
  cpBody * playerArm2= cpBodyNew(0.1, cpMomentForPoly(0.1, num, armverts, cpv(0,0)));
  cpSpaceAddBody(space, playerArm2);
	shape = cpPolyShapeNew(playerArm2, num, armverts, cpv(0,0));
  shape->collision_type = kColl_Player;
	shape->e = 0.0; shape->u = 1.0;
  shape->group = kColl_Player;
  arm2Shape = shape;
  playerArm2 ->p = cpv(160,240);
	cpSpaceAddShape(space, shape);
  joint = cpPinJointNew(playerChest, playerArm2, cpv(-5, 3), cpv(-5, 3));
	cpSpaceAddJoint(space, joint);
  arm2 = playerArm2;
  
  return playerChest;
}

void turnPlayerStiff(){
  // make the shapes collide with each other
  // turns the player stiff, I found this out by accident =)
  
  chestShape-> group = 53;
  headShape -> group = 52;
  arm1Shape -> group = 50;
  arm2Shape -> group = 51;
  cpBodyResetForces(head);
}

void relaxPlayer(){
  // resets the player
  
  chestShape-> group = 50;
  headShape -> group = 50;
  arm1Shape -> group = 50;
  arm2Shape -> group = 50;
  cpBodyApplyForce(head, cpv(0, 10), cpvzero);
}

void move_player( cpVect point){
  // when these are close enough to each other
  // the joints sort out their positioning
  chest-> p = point;
  head-> p = point;
  arm1-> p =  point;
  arm2-> p =  point;
}

void bleed(){
  // randomly creates a blood circle
  
  cpFloat radius = (rand() % 2) + 1;
  cpBody *dropletBody = cpBodyNew(1, cpMomentForCircle(1, 0.0, radius, cpvzero));
	dropletBody->p = chest->p;
	cpSpaceAddBody(space, dropletBody);
	cpShape * shape = cpCircleShapeNew(dropletBody, radius, cpvzero);
	shape->e = 0.0; shape->u = 2.5;
  shape->collision_type = kColl_Blood;
	cpSpaceAddShape(space, shape);  
  float x = rand() % 40;
  float y = rand() % 40;
  x -= 20;
  y -= 20;
  cpBodyApplyImpulse(dropletBody, cpv(x, y), cpv(10,20));
}