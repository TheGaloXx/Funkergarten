package substates;

import flixel.FlxBasic;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;


using StringTools;

//a

class ResultsScreen extends FlxSubState
{
    public var background:FlxSprite;
    public var text:FlxText;

    public var anotherBackground:FlxSprite;

    public var comboText:FlxText;
    public var contText:FlxText;
    public var settingsText:FlxText;

    public var ranking:String;
    public var accuracy:String;

	override function create()
	{	
        Application.current.window.title = (Main.appTitle + (FlxG.save.data.esp ? ' - Pantalla de Resultados' : ' - Results Screen'));

        FlxG.camera.zoom = FlxG.camera.zoom + 0.1;

        background = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        background.scrollFactor.set();
        add(background);

        background.alpha = 0;

        text = new FlxText(50,-55,0,(FlxG.save.data.esp ? "Cancion Completada!" : "Song Cleared!"));
        text.size = 34;
        text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        text.color = FlxColor.WHITE;
        text.scrollFactor.set();
        add(text);

        var score = PlayState.instance.songScore;
        if (PlayState.isStoryMode)
        {
            score = PlayState.campaignScore;
            text.text = (FlxG.save.data.esp ? "Semana Completada!" : "Week Cleared!");
        }
        
        comboText = new FlxText(50,-75,0, (FlxG.save.data.esp ? '\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\n\nFallos: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nMayor Combo: ${PlayState.highestCombo + 1}\n\nPuntaje: ${PlayState.instance.songScore}\nPrecision: ${HelperFunctions.truncateFloat(PlayState.instance.accuracy,2)}%\nIntentos: ' + FlxG.save.data.tries + '\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\n\nF2 - Repetir Cancion' : '\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\n\nScore: ${PlayState.instance.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.instance.accuracy,2)}%\nTries: ' + FlxG.save.data.tries + '\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\n\nF2 - Replay song'));
        comboText.size = 28;
        comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        comboText.color = FlxColor.WHITE;
        comboText.scrollFactor.set();
        add(comboText);
        contText = new FlxText(FlxG.width - 550,FlxG.height + 100,0, (FlxG.save.data.esp ? 'Presiona ${KeyBinds.gamepad ? 'A' : 'ENTER'} para continuar.' : 'Press ${KeyBinds.gamepad ? 'A' : 'ENTER'} to continue.'));
        contText.size = 28;
        contText.alignment = RIGHT;
        contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        contText.color = FlxColor.WHITE;
        contText.scrollFactor.set();
        add(contText);

        anotherBackground = new FlxSprite(FlxG.width - 500,45).makeGraphic(450,240,FlxColor.BLACK);
        anotherBackground.scrollFactor.set();
        anotherBackground.alpha = 0;
        add(anotherBackground);


        var sicks = HelperFunctions.truncateFloat(PlayState.sicks / PlayState.goods,1);
        var goods = HelperFunctions.truncateFloat(PlayState.goods / PlayState.bads,1);

        if (sicks == Math.POSITIVE_INFINITY)
            sicks = 0;
        if (goods == Math.POSITIVE_INFINITY)
            goods = 0;

        var mean:Float = 0;

        settingsText = new FlxText(20,FlxG.height + 50,0,'Ratio (SA/GA): ${Math.round(sicks)}:1 ${Math.round(goods)}:1 | Mean: ${mean}ms | Played on ${PlayState.SONG.song} ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
        settingsText.size = 16;
        settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
        settingsText.color = FlxColor.WHITE;
        settingsText.scrollFactor.set();
        add(settingsText);


        FlxTween.tween(background, {alpha: 0.6},0.25);
        FlxTween.tween(text, {y:20},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(contText, {y:FlxG.height - 45},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(settingsText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(anotherBackground, {alpha: 0.6}, 0.5);

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        FlxG.save.data.tries = 0;

		super.create();
	}


    var frames = 0;

	override function update(elapsed:Float)
	{
        if (PlayerSettings.player1.controls.ACCEPT)
        {
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            if (PlayState.isStoryMode)
            {
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                FlxG.switchState(new menus.MainMenuState());
            }
            else{
                FlxG.switchState(new menus.FreeplayState());
            }
        }

        if (FlxG.keys.justPressed.F2 )
        {
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            var songFormat = StringTools.replace(PlayState.SONG.song, " ", "-");
            switch (songFormat) {
                case 'Dad-Battle': songFormat = 'Dadbattle';
                case 'Philly-Nice': songFormat = 'Philly';
                case 'dad-battle': songFormat = 'Dadbattle';
                case 'philly-nice': songFormat = 'Philly';
            }

            var poop:String = Highscore.formatSong(songFormat, PlayState.storyDifficulty);

            PlayState.SONG = Song.loadFromJson(poop, PlayState.SONG.song);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = PlayState.storyDifficulty;
            PlayState.storyWeek = 0;
            LoadingState.loadAndSwitchState(new PlayState());
        }

		super.update(elapsed);
	}
}
