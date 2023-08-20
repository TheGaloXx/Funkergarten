package data;

import flixel.FlxG;

class Ratings
{
    //a
    
    public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
    {
        var ranking:String = "N/A";
		if(data.KadeEngineData.botplay)
			ranking = "BotPlay";

        if (states.PlayState.misses == 0 && states.PlayState.bads == 0 && states.PlayState.shits == 0 && states.PlayState.goods == 0) // Marvelous (SICK) Full Combo
            ranking = "(MFC)";
        else if (states.PlayState.misses == 0 && states.PlayState.bads == 0 && states.PlayState.shits == 0 && states.PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
            ranking = "(GFC)";
        else if (states.PlayState.misses == 0) // Regular FC
            ranking = "(FC)";
        else if (states.PlayState.misses < 10) // Single Digit Combo Breaks
            ranking = "(SDCB)";
        else
            ranking = "(Clear)";

        // WIFE TIME :)))) (based on Wife3)

        var wifeConditions:Array<Bool> = [
            accuracy >= 99.9935, // AAAAA
            accuracy >= 99.980, // AAAA:
            accuracy >= 99.970, // AAAA.
            accuracy >= 99.955, // AAAA
            accuracy >= 99.90, // AAA:
            accuracy >= 99.80, // AAA.
            accuracy >= 99.70, // AAA
            accuracy >= 99, // AA:
            accuracy >= 96.50, // AA.
            accuracy >= 93, // AA
            accuracy >= 90, // A:
            accuracy >= 85, // A.
            accuracy >= 80, // A
            accuracy >= 70, // B
            accuracy >= 60, // C
            accuracy < 60 // D
        ];

        for(i in 0...wifeConditions.length)
        {
            var b = wifeConditions[i];
            if (b)
            {
                switch(i)
                {
                    case 0:
                        ranking += " AAAAA";
                    case 1:
                        ranking += " AAAA:";
                    case 2:
                        ranking += " AAAA.";
                    case 3:
                        ranking += " AAAA";
                    case 4:
                        ranking += " AAA:";
                    case 5:
                        ranking += " AAA.";
                    case 6:
                        ranking += " AAA";
                    case 7:
                        ranking += " AA:";
                    case 8:
                        ranking += " AA.";
                    case 9:
                        ranking += " AA";
                    case 10:
                        ranking += " A:";
                    case 11:
                        ranking += " A.";
                    case 12:
                        ranking += " A";
                    case 13:
                        ranking += " B";
                    case 14:
                        ranking += " C";
                    case 15:
                        ranking += " D";
                }
                break;
            }
        }

        if (accuracy == 0)
            ranking = "N/A";
		else if(data.KadeEngineData.botplay)
			ranking = "BotPlay";

        return ranking;
    }
    
    public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
    {

        var customTimeScale = funkin.Conductor.timeScale;

        if (customSafeZone != null)
            customTimeScale = customSafeZone / 166;

        // trace(customTimeScale + ' vs ' + funkin.Conductor.timeScale);

        // I HATE THIS IF CONDITION
        // IF LEMON SEES THIS I'M SORRY :(

        // trace('Hit Info\nDifference: ' + noteDiff + '\nZone: ' + funkin.Conductor.safeZoneOffset * 1.5 + "\nTS: " + customTimeScale + "\nLate: " + 155 * customTimeScale);

        if (data.KadeEngineData.botplay)
            return "sick"; // FUNNY
	
        var rating = checkRating(noteDiff,customTimeScale);

        return rating;
    }

    public static function checkRating(ms:Float, ts:Float)
    {
        var rating = "sick";
        if (ms <= 166 * ts && ms >= 135 * ts)
            rating = "shit";
        if (ms < 135 * ts && ms >= 90 * ts) 
            rating = "bad";
        if (ms < 90 * ts && ms >= 45 * ts)
            rating = "good";
        if (ms < 45 * ts && ms >= -45 * ts)
            rating = "sick";
        if (ms > -90 * ts && ms <= -45 * ts)
            rating = "good";
        if (ms > -135 * ts && ms <= -90 * ts)
            rating = "bad";
        if (ms > -166 * ts && ms <= -135 * ts)
            rating = "shit";
        return rating;
    }

    // cleaned it up for you since you wouldnt actually want to clean all of this
    public static function CalculateRanking(score:Int, scoreDef:Int, accuracy:Float):String
    {
        // score
        var scoreStr:String = Language.get('Ratings', 'score') + " " + (funkin.Conductor.safeFrames != 10 ? '$score ($scoreDef)' : '$score');

        var missStr:String = Language.get('Ratings', 'misses') + " " + '${states.PlayState.misses}';

        var retAcc:String = (data.KadeEngineData.botplay ? "N/A" : '${CoolUtil.truncateFloat(accuracy, 2)}%');
        var accStr:String = Language.get('Ratings', 'accuracy') + " " + retAcc;

        var endString:String = scoreStr + (data.KadeEngineData.settings.data.accuracyDisplay ? ' | $missStr | $accStr | ${GenerateLetterRank(accuracy)}' : '');

        return  (!data.KadeEngineData.botplay ? endString : "");
    }
}
