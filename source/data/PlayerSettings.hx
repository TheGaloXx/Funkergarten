package data;

import data.Controls;
import flixel.FlxG;
import flixel.util.FlxSignal;

// import ui.DeviceManager;
// import props.Player;
class PlayerSettings
{
	static public var numPlayers(default, null) = 0;
	static public var numAvatars(default, null) = 0;
	static public var player1(default, null):data.PlayerSettings;
	static public var player2(default, null):data.PlayerSettings;

	#if (haxe >= "4.0.0")
	static public final onAvatarAdd = new FlxTypedSignal<data.PlayerSettings->Void>();
	static public final onAvatarRemove = new FlxTypedSignal<data.PlayerSettings->Void>();
	#else
	static public var onAvatarAdd = new FlxTypedSignal<data.PlayerSettings->Void>();
	static public var onAvatarRemove = new FlxTypedSignal<data.PlayerSettings->Void>();
	#end

	public var id(default, null):Int;

	#if (haxe >= "4.0.0")
	public final controls:data.Controls;
	#else
	public var controls:data.Controls;
	#end

	// public var avatar:Player;
	// public var camera(get, never):PlayCamera;

	function new(id, scheme)
	{
		this.id = id;
		this.controls = new data.Controls('player$id', scheme);
	}

	static public function init():Void
	{
		if (player1 == null)
		{
			player1 = new data.PlayerSettings(0, Solo);
			++numPlayers;
		}
	}

	static public function reset()
	{
		player1 = null;
		player2 = null;
		numPlayers = 0;
	}
}