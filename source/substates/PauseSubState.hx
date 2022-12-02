package substates;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if cpp
import llua.Lua;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.app.Application;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	
	var menuItems:Array<String> = (FlxG.save.data.esp ? ['Resumir', 'Reiniciar Cancion', (FlxG.save.data.botplay ? 'Desactivar Botplay' : 'Activar Botplay'), (FlxG.save.data.practice ? 'Desactivar Modo de Practica' : 'Activar Modo de Practica'), 'Opciones', 'Regresar al Menu'] : ['Resume', 'Restart Song', (FlxG.save.data.botplay ? 'Disable Botplay' : 'Enable Botplay'), (FlxG.save.data.practice ? 'Disable Practice Mode' : 'Enable Practice Mode'), 'Options', 'Exit to menu']);
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;

	public static var options:Bool = false;

	public static var time:Float;

	var canDoSomething:Bool = true;

	public function new(x:Float, y:Float)
	{
		super();

		Application.current.window.title = (Main.appTitle + ' - ' + (FlxG.save.data.esp ? "Pausado" : "Paused"));

		FlxG.camera.zoom = FlxG.camera.zoom + 0.1;

		if (pauseMusic != null)
			pauseMusic.kill();
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		if (pauseMusic == null)
			add(pauseMusic);
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxTween.tween(pauseMusic, {volume: 0.75}, 2);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(10, FlxG.height - 25, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		#if cpp
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (60 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upP = gamepad.justPressed.DPAD_UP;
			downP = gamepad.justPressed.DPAD_DOWN;
			leftP = gamepad.justPressed.DPAD_LEFT;
			rightP = gamepad.justPressed.DPAD_RIGHT;
		}

		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		var songPath = 'assets/data/' + songLowercase + '/';

		if (upP)
		{
			changeSelection(-1);
   
		}else if (downP)
		{
			changeSelection(1);
		}
		
		#if cpp
			else if (leftP && canDoSomething)
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset -= 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

				// Prevent loop from happening every single time the offset changes
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = (FlxG.save.data.esp ? ['Reiniciar Cancion', (FlxG.save.data.botplay ? 'Desactivar Botplay' : 'Activar Botplay'), (FlxG.save.data.practice ? 'Desactivar Modo de Practica' : 'Activar Modo de Practica'), 'Opciones', 'Regresar al Menu'] : ['Restart Song', (FlxG.save.data.botplay ? 'Disable Botplay' : 'Enable Botplay'), (FlxG.save.data.practice ? 'Disable Practice Mode' : 'Enable Practice Mode'), 'Options', 'Exit to menu']);

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			}else if (rightP && canDoSomething)
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset += 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = (FlxG.save.data.esp ? ['Reiniciar Cancion', (FlxG.save.data.botplay ? 'Desactivar Botplay' : 'Activar Botplay'), (FlxG.save.data.practice ? 'Desactivar Modo de Practica' : 'Activar Modo de Practica'), 'Opciones', 'Regresar al Menu'] : ['Restart Song', (FlxG.save.data.botplay ? 'Disable Botplay' : 'Enable Botplay'), (FlxG.save.data.practice ? 'Disable Practice Mode' : 'Enable Practice Mode'), 'Options', 'Exit to menu']);

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			}
		#end

		if (accepted && canDoSomething)
		{
			canDoSomething = false;

			var daSelected:String = menuItems[curSelected];

			pauseMusic.kill();

			switch (daSelected)
			{
				//(FlxG.save.data.esp ? ['Resumir', 'Reiniciar Cancion', (FlxG.save.data.botplay ? 'Desactivar Botplay' : 'Activar Botplay'), (FlxG.save.data.practice ? 'Desactivar Modo de Practica' : 'Activar Modo de Practica'), 'Opciones', 'Regresar al Menu'] : 
				//['Resume', 'Restart Song', (FlxG.save.data.botplay ? 'Disable Botplay' : 'Enable Botplay'), (FlxG.save.data.practice ? 'Disable Practice Mode' : 'Enable Practice Mode'), 'Options', 'Exit to menu']);
				case "Resume" | "Resumir":

					var startTimer:FlxTimer;
					var swagCounter:Int = 0;
					
					var swagCounter:Int = 0;

				startTimer = new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{

					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3'), 0.6);
						case 1:
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/ready'));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.screenCenter();
							add(ready);

							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});

							FlxG.sound.play(Paths.sound('intro2'), 0.6);

						case 2:
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/set'));
							set.scrollFactor.set();
							set.screenCenter();
							add(set);
							
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});

							FlxG.sound.play(Paths.sound('intro1'), 0.6);

						case 3:
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/go'));
							go.scrollFactor.set();
							go.updateHitbox();
							go.screenCenter();
							add(go);

							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});

							FlxG.sound.play(Paths.sound('introGo'), 0.6);
						case 4:
							close();
					}

					swagCounter += 1;
				}, 5);

				case "Restart Song" | "Reiniciar Cancion":
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					FlxG.resetState();
				case "Enable Botplay" | "Disable Botplay" | "Activar Botplay" | "Desactivar Botplay":
					if (FlxG.save.data.botplay)
						FlxG.save.data.botplay = false;
					else
						FlxG.save.data.botplay = true;
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					
					FlxG.resetState();
				case "Enable Practice Mode" | "Disable Practice Mode" | "Activar Modo de Practica" | "Desactivar Modo de Practica":
					if (PlayState.storyDifficulty == 3)
						{
							pussyAlert();
						}
					else
						{
							if (FlxG.save.data.practice)
								FlxG.save.data.practice = false;
							else
								FlxG.save.data.practice = true;
							PlayState.SONG.speed = PlayState.originalSongSpeed;
							
							FlxG.resetState();
						}
				case "Options" | "Opciones":
					#if cpp
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					
					options = true;
					
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					FlxG.switchState(new menus.KindergartenOptions());
				case "Exit to menu" | "Regresar al Menu":
					#if cpp
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					FlxG.switchState(new menus.MainMenuState());
			}
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		if (!canDoSomething)
			return;

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function pussyAlert():Void
		{
			if (canDoSomething)
				canDoSomething = false;

			var quotes:Array<String> = [];
			if (FlxG.save.data.esp)
				quotes = ['Manco', 'Noob', 'Skill issue', 'Malo', 'Mejora', 'No bitches'];
			else
				quotes = ['Pussy', 'Noob', 'Skill issue', 'You suck', 'Git gud', 'No bitches'];

			FlxG.sound.play(Paths.sound('ohHellNo'), 1);

			new FlxTimer().start(0.55, function(tmr:FlxTimer)
			{
				//copypasted from creditsmenu lol
				var dumb:FlxSprite = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width * 0.6 + 50), Std.int(FlxG.height * 0.7), FlxColor.BLACK);
				dumb.alpha = 0.65;
				dumb.screenCenter();
				dumb.acceleration.y = FlxG.random.int(400, 500);
				add(dumb);

				var text:FlxText = new FlxText(0,0,0, quotes[FlxG.random.int(0, quotes.length - 1)], 80);
				text.scrollFactor.set();
				text.setFormat(null, 90, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.borderSize = 8;
				text.screenCenter();
				add(text);

				FlxTween.tween(dumb, {alpha: 0, angle: FlxG.random.float(2.5, -2.5)}, 1, {startDelay: 0.2, ease: FlxEase.expoOut});
				FlxTween.tween(text, {alpha: 0, angle: FlxG.random.int(5, -5), y: 375}, 1, {startDelay: 0.2, ease: FlxEase.expoOut, onComplete: function(_)
				{
					dumb.kill();
					text.kill();

					if (!canDoSomething)
						canDoSomething = true;
				}});
			});
		}
}