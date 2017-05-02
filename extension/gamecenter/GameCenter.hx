package extension.gamecenter;


import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.ByteArray;


class GameCenter {
	
	
	public static var available (get, null):Bool;
	
	private static var dispatcher = new EventDispatcher ();
	private static var initialized = false;
	
	
	public static function addEventListener (type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		
		dispatcher.addEventListener (type, listener, useCapture, priority, useWeakReference);
		
	}
	
	public static function removeEventListener (type:String, listener:Dynamic):Void {
		
		dispatcher.removeEventListener (type, listener);
		
	}
	
	public static function authenticate ():Void {
		
		initialize ();
		
		#if (ios || mac)
		#if (openfl_next || openfl_legacy || nme)
			openfl.Lib.pause ();
		#else
			openfl.system.System.pause ();
		#end
		gamecenter_authenticate ();
		#end
		
	}
	
	
	public static function dispatchEvent (event:Event):Bool {
		
		return dispatcher.dispatchEvent (event);
		
	}
	
	
	public static function hasEventListener (type:String):Bool {
		
		return dispatcher.hasEventListener (type);
		
	}
	
	
	private static function initialize ():Void {
		
		if (!initialized) {
			
			#if (ios || mac)
			gamecenter_set_event_handle (notifyListeners);
			gamecenter_initialize ();
			#end
			
			initialized = true;
			
		}
		
	}
	
	
	public static function getPlayerName ():String {
		
		initialize ();
		
		#if (ios || mac)
		return gamecenter_playername ();
		#else
		return null;
		#end
		
	}
	
	
	public static function getPlayerID ():String {
		
		initialize ();
		
		#if (ios || mac)
		return gamecenter_playerid ();
		#else
		return null;
		#end
		
	}

	public static function getPlayerFriends(){
		
		initialize();

		#if (ios || mac)
		gamecenter_playerfriends ();
		#end

	}

	public static function getPlayerPhoto(playerID:String){

		initialize();

		#if (ios || mac)
		gamecenter_playerphoto(playerID);
		#end
	}
	
	
	private static function notifyListeners (inEvent:Dynamic) {
		
		#if (ios || mac)
		
		#if (openfl_next || openfl_legacy || nme)
			openfl.Lib.resume ();
		#else
			openfl.system.System.resume ();
		#end
		
		var type = Std.string (Reflect.field (inEvent, "type"));
		var data1 = Std.string (Reflect.field (inEvent, "data1"));
		var data2 = Std.string (Reflect.field (inEvent, "data2"));
		var data3 = Std.string (Reflect.field (inEvent, "data3"));
		var data4 = Std.string (Reflect.field (inEvent, "data4"));
		dispatcher.dispatchEvent(new GameCenterEvent(type, data1, data2, data3, data4));
		
		#end
		
	}
	
	
	/**
    /* Reports changed in achievement completion.
	/* 
    /* @param achievementID The Achievement ID.
    /* @param percentComplete The range of legal values is between 0.0 and 100.0, inclusive.
    /* @param showCompletionBanner Indicates if GameCenter should display the completion banner for this achievement if completed.
    **/
	public static function reportAchievement (achievementID:String, percentComplete:Float, showCompletionBanner:Bool=true):Void {
		
		initialize ();
		
		#if (ios || mac)
		gamecenter_reportachievement (achievementID, percentComplete, showCompletionBanner);
		#end
		
	}
	
	
	public static function reportScore (categoryID:String, score:Int):Void {
		
		initialize ();
		
		#if (ios || mac)
		gamecenter_reportscore (categoryID, score);
		#end
		
	}
	
	
	public static function resetAchievements ():Void {
		
		initialize ();
		
		#if (ios || mac)
		gamecenter_resetachievements ();
		#end
		
	}
	
	
	public static function showAchievements ():Void {
		
		initialize ();
		
		#if (ios || mac)
		// #if (openfl_next || openfl_legacy || nme)
		// 	openfl.Lib.pause ();
		// #else
		// 	openfl.system.System.pause ();
		// #end
		gamecenter_showachievements ();
		#end
		
	}
	
	
	public static function showLeaderboard (categoryID:String):Void {
		
		initialize ();
		
		#if (ios || mac)
		// #if (openfl_next || openfl_legacy || nme)
		// 	openfl.Lib.pause ();
		// #else
		// 	openfl.system.System.pause ();
		// #end
		gamecenter_showleaderboard (categoryID);
		#end
		
	}
	 
	public static function getAchievementProgress(achievementID:String):Void {
		initialize ();
		#if (ios || mac)
			gamecenter_getAchievementProgress(achievementID);
		#end
	}

	public static function getAchievementStatus(achievementID:String):Void {
		initialize ();
		#if (ios || mac)
			gamecenter_getAchievementStatus(achievementID);
		#end
	}
	public static function getPlayerScore(leaderboardID:String):Void {
		initialize ();
		#if (ios || mac)
			gamecenter_getPlayerScore(leaderboardID);
		#end
	}
	
	// Get & Set Methods	
	
	
	private static function get_available ():Bool {
		
		#if (ios || mac)
		return gamecenter_isavailable ();
		#else
		return false;
		#end
		
	}
	
	
	
	
	// Native Methods
	
	#if (ios || mac)
	private static var gamecenter_set_event_handle = cpp.Lib.load ("gamecenter", "gamecenter_set_event_handle", 1);
	private static var gamecenter_initialize = cpp.Lib.load ("gamecenter", "gamecenter_initialize", 0);
	private static var gamecenter_authenticate = cpp.Lib.load ("gamecenter", "gamecenter_authenticate", 0);
	private static var gamecenter_isavailable = cpp.Lib.load ("gamecenter", "gamecenter_isavailable", 0);
	private static var gamecenter_isauthenticated = cpp.Lib.load ("gamecenter", "gamecenter_isauthenticated", 0);
	private static var gamecenter_playername = cpp.Lib.load ("gamecenter", "gamecenter_playername", 0);
	private static var gamecenter_playerid = cpp.Lib.load ("gamecenter", "gamecenter_playerid", 0);
	private static var gamecenter_playerfriends = cpp.Lib.load("gamecenter", "gamecenter_playerfriends", 0);
	private static var gamecenter_playerphoto = cpp.Lib.load("gamecenter", "gamecenter_playerphoto", 1);
	private static var gamecenter_showleaderboard = cpp.Lib.load ("gamecenter", "gamecenter_showleaderboard", 1);
	private static var gamecenter_showachievements = cpp.Lib.load ("gamecenter", "gamecenter_showachievements", 0);
	private static var gamecenter_reportscore = cpp.Lib.load ("gamecenter", "gamecenter_reportscore", 2);
	private static var gamecenter_reportachievement = cpp.Lib.load ("gamecenter", "gamecenter_reportachievement", 3);
	private static var gamecenter_resetachievements = cpp.Lib.load ("gamecenter", "gamecenter_resetachievements", 0);
	private static var gamecenter_getAchievementProgress = cpp.Lib.load ("gamecenter", "gamecenter_getAchievementProgress", 1);
	private static var gamecenter_getAchievementStatus = cpp.Lib.load ("gamecenter", "gamecenter_getAchievementStatus", 1);
	private static var gamecenter_getPlayerScore = cpp.Lib.load ("gamecenter", "gamecenter_getPlayerScore", 1);

	#end
	
	
}