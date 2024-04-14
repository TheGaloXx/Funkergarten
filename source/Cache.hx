package;

import openfl.Assets;
import flixel.FlxG;

using StringTools;

// No this isn't gonna be a super complex cache system class, im way too dumb and lazy to do that

class Cache
{
    inline public static function remove(path:String, library:Libraries):Void
    {
        final graphic = FlxG.bitmap.get(Paths.image(path, Std.string(library)));

        if (graphic != null)
            FlxG.bitmap.remove(graphic);
        else
            trace('$path is null!');
    }

    inline public static function uncachCharacters():Void
    {
        var characters:Int = 0;

        @:privateAccess
        for (key => i in FlxG.bitmap._cache)
        {
            // trace(key, key.contains('characters'));

            if (!key.contains('characters'))
                continue;
            else
                characters++;

            final graphic = FlxG.bitmap.get(key);

            if (graphic != null)
            {
                if (graphic.persist)
                    continue;

                FlxG.bitmap.remove(graphic);
            }
            else
                trace('$key is null!');
        }

        if (characters > 0) trace('Cleaned $characters character sprites from the cache.');
    }

    inline public static function check():Void
    {
        /*
        @:privateAccess
		for (key => i in FlxG.bitmap._cache)
		{
			trace("Cache key: " + key);
		}
        */
    }

    inline public static function length():Void
    {
        var length:Int = 0;

        @:privateAccess
		for (key => i in FlxG.bitmap._cache)
		{
			length++;
		}

        trace('Cached assets: $length.');
    }

    inline public static function clear():Void
    {
        check();

        var lol = false;
        if (lol)
        {
            length();

            @:privateAccess
            for (key => i in FlxG.bitmap._cache)
            {
                final graphic = FlxG.bitmap.get(key);

                if (graphic != null)
                {
                    // if (!graphic.persist && graphic.destroyOnNoUse)
                        FlxG.bitmap.remove(graphic);
                }
                else
                    trace('$key is null!');
            }

            length();
        }
    }
}

enum Libraries
{
    DEFAULT;
    PRELOAD;
    SHARED;
}