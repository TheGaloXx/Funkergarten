package data;

import states.PlayState;
using StringTools;

class FCs
{
	public static var fcedSongs:Map<String, Bool> = new Map();

    public static inline function save():Void
    {
        if (PlayState.storyDifficulty != 2 || KadeEngineData.botplay || KadeEngineData.practice)
            return;

        final song = CoolUtil.normalize(PlayState.SONG.song);

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

        KadeEngineData.other.data.fcedSongs = fcedSongs;
        KadeEngineData.flush();
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
        if (KadeEngineData.other.data.fcedSongs != null)
			fcedSongs = KadeEngineData.other.data.fcedSongs;
    }

    public static function fullFC():Bool
    {
        if (!KadeEngineData.other.data.beatedMod || KadeEngineData.other.data.fcedSongs == null)
            return false;

        final songs:Array<String> = ['monday', 'nugget', 'staff-only', 'cash-grab', 'expelled', 'expelled-v1', 'expelled-v2', 'monday-encore', 'nugget-de-polla'];
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

        for (song in songs)
        {
            if (!dumbSongs.contains(song))
            {
                return false;
            }
        }

        return true;
    }
}
