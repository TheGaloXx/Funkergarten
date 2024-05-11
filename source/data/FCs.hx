package data;

import states.PlayState;
using StringTools;

class FCs
{
	public static var fcedSongs:Map<String, Bool> = new Map();

    public static inline function save():Void
    {
        if (PlayState.storyDifficulty != 2 || GlobalData.botplay || GlobalData.practice)
            return;

        final song = CoolUtil.normalize(PlayState.SONG.name);

        if (fcedSongs.exists(song))
		{
            trace('Song exists in the FC map.');

			if (fcedSongs.get(song) != true)
			{
                trace('Song is not set as fced in the FC map.');

                if (PlayState.scoreData.misses <= 0)
                {
                    trace('You FCed the song.');
                    fcedSongs.set(song, true);
                }
                else
                {
                    trace('You did not FC the song.');
                    fcedSongs.set(song, false);
                }
            }
            else
            {
                trace("You have already FC'ed " + song + "!");
            }
		}
		else
		{
            trace('Song does not exist in the FC map.');

            if (PlayState.scoreData.misses <= 0)
            {
                trace('You FCed the song.');
                fcedSongs.set(song, true);
            }
            else
            {
                trace('You did not FC the song.');
                fcedSongs.set(song, false);
            }
        }

        GlobalData.other.fcedSongs = fcedSongs;
        GlobalData.flush();
    }

    public static inline function check(song:String):Bool
    {
        song = CoolUtil.normalize(song);

        if (fcedSongs.exists(song) && fcedSongs.get(song))
            return true;

        return false;
    }

    public static inline function init():Void
    {
        if (GlobalData.other.fcedSongs != null)
			fcedSongs = GlobalData.other.fcedSongs;
    }

    public static function fullFC():Bool
    {
        if (!GlobalData.other.beatenStoryMode || GlobalData.other.fcedSongs == null)
            return false;

        final dumbSongs:Array<String> = [];

        for (key => i in fcedSongs)
        {
            if (!i)
            {
                return false;
            }
            else
            {
                dumbSongs.push(key);
            }
        }

        for (song in GlobalData.allSongs)
        {
            song = CoolUtil.normalize(song);

            if (!dumbSongs.contains(song))
            {
                return false;
            }
        }

        return true;
    }
}
