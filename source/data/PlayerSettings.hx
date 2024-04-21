package data;

import data.Controls;

class PlayerSettings
{
	public static var player(default, null):PlayerSettings;

	public final controls:Controls;

	function new()
	{
		this.controls = new Controls('player');
	}

	public static function init():Void
	{
		player ??= new PlayerSettings();
	}
}