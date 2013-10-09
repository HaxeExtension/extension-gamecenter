package extension.gamecenter;


import flash.events.Event;


class GameCenterEvent extends Event {
	
	
	public static inline var AUTH_SUCCESS = "authSuccess";
	public static inline var AUTH_FAILURE = "authFailure";
	public static inline var SCORE_SUCCESS = "scoreSuccess";
	public static inline var SCORE_FAILURE = "scoreFailure";
	public static inline var ACHIEVEMENT_SUCCESS = "achievementSuccess";
	public static inline var ACHIEVEMENT_FAILURE = "achievementFailure";
	public static inline var ACHIEVEMENT_RESET_SUCCESS = "achievementResetSuccess";
	public static inline var ACHIEVEMENT_RESET_FAILURE = "achievementResetFailure";
	
	
	public function new (type:String) {
		
		super (type);
		
	}
	
	
}