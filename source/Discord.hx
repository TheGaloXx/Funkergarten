package;

#if sys
import discord_rpc.DiscordRpc;

using StringTools;

class DiscordClient
{
	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1081628829094785084",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			Sys.sleep(2);
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			state: null,
			details: "Loading...",
			startTimestamp: null,
			endTimestamp: null,
			largeImageKey: 'apple',
			largeImageText: null,
			smallImageKey: null,
			smallImageText: null,
			partyID: null,
			partySize: null,
			partyMax: null,
			joinSecret: null
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	/**
	 * Function that changes the `Discord Rich Presence`.
	 * @param   state   The second line in the presence (use it for misses).
	 * @param   details   The first line in the presence (use for current state and song details).
	 * @param   hasStartTimestamp      Time left indicator (ignore).
	 * @param   endTimestamp     End time indicator (ignore).
	 * @param   smallImageKey The small image name.
	**/
	public static function changePresence(state:String, details:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, smallImageKey:String,
			addLittleIcon:Bool = false)
	{
		// time shit
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;
		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			state: state,
			details: details,
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000),
			largeImageKey: 'apple',
			largeImageText: null,
			smallImageKey: smallImageKey,
			smallImageText: (addLittleIcon ? CoolUtil.firstLetterUpperCase(smallImageKey) : null),
			partyID: null, // these are unnecesary but whatever
			partySize: null,
			partyMax: null,
			joinSecret: null
		});
	}
}
#else
// made it like this cuz uhhhhhh funny compilation checks - sanco
class DiscordClient
{
	public function new() {}

	public static function shutdown() {}

	static function onReady() {}

	static function onError(_code:Int, _message:String) {}

	static function onDisconnected(_code:Int, _message:String) {}

	public static function initialize() {}

	/**
	 * Function that changes the `Discord Rich Presence`.
	 * @param   state   The second line in the presence (use it for misses).
	 * @param   details   The first line in the presence (use for current state and song details).
	 * @param   hasStartTimestamp      Time left indicator (ignore).
	 * @param   endTimestamp     End time indicator (ignore).
	 * @param   smallImageKey The small image name.
	**/
	public static function changePresence(state:String, details:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, smallImageKey:String,
		addLittleIcon:Bool = false) {}
}
#end
