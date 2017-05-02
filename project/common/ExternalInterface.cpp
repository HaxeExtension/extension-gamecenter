#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include <stdio.h>
#include <hxcpp.h>
#include "GameCenter.h"


using namespace gamecenter;


AutoGCRoot* gameCenterEventHandle = 0;


static value gamecenter_set_event_handle(value onEvent)
{
	#if defined(IPHONE) || defined(HX_MACOS)
	gameCenterEventHandle = new AutoGCRoot(onEvent);
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_set_event_handle, 1);


static value gamecenter_initialize() 
{
	#if defined(IPHONE) || defined(HX_MACOS)
	initializeGameCenter();
	#endif
	return alloc_null();
}
DEFINE_PRIM (gamecenter_initialize, 0);


static value gamecenter_authenticate() 
{
	#if defined(IPHONE) || defined(HX_MACOS)
	authenticateLocalUser();
	#endif
	return alloc_null();
}
DEFINE_PRIM (gamecenter_authenticate, 0);


static value gamecenter_isavailable()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	return alloc_bool(isGameCenterAvailable());
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM(gamecenter_isavailable, 0);


static value gamecenter_isauthenticated()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	return alloc_bool(isUserAuthenticated());
	#else
	return alloc_bool(false);
	#endif
}
DEFINE_PRIM(gamecenter_isauthenticated, 0);


static value gamecenter_playername()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	return alloc_string(getPlayerName());
	#else
	return alloc_null();
	#endif
}
DEFINE_PRIM(gamecenter_playername, 0);


static value gamecenter_playerid()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	return alloc_string(getPlayerID());
	#else
	return alloc_null();
	#endif
}
DEFINE_PRIM(gamecenter_playerid, 0);

static value gamecenter_playerfriends()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	getPlayerFriends();
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_playerfriends, 0);

static value gamecenter_playerphoto(value playerID)
{
	#if defined(IPHONE) || defined(HX_MACOS)
	getPhoto(val_string(playerID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_playerphoto, 1);


static value gamecenter_showachievements()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	showAchievements();
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_showachievements, 0);


static value gamecenter_showleaderboard(value categoryID)
{
	#if defined(IPHONE) || defined(HX_MACOS)
	showLeaderboard(val_string(categoryID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_showleaderboard, 1);


static value gamecenter_reportscore(value categoryID, value score)
{
	#if defined(IPHONE) || defined(HX_MACOS)
	reportScore(val_string(categoryID), val_int(score));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_reportscore, 2);


static value gamecenter_reportachievement(value achievementID, value percent, value showCompletionBanner)
{
	#if defined(IPHONE) || defined(HX_MACOS)
	reportAchievement(val_string(achievementID),val_float(percent),val_bool(showCompletionBanner));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_reportachievement, 3);


static value gamecenter_resetachievements()
{
	#if defined(IPHONE) || defined(HX_MACOS)
	resetAchievements();
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_resetachievements, 0);


static value gamecenter_getAchievementProgress(value achievementID)
{
	#if defined(IPHONE) || defined(HX_MACOS)
		getAchievementProgress(val_string(achievementID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_getAchievementProgress, 1);


static value gamecenter_getAchievementStatus(value achievementID)
{
	#if defined(IPHONE) || defined(HX_MACOS)
		getAchievementStatus(val_string(achievementID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_getAchievementStatus, 1);


static value gamecenter_getPlayerScore(value leaderboardID)
{
	#if defined(IPHONE) || defined(HX_MACOS)
		getPlayerScore(val_string(leaderboardID));
	#endif
	return alloc_null();
}
DEFINE_PRIM(gamecenter_getPlayerScore, 1);


extern "C" void gamecenter_main() 
{	
	val_int(0); // Fix Neko init
}
DEFINE_ENTRY_POINT(gamecenter_main);



extern "C" int gamecenter_register_prims() { return 0; }



extern "C" void sendGameCenterEvent(const char* type, const char* data1, const char* data2, const char* data3, const char* data4)
{
    //printf("Send Event: %s\n", type);
    value o = alloc_empty_object();
    alloc_field(o,val_id("type"),alloc_string(type));
    alloc_field(o,val_id("data1"),alloc_string(data1));
    alloc_field(o,val_id("data2"),alloc_string(data2));
    alloc_field(o,val_id("data3"),alloc_string(data3));
    alloc_field(o,val_id("data4"),alloc_string(data4));
    val_call1(gameCenterEventHandle->get(), o);
}
