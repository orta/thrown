//
//  XMLLevelLoader.m
//  Thrown
//
//  Created by orta on 23/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XMLLevelLoader.h"
#import "chipmunk.h"
#import "Globals.h"

extern void make_scenery_line(cpFloat x, cpFloat y, cpFloat x2, cpFloat y2, uint type);
extern void make_cpv_scenery_line(cpVect v1, cpVect v2);
extern void make_scenery_box(cpFloat x, cpFloat y, cpFloat width, cpFloat height );
extern void make_scenery_circle(cpFloat x, cpFloat y, cpFloat radius );
extern void move_player( cpVect point);
extern void make_up_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height );
extern void make_down_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height );
extern void make_right_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height );
extern void make_left_scenery_spikes(cpFloat x, cpFloat y, cpFloat width, cpFloat height );
extern void make_scenery_exit_box(cpFloat x, cpFloat y, cpFloat width, cpFloat height );

extern float player_origin_y;
extern float player_origin_x;
extern int numberOfThrows;
extern int totalNumberOfThrows;
extern cpVect mapSize;

@class GameLayer;


@implementation XMLLevelLoader

-(void) setGame: (GameLayer *) newGame{
  game = newGame;
}

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error {	
  NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
  // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
  [parser setDelegate:self];

  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
  
  [parser parse];
  
  NSError *parseError = [parser parserError];
  if (parseError && error) {
    *error = parseError;
  }
  
  [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if (qName) {
    elementName = qName;
  }
//  NSLog(@"element = %@ , attr = %@", elementName, attributeDict);
  
  if ([elementName isEqualToString:@"line"]) {
    float x1 = [[attributeDict valueForKey:@"x1"] floatValue];
    float y1 = [[attributeDict valueForKey:@"y1"] floatValue];
    float x2 = [[attributeDict valueForKey:@"x2"] floatValue];
    float y2 = [[attributeDict valueForKey:@"y2"] floatValue];
    make_scenery_line(x1, y1, x2, y2, kColl_Scenery);
    
  }else if([elementName isEqualToString:@"circle"]) {
    float x = [[attributeDict valueForKey:@"x"] floatValue];
    float y = [[attributeDict valueForKey:@"y"] floatValue];
    float radius = [[attributeDict valueForKey:@"radius"] floatValue];
    make_scenery_circle(x, y, radius);

  }else if([elementName isEqualToString:@"background"]) {
    NSString * url = [attributeDict valueForKey:@"url"];
    if(url != nil){
      //  [game setPsuedoBackground:[NSURL URLWithString:url]];  
    }
    NSString * fileURL = [attributeDict valueForKey:@"file"];
    if(fileURL != nil){
      //TODO
    //  NSBundle*	bundle = [NSBundle mainBundle];
      // [game setPsuedoBackground: [NSURL fileURLWithPath: [bundle pathForResource:fileURL ofType:@"png"]]];  
    }
  
  }else if ([elementName isEqualToString:@"spikes"]) {
    float x = [[attributeDict valueForKey:@"x"] floatValue];
    float y = [[attributeDict valueForKey:@"y"] floatValue];
    float width = [[attributeDict valueForKey:@"width"] floatValue];
    float height = [[attributeDict valueForKey:@"height"] floatValue];
    NSString * type = [attributeDict valueForKey:@"direction"];
    if([type compare:@"up"] == NSOrderedSame){
      make_up_scenery_spikes(x, y, width, height);
    }else if([type compare:@"down"] == NSOrderedSame){
      make_down_scenery_spikes(x, y, width, height);
    }else if([type compare:@"left"] == NSOrderedSame){
      make_left_scenery_spikes(x, y, width, height);
    }else if([type compare:@"right"] == NSOrderedSame){
      make_right_scenery_spikes(x, y, width, height);
    }
    
  }else if([elementName isEqualToString:@"next"]) {
    NSString *level = [attributeDict valueForKey:@"level"];
    // TODO
    [game setNextLevel: level];
    
  }else if([elementName isEqualToString:@"size"]) {
    float width = [[attributeDict valueForKey:@"width"] floatValue];
    float height = [[attributeDict valueForKey:@"height"] floatValue];
    mapSize = cpv(width, height);
    make_scenery_box(0, 0, width, height);
    
  }else if([elementName isEqualToString:@"thrown"]) {
    numberOfThrows = [[attributeDict valueForKey:@"throws"] floatValue];
    totalNumberOfThrows = [[attributeDict valueForKey:@"throws"] floatValue];

  }else if([elementName isEqualToString:@"player"]) {
    float x = [[attributeDict valueForKey:@"x"] floatValue];
    float y = [[attributeDict valueForKey:@"y"] floatValue];
    move_player(cpv(x, y));
    player_origin_x = x;
    player_origin_y = y;    
    
  }else if ([elementName isEqualToString:@"exit"]) {
    float x = [[attributeDict valueForKey:@"x"] floatValue];
    float y = [[attributeDict valueForKey:@"y"] floatValue];
    float width = [[attributeDict valueForKey:@"width"] floatValue];
    float height = [[attributeDict valueForKey:@"height"] floatValue];
    make_scenery_exit_box(x, y, width, height);
  }
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
  NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}

@end
