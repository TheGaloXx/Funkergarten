package objects;

import flixel.FlxSprite;

class Sackboy extends FlxSprite
{
    public function new(boyfriend:Boyfriend)
    {
        super(boyfriend.x + boyfriend.width + 70, boyfriend.y + boyfriend.height - 370);

        frames = Paths.getSparrowAtlas('bg/sackboy', 'shit');
        animation.addByPrefix('idle', 'sackboy', 24);
        animation.play('idle');
        antialiasing = false;
        setGraphicSize(370, 370);
        updateHitbox();
    }

    override function update(elapsed:Float):Void
    {
        updateAnimation(elapsed);
    }
}