package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

// ALL OF THIS CLASS IS COPIED FROM OTHER LITTLE PROJECT THAT I MADE - galo

class EventAdding extends flixel.FlxSubState
{
    var inputs:Array<flixel.addons.ui.FlxUIInputText> = [];

	public function new(finishThing:Void->Void)
	{
		super();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xff000000);
        bg.alpha = 0.75;
		bg.active = false;
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		var indicator = new FlxText(0, 5, FlxG.width, Language.get('EventSubstate', 'indicator_text'), 24 * 2);
		indicator.autoSize = false;
		indicator.setFormat(null, 24 * 2, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		indicator.screenCenter();
		indicator.y -= 150;
		indicator.borderSize = 2;
		indicator.active = false;
		indicator.scrollFactor.set();
		add(indicator);

		for (i in 0...3)
		{
			var daX = (250 * (i + 1)) + 70;

			var xd = "";
			switch (i)
			{
				case 0:
					xd = "Name:";
				case 1:
					xd = "Value 1:";
				case 2:
					xd = "Value 2:";
				default:
					break;
			}

			var daText = new FlxText(daX - 70, 0, 0, xd, 48);
			daText.setFormat(null, 48, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
			daText.screenCenter(Y);
			daText.borderSize = 2;
			daText.active = false;
			daText.y += 100;
			daText.scrollFactor.set();
			add(daText);

			var txt = new flixel.addons.ui.FlxUIInputText(daX, 0, 150, "", 48, 0x00000000);
			txt.screenCenter(Y);
			txt.scrollFactor.set();
			add(txt);
			inputs.push(txt);
		}

		var cancel = new FlxButton(5, 5, Language.get('EventSubstate', 'cancel_btn'), function()
		{
			close();
		});
		cancel.scale.set(2, 2);
		cancel.label.scale.set(2, 2);
		cancel.label.updateHitbox();
		cancel.updateHitbox();
		cancel.scrollFactor.set();
		add(cancel);

		var addEvent = new FlxButton(180, FlxG.height - 100, Language.get('EventSubstate', 'add_btn'), function()
		{
			var errors:Int = 0;

			var _a:String = null;
			var _b:String = null;
			var _c:String = null;

			for (i in 0...inputs.length)
			{
				if (inputs[i].text == null || inputs[i].text == "")
				{
                    lime.app.Application.current.window.alert('Error.', "Error!");
					errors++;
					break;
				}
				else
				{
					switch (i)
					{
						case 0:
							_a = inputs[i].text;
						case 1:
							_b = inputs[i].text;
						case 2:
							_c = inputs[i].text;
						default:
							trace("What");
					}
				}
			}

			trace("Errors: " + errors + ".");

			if (errors <= 0)
			{
				var info:Array<String> = [_a, _b, _c];

				ChartingState.eventData = info;
				trace(ChartingState.eventData);

				close();
				finishThing();
			}
			else
				close();
		});
		addEvent.screenCenter(X);
		addEvent.label.screenCenter(X);
		addEvent.scale.set(2, 2);
		addEvent.label.scale.set(2, 2);
		addEvent.label.updateHitbox();
		addEvent.updateHitbox();
		addEvent.scrollFactor.set();
		add(addEvent);
	}
}
