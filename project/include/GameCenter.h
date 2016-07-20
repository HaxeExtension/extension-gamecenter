#ifndef GAME_CENTER_H
#define GAME_CENTER_H

namespace gamecenter 
{	
    //User
	void initializeGameCenter();
    bool isGameCenterAvailable();
	bool isUserAuthenticated();
    void authenticateLocalUser();
    
    const char* getPlayerName();
    const char* getPlayerID();
    void getPlayerFriends();
    void getPhoto(const char* playerID);
    
    //Leaderboards
    void showLeaderboard(const char* categoryID);
    void reportScore(const char* categoryID, int score);
    void getPlayerScore(const char* leaderboardID);
    
    //Achievements
    void showAchievements();
    void resetAchievements();
    void reportAchievement(const char* achievementID, float percent, bool showCompletionBanner);
    void getAchievementProgress(const char* achievementID);
    void getAchievementStatus(const char* achievementID);

    //Other
    void registerForAuthenticationNotification();
}


#endif
