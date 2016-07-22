package extension.gamecenter;


import flash.events.Event;


class GameCenterEvent extends Event {
	
	public static inline var DISABLED = "disabled";
	public static inline var AUTH_SUCCESS = "authSuccess";
	public static inline var AUTH_ALREADY = "authAlready";
	public static inline var AUTH_FAILURE = "authFailure";
	public static inline var SCORE_SUCCESS = "scoreSuccess";
	public static inline var SCORE_FAILURE = "scoreFailure";
	public static inline var ACHIEVEMENT_SUCCESS = "achievementSuccess";
	public static inline var ACHIEVEMENT_FAILURE = "achievementFailure";
	public static inline var ACHIEVEMENT_RESET_SUCCESS = "achievementResetSuccess";
	public static inline var ACHIEVEMENT_RESET_FAILURE = "achievementResetFailure";

	public static inline var ON_GET_ACHIEVEMENT_STATUS_FAILURE = "onGetAchievementStatusFailure";
	public static inline var ON_GET_ACHIEVEMENT_STATUS_SUCESS = "onGetAchievementStatusSuccess";
	public static inline var ON_GET_ACHIEVEMENT_PROGRESS_FAILURE = "onGetAchievementProgressFailure"; 
	public static inline var ON_GET_ACHIEVEMENT_PROGRESS_SUCESS = "onGetAchievementProgressSuccess";
	public static inline var ON_GET_PLAYER_SCORE_FAILURE = "onGetPlayerScoreFailure";
	public static inline var ON_GET_PLAYER_SCORE_SUCESS = "onGetPlayerScoreSuccess";

	public static inline var ON_GET_PLAYER_FRIENDS_FAILURE = "onGetPlayerFriendsFailure";
	public static inline var ON_GET_PLAYER_FRIENDS_SUCCESS = "onGetPlayerFriendsSuccess";
	
	public var data1 : String;
	public var data2 : String;
	public var data3 : String;
	public var data4 : String;

	public function new (type:String, data1:String, data2:String, data3:String, data4:String) {
		
		super (type);
		this.data1 = data1;
		this.data2 = data2;
		this.data3 = data3;
		this.data4 = data4;

	}
	
	
}