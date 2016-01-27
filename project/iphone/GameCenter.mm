#include <GameCenter.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GameKit/GameKit.h>
#define __STDC_FORMAT_MACROS // non needed in C, only in C++
#include <inttypes.h>

extern "C" void sendGameCenterEvent (const char* event, const char* data1, const char* data2, const char* data3, const char* data4);


typedef void (*FunctionType)();


@interface GKViewDelegate : NSObject <GKAchievementViewControllerDelegate,GKLeaderboardViewControllerDelegate> {}
	
	- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController;
	- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController;
	
	@property (nonatomic) FunctionType onAchievementFinished;
	@property (nonatomic) FunctionType onLeaderboardFinished;
	
@end


@implementation GKViewDelegate
	
	@synthesize onAchievementFinished;
	@synthesize onLeaderboardFinished;
	
	- (id)init {
		
		self = [super init];
		return self;
		
	}
	
	- (void)dealloc {
		
		[super dealloc];
		
	}
	
	UIViewController *glView2;
	
	- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController {
		
		[viewController dismissModalViewControllerAnimated:YES];
		[viewController.view.superview removeFromSuperview];
		[viewController release];
		onAchievementFinished ();
		
	}
	
	- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController {
		
		[viewController dismissModalViewControllerAnimated:YES];
		[viewController.view.superview removeFromSuperview];
		[viewController release];
		onLeaderboardFinished ();
		
	}
	
@end



namespace gamecenter {
	
	
	static int isInitialized = 0;
	GKViewDelegate* viewDelegate;
	
	//---
	
	
	//User
	
	void initializeGameCenter ();
	bool isGameCenterAvailable ();
	bool isUserAuthenticated ();
	void authenticateLocalUser ();
	
	const char* getPlayerName ();
	const char* getPlayerID ();
	
	
	//Leaderboards
	
	void showLeaderboard (const char* categoryID);
	void reportScore (const char* categoryID, int score);
	
	
	//Achievements
	
	void showAchievements ();
	void resetAchievements ();
	void reportAchievement (const char* achievementID, float percent, bool showCompletionBanner);
	
	
	//Callbacks
	
	void registerForAuthenticationNotification ();
	static void authenticationChanged (CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo);
	
	void achievementViewDismissed ();
	void leaderboardViewDismissed ();
	
	
	//Events
	
	static const char* DISABLED = "disabled";
	static const char* AUTH_SUCCESS = "authSuccess";
	static const char* AUTH_ALREADY = "authAlready";
	static const char* AUTH_FAILURE = "authFailure";
	static const char* SCORE_SUCCESS = "scoreSuccess";
	static const char* SCORE_FAILURE = "scoreFailure";
	static const char* ACHIEVEMENT_SUCCESS = "achievementSuccess";
	static const char* ACHIEVEMENT_FAILURE = "achievementFailure";
	static const char* ACHIEVEMENT_RESET_SUCCESS = "achievementResetSuccess";
	static const char* ACHIEVEMENT_RESET_FAILURE = "achievementResetFailure";

	static const char* ON_GET_ACHIEVEMENT_STATUS_FAILURE = "onGetAchievementStatusFailure";
	static const char* ON_GET_ACHIEVEMENT_STATUS_SUCESS = "onGetAchievementStatusSucess";
	static const char* ON_GET_ACHIEVEMENT_PROGRESS_FAILURE = "onGetAchievementProgressFailure"; 
	static const char* ON_GET_ACHIEVEMENT_PROGRESS_SUCESS = "onGetAchievementProgressSucess";
	static const char* ON_GET_PLAYER_SCORE_FAILURE = "onGetPlayerScoreFailure";
	static const char* ON_GET_PLAYER_SCORE_SUCESS = "onGetPlayerScoreSucess";
	
	//---
	
	
	
	
	//USER
	
	
	
	
	void initializeGameCenter () {
		
		if (isInitialized == 1) {
			
			return;
			
		}
		
		if (isGameCenterAvailable ()) {
			
			viewDelegate = [[GKViewDelegate alloc] init];
			viewDelegate.onAchievementFinished = &achievementViewDismissed;
			viewDelegate.onLeaderboardFinished = &leaderboardViewDismissed;
			
			isInitialized = 1;
			authenticateLocalUser ();
			
		}
		
	}
	
	
	bool isGameCenterAvailable () {
		
		// check for presence of GKLocalPlayer API
		Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
		
		// check if the device is running iOS 4.1 or later  
		NSString* reqSysVer = @"4.1";   
		NSString* currSysVer = [[UIDevice currentDevice] systemVersion];   
		BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);   

		NSLog(@"Game Center is available");
		return (gcClass && osVersionSupported);
		
	}
	
	
	bool isUserAuthenticated () {
		
		return ([GKLocalPlayer localPlayer].isAuthenticated);
		
	}
	
	
	void authenticateLocalUser () {
		
		if (!isGameCenterAvailable ()) {
			
			NSLog (@"Game Center: is not available");
			sendGameCenterEvent (DISABLED, "", "", "", "");
			return;
			
		}
		
		NSLog (@"Authenticating local user...");
		
		if ([GKLocalPlayer localPlayer].authenticated == NO) {
			
			GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

			[localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
				
				if (localPlayer.isAuthenticated) {
					
					NSLog (@"Game Center: You are logged in to game center.");
					registerForAuthenticationNotification();

					[localPlayer generateIdentityVerificationSignatureWithCompletionHandler:^(NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error)
					{
						if(error != nil) {
						    // some sort of error, can't authenticate with url/signature/salt
						    // but authentication did succeed according to GameCenter so report it
						    sendGameCenterEvent (AUTH_SUCCESS, "", "", "", "");
						    return;
						}

						NSString* urlString = [publicKeyUrl absoluteString];

						char timestampBuf[256];
                        snprintf(timestampBuf, sizeof timestampBuf, "%"PRIu64, timestamp);
                        NSLog(@"SALT: %@", salt);

						//[self verifyPlayer:localPlayer.playerID publicKeyUrl:publicKeyUrl signature:signature salt:salt timestamp:timestamp];
						sendGameCenterEvent (AUTH_SUCCESS, [urlString UTF8String], [[signature base64EncodedStringWithOptions:0] UTF8String], [[salt base64EncodedStringWithOptions:0] UTF8String], timestampBuf);
					}];

				} else if (viewcontroller != nil) {
					
					NSLog (@"Game Center: User was not logged in. Show Login Screen.");
					UIViewController *glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
					[glView2 presentModalViewController: viewcontroller animated : NO];
					
				} else if (error != nil) {
					
					NSLog (@"Game Center: Error occurred authenticating-");
					NSLog (@"  %@", [error localizedDescription]);
					NSString* errorDescription = [error localizedDescription];
					sendGameCenterEvent (AUTH_FAILURE, [errorDescription UTF8String], "", "", "");
					
				}
				
			})];
			
		} else {
			
			NSLog (@"Already authenticated!");
			sendGameCenterEvent (AUTH_ALREADY, "", "", "", "");
			
		}
		
	}
	
	
	const char* getPlayerName () {
		
		GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
		
		if (localPlayer.isAuthenticated) {
			
			return [localPlayer.alias cStringUsingEncoding:NSUTF8StringEncoding];
			
		} else {
			
			return NULL;
			
		}
		
	}
	
	
	const char* getPlayerID () {
		
		GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
		
		if (localPlayer.isAuthenticated) {
			
			return [localPlayer.playerID cStringUsingEncoding:NSUTF8StringEncoding];
			
		} else {
			
			return NULL;
			
		}
		
	}
	
	
	
	
	//LEADERBOARDS
	
	
	
	
	void showLeaderboard (const char* categoryID) {
		
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString* strCategory = [[NSString alloc] initWithUTF8String:categoryID];
		
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];  
		
		if (leaderboardController != nil) {
			
			leaderboardController.category = strCategory;
			leaderboardController.leaderboardDelegate = viewDelegate;
			UIViewController *glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
			[glView2 presentModalViewController:leaderboardController animated: NO];
			
		}
		
		[strCategory release];
		[pool drain];
		
	}
	
	
	void reportScore (const char* categoryID, int score) {
		
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString* strCategory = [[NSString alloc] initWithUTF8String:categoryID];
		GKScore* scoreReporter = [[[GKScore alloc] initWithCategory:strCategory] autorelease];
		
		if (scoreReporter) {
			
			scoreReporter.value = score;
			
			[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
				   
				if (error != nil) {
					
					NSLog (@"Game Center: Error occurred reporting score-");
					NSLog (@"  %@", [error userInfo]);
					sendGameCenterEvent (SCORE_FAILURE, categoryID, "", "", "");
					
				} else {
					
					NSLog (@"Game Center: Score was successfully sent");
					sendGameCenterEvent (SCORE_SUCCESS, categoryID, "", "", "");
					
				}
				
			}];
			  
		}
		
		[strCategory release];
		[pool drain];
		
	}
	
	void getPlayerScore(const char* leaderboardID) {

		NSString* strLeaderboard = [[NSString alloc] initWithUTF8String:leaderboardID];
		GKLeaderboard* leaderboardRequest = [[GKLeaderboard alloc] init];
		leaderboardRequest.identifier = strLeaderboard;
		
		[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error != nil) {
				// Handle the error.
				NSLog (@"Game Center: Error occurred getting score-");
				NSLog (@"  %@", [error userInfo]);				
				sendGameCenterEvent (ON_GET_PLAYER_SCORE_FAILURE, leaderboardID, "", "", "");
			}
			if (scores != nil) {
				// Process the score information.
				GKScore* localPlayerScore = leaderboardRequest.localPlayerScore;
				NSString* myString = [NSString stringWithFormat:@"%lld", localPlayerScore.value];
				NSLog (@"Game Center: Player score was successfully obtained");
				sendGameCenterEvent (ON_GET_PLAYER_SCORE_SUCESS, leaderboardID, [myString UTF8String], "", "");			
			}
		}];
		[strLeaderboard release];	
	}

	//ACHIEVEMENTS
		
	
	
	void showAchievements () {
		
		NSLog(@"Game Center: Show Achievements");
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKAchievementViewController* achievements = [[GKAchievementViewController alloc] init]; 
		
		if (achievements != nil) {
			
			achievements.achievementDelegate = viewDelegate;
			UIViewController *glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
			[glView2 presentModalViewController: achievements animated: NO];
			//dispatchHaxeEvent(ACHIEVEMENTS_VIEW_OPENED);
			
		}
		
	}
	
	
	void resetAchievements () {
		
		[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
			
			if (error != nil) {
				
				NSLog (@"  %@", [error userInfo]);
				sendGameCenterEvent (ACHIEVEMENT_RESET_FAILURE, "", "", "", "");
				
			} else {
				
				sendGameCenterEvent(ACHIEVEMENT_RESET_SUCCESS, "", "", "", "");
				
			}
			
		}];
		
	}
	
	
	/*!
	 * Reports changed in achievement completion.
	 *
	 * \param achievementID The Achievement ID.
	 * \param percentComplete The range of legal values is between 0.0 and 100.0, inclusive.
	 */
	void reportAchievement (const char* achievementID, float percentComplete, bool showCompletionBanner) {
		
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString* strAchievement = [[NSString alloc] initWithUTF8String:achievementID];
		NSLog (@"Game Center: Report Achievements");
		NSLog (@"  %@", strAchievement);
		GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier:strAchievement] autorelease];
		
		if (achievement) {
			
			/*if(percentComplete >= 100)
			{
				achievement.showsCompletionBanner = YES;
			}*/
			
			achievement.percentComplete = percentComplete;    
			achievement.showsCompletionBanner = showCompletionBanner;
			
			[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
				
				if (error != nil) {
					
					NSLog (@"Game Center: Error occurred reporting achievement-");
					NSLog (@"  %@", [error userInfo]);
					sendGameCenterEvent (ACHIEVEMENT_FAILURE, achievementID, "", "", "");
					
				} else {
					
					NSLog (@"Game Center: Achievement report successfully sent");
					sendGameCenterEvent (ACHIEVEMENT_SUCCESS, achievementID, "", "", "");
					
				}
				
			}];
			
		} else {
			
			sendGameCenterEvent (ACHIEVEMENT_FAILURE, achievementID, "", "", "");
			
		}
		
		[strAchievement release];
		[pool drain];
		
	}
	
	void getAchievementProgress(const char* achievementID) {

		NSString* strAchievementInput = [[NSString alloc] initWithUTF8String:achievementID];

		[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
			if (error != nil) {
				NSLog (@"Game Center: Error occurred getting achievements array-");
				NSLog (@"  %@", [error userInfo]);				
				sendGameCenterEvent (ON_GET_ACHIEVEMENT_PROGRESS_FAILURE, achievementID, "", "", "");
			}
			if (achievements != nil) {
				// Process the array of achievements.
				for (GKAchievement* achievement in achievements) {
					if ([achievement.identifier isEqualToString:strAchievementInput]) {
						NSString* myString = [NSString stringWithFormat:@"%.2f", achievement.percentComplete];
						NSLog (@"Game Center: Achievement percent was successfully obtained");
						sendGameCenterEvent (ON_GET_ACHIEVEMENT_PROGRESS_SUCESS, achievementID, [myString UTF8String], "", "");
						return;
					}
				}
			}
		}];
	}

	void getAchievementStatus(const char* achievementID) {

		NSString* strAchievementInput = [[NSString alloc] initWithUTF8String:achievementID];

		[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
			if (error != nil) {
				NSLog (@"Game Center: Error occurred getting achievements array-");
				NSLog (@"  %@", [error userInfo]);				
				sendGameCenterEvent (ON_GET_ACHIEVEMENT_STATUS_FAILURE, achievementID, "", "", "");
			}
			if (achievements != nil) {
				// Process the array of achievements.
				for (GKAchievement* achievement in achievements) {
					if ([achievement.identifier isEqualToString:strAchievementInput]) {
						if (achievement.completed) {
							NSLog (@"Game Center: Achievement status was successfully obtained");
							NSString* status = @"Completed";
							sendGameCenterEvent (ON_GET_ACHIEVEMENT_STATUS_SUCESS, achievementID, [status UTF8String], "", "");
						} else {
							NSLog (@"Game Center: Achievement status was successfully obtained");
							NSString* status = @"Not Completed";
							sendGameCenterEvent (ON_GET_ACHIEVEMENT_STATUS_SUCESS, achievementID, [status UTF8String], "", "");
						}
					}
					return;
				}
			}
		}];
	}

	//CALLBACKS
	
	
	
	void registerForAuthenticationNotification () {
		
		// TODO: need to REMOVE OBSERVER on dispose
		CFNotificationCenterAddObserver (CFNotificationCenterGetLocalCenter (), NULL, &authenticationChanged, (CFStringRef)GKPlayerAuthenticationDidChangeNotificationName, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		
	}
	
	
	void authenticationChanged (CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
		
		if (!isGameCenterAvailable ()) {
			
			NSLog (@"Game Center: is not available");
			return;
			
		}
		
		if ([GKLocalPlayer localPlayer].isAuthenticated) {
			
			NSLog (@"Game Center: You are logged in to game center.");

			sendGameCenterEvent (AUTH_SUCCESS, "", "", "", "");

		} else {
			
			NSLog (@"Game Center: You are NOT logged in to game center.");
			sendGameCenterEvent (AUTH_FAILURE, "", "", "", "");
			
		}
		
	}
	
	
	void achievementViewDismissed () {
		
		//dispatchHaxeEvent(ACHIEVEMENTS_VIEW_CLOSED);
		
	}
	
	
	void leaderboardViewDismissed () {
		
		//dispatchHaxeEvent(LEADERBOARD_VIEW_CLOSED);
		
	}
	
	
}