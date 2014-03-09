#include <GameCenter.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GameKit/GameKit.h>

extern "C" void sendGameCenterEvent(const char* event, const char* data);

typedef void (*FunctionType)();

@interface GKViewDelegate : NSObject <GKAchievementViewControllerDelegate,GKLeaderboardViewControllerDelegate>
{
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController;

@property (nonatomic) FunctionType onAchievementFinished;
@property (nonatomic) FunctionType onLeaderboardFinished;

@end

@implementation GKViewDelegate

@synthesize onAchievementFinished;
@synthesize onLeaderboardFinished;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

UIViewController *glView2;

- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
    [viewController dismissModalViewControllerAnimated:YES];
    [viewController.view.superview removeFromSuperview];
    [viewController release];
    onAchievementFinished();
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
    [viewController dismissModalViewControllerAnimated:YES];
    [viewController.view.superview removeFromSuperview];
    [viewController release];
    onLeaderboardFinished();
}

@end



namespace gamecenter
{
    static int isInitialized = 0;
    GKViewDelegate* viewDelegate;

    static const char* AUTH_SUCCESS = "authSuccess";
    static const char* AUTH_FAILURE = "authFailure";
    static const char* SCORE_SUCCESS = "scoreSuccess";
    static const char* SCORE_FAILURE = "scoreFailure";
    static const char* ACHIEVEMENT_SUCCESS = "achievementSuccess";
    static const char* ACHIEVEMENT_FAILURE = "achievementFailure";
    static const char* ACHIEVEMENT_RESET_SUCCESS = "achievementResetSuccess";
    static const char* ACHIEVEMENT_RESET_FAILURE = "achievementResetFailure";

    //---

    //User
    void initializeGameCenter();
    bool isGameCenterAvailable();
    bool isUserAuthenticated();
    void authenticateLocalUser();

    const char* getPlayerName();
    const char* getPlayerID();

    //Leaderboards
    void showLeaderboard(const char* categoryID);
    void reportScore(const char* categoryID, int score);

    //Achievements
    void showAchievements();
    void resetAchievements();
    void reportAchievement(const char* achievementID, float percent);

    //Callbacks
    void registerForAuthenticationNotification();
    static void authenticationChanged(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo);

    void achievementViewDismissed();
    void leaderboardViewDismissed();

    //---

    //USER

    void initializeGameCenter()
    {
        if(isInitialized == 1)
        {
            return;
        }

        if(isGameCenterAvailable())
        {
            viewDelegate = [[GKViewDelegate alloc] init];
            viewDelegate.onAchievementFinished = &achievementViewDismissed;
            viewDelegate.onLeaderboardFinished = &leaderboardViewDismissed;

            isInitialized = 1;
            authenticateLocalUser();
        }
    }

    bool isGameCenterAvailable()
    {
        Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
        NSString* reqSysVer = @"4.1";
        NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
        BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);

        return (gcClass && osVersionSupported);
    }

    bool isUserAuthenticated()
    {
        return ([GKLocalPlayer localPlayer].isAuthenticated);
    }

    void authenticateLocalUser()
    {
        if(!isGameCenterAvailable())
        {
            return;
        }

        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
        {
            if(error == nil)
            {
                registerForAuthenticationNotification();
                sendGameCenterEvent(AUTH_SUCCESS, "");
            }

            else
            {
                NSString* errorDescription = [error localizedDescription];
                sendGameCenterEvent(AUTH_FAILURE, [errorDescription UTF8String]);
                [errorDescription release];
            }
        }];
    }

    const char* getPlayerName()
    {
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];

        if(localPlayer.isAuthenticated)
        {
            return [localPlayer.alias cStringUsingEncoding:NSUTF8StringEncoding];
        }

        else
        {
            return "";
        }
    }

    const char* getPlayerID()
    {
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];

        if(localPlayer.isAuthenticated)
        {
            return [localPlayer.playerID cStringUsingEncoding:NSUTF8StringEncoding];
        }

        else
        {
            return "";
        }
    }

    //LEADERBOARDS

    void showLeaderboard(const char* categoryID)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        NSString* strCategory = [[NSString alloc] initWithUTF8String:categoryID];

        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];

        if(leaderboardController != nil)
        {
            leaderboardController.category = strCategory;
            leaderboardController.leaderboardDelegate = viewDelegate;
            UIViewController *glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [glView2 presentModalViewController:leaderboardController animated: NO];
        }

        [strCategory release];
        [pool drain];
    }

    void reportScore(const char* categoryID, int score)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        NSString* strCategory = [[NSString alloc] initWithUTF8String:categoryID];
        GKScore* scoreReporter = [[[GKScore alloc] initWithCategory:strCategory] autorelease];

        if(scoreReporter)
        {
            scoreReporter.value = score;

            [scoreReporter reportScoreWithCompletionHandler:^(NSError *error)
            {
                if(error != nil)
                {
                    NSLog(@"Game Center: Error occurred reporting score-");
                    NSLog(@"  %@", [error userInfo]);
                    sendGameCenterEvent(SCORE_FAILURE, categoryID);
                }

                else
                {
                    NSLog(@"Game Center: Score was successfully sent");
                    sendGameCenterEvent(SCORE_SUCCESS, categoryID);
                }
            }];
        }

        [strCategory release];
        [pool drain];
    }

    //ACHIEVEMENTS

    void showAchievements()
    {
        NSLog(@"Game Center: Show Achievements");
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        GKAchievementViewController* achievements = [[GKAchievementViewController alloc] init];

        if(achievements != nil)
        {
            achievements.achievementDelegate = viewDelegate;
            UIViewController *glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [glView2 presentModalViewController: achievements animated: NO];
                        //dispatchHaxeEvent(ACHIEVEMENTS_VIEW_OPENED);
        }
    }

    void resetAchievements()
    {
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
        {
            if(error != nil)
            {
                NSLog(@"  %@", [error userInfo]);
                sendGameCenterEvent(ACHIEVEMENT_RESET_FAILURE, "");
            }

            else
            {
                 sendGameCenterEvent(ACHIEVEMENT_RESET_SUCCESS, "");
            }
        }];
    }

    void reportAchievement(const char* achievementID, float percent)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        NSString* strAchievement = [[NSString alloc] initWithUTF8String:achievementID];
        GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier:strAchievement] autorelease];

        if(achievement)
        {
            /*if(percent >= 1)
            {
                achievement.showsCompletionBanner = YES;
            }*/

            achievement.percentComplete = percent;
            [achievement reportAchievementWithCompletionHandler:^(NSError *error)
            {
                if(error != nil)
                {
                    NSLog(@"Game Center: Error occurred reporting achievement-");
                    NSLog(@"  %@", [error userInfo]);
                    sendGameCenterEvent(ACHIEVEMENT_FAILURE, achievementID);
                }

                else
                {
                    NSLog(@"Game Center: Achievement report successfully sent");
                    sendGameCenterEvent(ACHIEVEMENT_SUCCESS, achievementID);
                }

            }];
        }

        else
        {
            sendGameCenterEvent(ACHIEVEMENT_FAILURE, achievementID);
        }

        [strAchievement release];
        [pool drain];
    }

    //CALLBACKS

    void registerForAuthenticationNotification()
    {
        // TODO: need to REMOVE OBSERVER on dispose
        CFNotificationCenterAddObserver
        (
            CFNotificationCenterGetLocalCenter(),
            NULL,
            &authenticationChanged,
            (CFStringRef)GKPlayerAuthenticationDidChangeNotificationName,
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );
    }

    void authenticationChanged(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
    {
        if(!isGameCenterAvailable())
        {
            return;
        }

        if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            NSLog(@"Game Center: You are logged in to game center.");
        }

        else
        {
            NSLog(@"Game Center: You are NOT logged in to game center.");
        }
    }

    void achievementViewDismissed()
    {
        //dispatchHaxeEvent(ACHIEVEMENTS_VIEW_CLOSED);
    }

    void leaderboardViewDismissed()
    {
        //dispatchHaxeEvent(LEADERBOARD_VIEW_CLOSED);
    }
}
