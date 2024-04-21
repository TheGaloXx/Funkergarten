package data;

import flixel.math.FlxMath;
import flixel.util.FlxSave;
import funkin.Conductor;
import flixel.FlxSprite;

using StringTools;

class GlobalData
{
	public static final allCharacters:Array<String> = ['bf', 'bf-pixel', 'bf-alt', 'bf-dead', 'bf-pixel-dead', 'protagonist', 'nugget', 'janitor', 'monty', 'principal', 'protagonist-pixel', 'cindy', 'lily', 'monster', 'polla'];
	public static final allSongs:Array<String> = ['Monday', 'Nugget', 'Staff Only', 'Cash Grab', 'Expelled', 'Nugget de Polla', 'Petty Petals'];
	public static final storySongs:Array<String> = ['Monday', 'Nugget', 'Staff Only', 'Cash Grab', 'Expelled'];
	public static final secretSongs:Array<String> = ['Nugget de Polla', 'Expelled V0'];
	public static final allowedMenuCharacters:Array<String> = ['protagonist', 'nugget', 'monty', 'janitor', 'principal', 'cindy', 'lily', 'monster', 'polla'];

	public static var other:OtherData;
	public static var settings:SettingsData;
	public static var controls:ControlsData;

	public static var other_save = new FlxSave();
	public static var settings_save = new FlxSave();
	public static var controls_save = new FlxSave();
	public static var chart_autosave = new FlxSave();

	public static var showHelp:Bool = true;
	public static var botplay:Bool = false;
	public static var practice:Bool = false;

    public static function initSave()
    {
		GlobalData.bind();

		#if debug
		chart_autosave.data.chart ??= {};
		#end

		initSettings();
		initOther();
		initControls();

		flush();

		FlxSprite.defaultAntialiasing = settings.antialiasingEnabled;

		Conductor.recalculateTimings();

		PlayerSettings.init();
		PlayerSettings.player.controls.loadKeyBinds();

		Main.changeFPS(settings.fpsCap);
	}

	public static function resetData()
	{
		other =
		{
			mondays: defaultOther.mondays,
			menuCharacters: defaultOther.menuCharacters,
			beatenStoryMode: defaultOther.beatenStoryMode,
			beatenSongs: defaultOther.beatenSongs,
			gotSkin: defaultOther.gotSkin,
			metNugget: defaultOther.metNugget,
			seenCredits: defaultOther.seenCredits,
			didPolla: defaultOther.didPolla,
			sawAdvice: defaultOther.sawAdvice,
			usingSkin: defaultOther.usingSkin,
			didV0: defaultOther.didV0,
			songScores: defaultOther.songScores,
			fcedSongs: defaultOther.fcedSongs,
			songCombos: defaultOther.songCombos
		}

		setDataOf(other_save, other, DATABASE_TO_FLXSAVE);

		Highscore.load();
		FCs.init();

		flush();
	}

	public static function initSettings():Void
	{
		settings = 
		{
			downscroll: false,
			showFPS: false,
			mechanicsEnabled: true,
			antialiasingEnabled: true,
			singCamMoveEnabled: true,
			fullscreen: false,
			middlescroll: false,
			lowQuality: false,
			flashingLights: true,
			shadersEnabled: true,
			ghostTapping: true,
			colorblindType: 'No filter',
			camZoomsEnabled: true,
			fpsCap: 60,
			changedHit: false,
			changedHitX: -1,
			changedHitY: -1,
			language: null
		}

		setDataOf(settings_save, settings, FLXSAVE_TO_DATABASE);

		settings.fpsCap = Std.int(FlxMath.bound(settings.fpsCap, 60, 240));

		if (settings.changedHit == null)
		{
			settings.changedHitX = settings.changedHitY = -1;
			settings.changedHit = false;
		}

		setDataOf(settings_save, settings, DATABASE_TO_FLXSAVE);
	}

	private static function initOther():Void
	{
		other =
		{
			mondays: defaultOther.mondays,
			menuCharacters: defaultOther.menuCharacters,
			beatenStoryMode: defaultOther.beatenStoryMode,
			beatenSongs: defaultOther.beatenSongs,
			gotSkin: defaultOther.gotSkin,
			metNugget: defaultOther.metNugget,
			seenCredits: defaultOther.seenCredits,
			didPolla: defaultOther.didPolla,
			sawAdvice: defaultOther.sawAdvice,
			usingSkin: defaultOther.usingSkin,
			didV0: defaultOther.didV0,
			songScores: defaultOther.songScores,
			fcedSongs: defaultOther.fcedSongs,
			songCombos: defaultOther.songCombos
		}

		setDataOf(other_save, other, FLXSAVE_TO_DATABASE);

		if (other.mondays < 0)
			other.mondays = 0;

		setDataOf(other_save, other, DATABASE_TO_FLXSAVE);
	}

    public static function initControls():Void
    {
		controls = 
		{
			leftBind: 'A',
			downBind: 'S',
			upBind: 'W',
			rightBind: 'D'
		}

		setDataOf(controls_save, controls, FLXSAVE_TO_DATABASE);

        if (controls.leftBind.contains("NUMPAD"))
            controls.leftBind = "A";
		if (controls.downBind.contains("NUMPAD"))
            controls.downBind = "S";
		if (controls.upBind.contains("NUMPAD"))
            controls.upBind = "W";
		if (controls.rightBind.contains("NUMPAD"))
            controls.rightBind = "D";

		setDataOf(controls_save, controls, DATABASE_TO_FLXSAVE);

        trace('KEYBINDS: [${controls.leftBind} - ${controls.downBind} - ${controls.upBind} - ${controls.rightBind}].');
    }

	public static function bind():Void
	{
		trace("Creating/reconnecting data!");

		other_save.bind('other', 'funkergarten');
		settings_save.bind('settings', 'funkergarten');
		controls_save.bind('controls', 'funkergarten');

		#if debug
		chart_autosave.bind('chart_autosave', 'funkergarten');
		#end
	}

	public static function flush():Void
	{
		trace("Saving data!");

		setDataOf(other_save, other, DATABASE_TO_FLXSAVE);
		setDataOf(settings_save, settings, DATABASE_TO_FLXSAVE);
		setDataOf(controls_save, controls, DATABASE_TO_FLXSAVE);

		other_save.flush();
		settings_save.flush();
		controls_save.flush();
	}

	public static function autoUnlock():Void
	{
		#if debug
		other.mondays = 999;
		other.menuCharacters = GlobalData.allowedMenuCharacters;
		other.beatenStoryMode = true;
		other.beatenSongs = GlobalData.allSongs;
		other.gotSkin = true;
		other.metNugget = true;
		other.seenCredits = true;
		other.didPolla = true;
		other.sawAdvice = true;
		other.didV0 = true;

		flush();
		#else
		trace('CHEATER');
		#end
	}

	private static final defaultOther:OtherData = 
	{
		mondays: 0,
		menuCharacters: ['protagonist'],
		beatenStoryMode: false,
		beatenSongs: [],
		gotSkin: false,
		metNugget: false,
		seenCredits: false,
		didPolla: false,
		sawAdvice: false,
		usingSkin: false,
		didV0: false,
		songScores: null,
		fcedSongs: null,
		songCombos: null
	}

	private static function setDataOf<T>(save:FlxSave, dataBase:T, type:DataSettingType):Void
	{
		if (type == FLXSAVE_TO_DATABASE)
		{
			var otherDataFields:Array<String> = Reflect.fields(save.data);

			for (i in 0...otherDataFields.length)
			{
				var curField:String = otherDataFields[i];
				var curValue:Dynamic = Reflect.field(save.data, curField);

				if (curValue != null)
				{
					Reflect.setField(dataBase, curField, curValue); // if the value of the flxsave's field isnt null, set it in the data typedef
				}
				else
				{
					var defaultValue:Dynamic = Reflect.field(dataBase, curField);

					Reflect.setField(save.data, curField, defaultValue); // if the value of the flxsave's field IS null, replace it by the default value of that field (the one in the typedef)
				}
			}
		}
		else if (type == DATABASE_TO_FLXSAVE)
		{
			var otherDataFields:Array<String> = Reflect.fields(dataBase);

			for (i in 0...otherDataFields.length)
			{
				var curField:String = otherDataFields[i];
				var curValue:Dynamic = Reflect.field(dataBase, curField);

				if (curValue != null)
				{
					Reflect.setField(save.data, curField, curValue); // if the value of the data typedef's field isnt null, set it in the flxsave instance
				}
				else
				{
					var defaultValue:Dynamic = Reflect.field(save.data, curField);

					Reflect.setField(dataBase, curField, defaultValue); // if the value of the data typedef's field IS null, replace it by the default value of that field
				}
			}
		}
	}
}

private typedef OtherData =
{
	var mondays:Int;
	var menuCharacters:Array<String>;
	var beatenStoryMode:Bool;
	var beatenSongs:Array<String>;
	var gotSkin:Bool;
	var metNugget:Bool;
	var seenCredits:Bool;
	var didPolla:Bool;
	var sawAdvice:Bool;
	var usingSkin:Bool;
	var didV0:Bool;
	var songScores:Map<String, Int>;
	var fcedSongs:Map<String, Bool>;
	var songCombos:Map<String, String>;
}

typedef SettingsData =
{
	var downscroll:Bool;
	var showFPS:Bool;
	var mechanicsEnabled:Bool;
	var antialiasingEnabled:Bool;
	var singCamMoveEnabled:Bool;
	var fullscreen:Bool;
	var middlescroll:Bool;
	var lowQuality:Bool;
	var flashingLights:Bool;
	var shadersEnabled:Bool;
	var ghostTapping:Bool;
	var colorblindType:String;
	var camZoomsEnabled:Bool;
	var fpsCap:Int;
	var changedHit:Null<Bool>;
	var changedHitX:Float;
	var changedHitY:Float;
	var language:String;
}

private typedef ControlsData =
{
	var leftBind:String;
	var downBind:String;
	var upBind:String;
	var rightBind:String;

	/* maybe???
	var appleBind:String;
	var volUpBind:String;
	var volDownBind:String;
	var pauseBind:String;
	*/
}

enum DataSettingType
{
	FLXSAVE_TO_DATABASE;
	DATABASE_TO_FLXSAVE;
}