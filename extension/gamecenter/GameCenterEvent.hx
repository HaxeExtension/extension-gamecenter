package extension.gamecenter;


import flash.events.Event;


class GameCenterEvent extends Event {
	
	
	public static inline var AUTH_SUCCESS = "authSuccess";
	public static inline var AUTH_ALREADY = "authAlready";
	public static inline var AUTH_FAILURE = "authFailure";
	public static inline var SCORE_SUCCESS = "scoreSuccess";
	public static inline var SCORE_FAILURE = "scoreFailure";
	public static inline var ACHIEVEMENT_SUCCESS = "achievementSuccess";
	public static inline var ACHIEVEMENT_FAILURE = "achievementFailure";
	public static inline var ACHIEVEMENT_RESET_SUCCESS = "achievementResetSuccess";
	public static inline var ACHIEVEMENT_RESET_FAILURE = "achievementResetFailure";
	
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