/*
 *  Globals.h
 *  Thrown
 *
 *  Created by orta on 06/09/2008.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

//collision types
enum CollisionTypes {
  kColl_Scenery,
  kColl_Player,
  kColl_Exit,
  kColl_Spikes,
  kColl_Blood,
  kColl_Slippy,
  kColl_Count
};


//gameplay modes
enum {
  kGame_Rest,
  kGame_Aiming,
  kGame_Firing,
  kGame_Fired,
  kGame_Spiked
};
