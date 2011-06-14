//
//  DebugRenderer.m
//  grabbed too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright 2009 ortatherox.com. All rights reserved.
//

#import "chipmunk.h"
#import "Primitives.h"
#import "cocos2d.h"
#import "OpenGL_Internal.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "Globals.h"

void drawCircleShape(cpShape *shape) {
	cpBody *body = shape->body;
  
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	drawCircle(c.x, c.y, circle->r, body->a, 25); // !important this number changes the quality of circles
}

void drawSegmentShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	drawLine( a.x, a.y, b.x, b.y );
}

void drawPolyShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	float *vertices = malloc( sizeof(float)*2*poly->numVerts);
	if(!vertices)
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i*2] = v.x;
		vertices[i*2+1] = v.y;
	}
	drawPoly( vertices, poly->numVerts );
	free(vertices);
}

void drawObject(void *ptr, void *unused) {
	cpShape *shape = (cpShape *)ptr;
  switch (shape->collision_type) {
    case kColl_Spikes:
      glColor4f(1.0, 0.2, 0.3, 0.8);
      break;
    case kColl_Blood:
      glColor4f(0.7, 0.1, 0.1, 0.6);
      break;            
    case kColl_Player:
      glColor4f(1.0, 1.0, 1.0, 1.0);
      break;      
    case kColl_Exit:
      glColor4f(0.2, 0.6, 0.4, 1.0);
      break;
    case kColl_Slippy:
      glColor4f(0.5, 0.5, 0.9, 1.0);
      break;
    default:
      glColor4f(1.0, 1.0, 1.0, 0.7);
      break;
  }
  
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE:
			drawCircleShape(shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}
