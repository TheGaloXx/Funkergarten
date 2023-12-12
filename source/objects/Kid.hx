package objects;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class KidBoyfriend extends FlxSprite
{
    public var canMove:Bool = true;
    private static inline final SPEED:Float = 500;

    var up:Bool = false;
    var down:Bool = false;
    var left:Bool = false;
    var right:Bool = false;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);
        
        frames = Paths.getSparrowAtlas('world_assets', 'preload');
        animation.addByIndices('idle', 'bf', [0,1,2,3,4,5,6,7], "", 24, true);
        animation.addByIndices('walk', 'bf', [9,10,11,12,13,14,15,16], "", 30, true);
        animation.play('idle');
        setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
        updateHitbox();
    }

    override function update(elapsed:Float)
        {
            //updateMovement();

            super.update(elapsed);

            oldInput();
        }
    
        // should i change this to controls movement or keep it with flixel
        function updateMovement() //code from the haxeflixel demo lol, https://github.com/HaxeFlixel/flixel-demos/blob/dev/Tutorials/TurnBasedRPG/source/Player.hx
        {
            if (!canMove)
                return;
            
            up = FlxG.keys.anyPressed([UP, W]);
            down = FlxG.keys.anyPressed([DOWN, S]);
            left = FlxG.keys.anyPressed([LEFT, A]);
            right = FlxG.keys.anyPressed([RIGHT, D]);
    
            if (up && down)
                up = down = false;
            if (left && right)
                left = right = false;
    
            if (up || down || left || right)
            {
                var newAngle:Float = 0;
                if (up)
                {
                    newAngle = -90;
                    if (left)
                        newAngle -= 45;
                    else if (right)
                        newAngle += 45;
                }
                else if (down)
                {
                    newAngle = 90;
                    if (left)
                        newAngle += 45;
                    else if (right)
                        newAngle -= 45;
                }
                else if (left)
                {
                    newAngle = 180;
                    facing = LEFT;
                }
                else if (right)
                {
                    newAngle = 0;
                    facing = RIGHT;
                }
    
                // determine our velocity based on angle and speed

                velocity.set(SPEED, 0);
                velocity.pivotDegrees(FlxPoint.weak(0, 0), newAngle);
            }
    
            var action = "idle";
            // check if the player is moving, and not walking into walls
            if (velocity.x != 0 || velocity.y != 0)
                action = "walk";
    
            animation.play(action);
        }

        function oldInput() //code from myself lol
        {
            if (!canMove)
                return;
            
            up = FlxG.keys.anyPressed([UP, W]);
            down = FlxG.keys.anyPressed([DOWN, S]);
            left = FlxG.keys.anyPressed([LEFT, A]);
            right = FlxG.keys.anyPressed([RIGHT, D]);

            if (up && down) up = down = false;
            if (left && right) left = right = false;

            if (right)
            {
                facing = RIGHT;
                velocity.x = SPEED;
            }
            else if (left)
            {
                facing = LEFT;
                velocity.x = -SPEED;
            }
            else
                velocity.x = 0;

            if (down)
                velocity.y = SPEED;
            else if (up)
                velocity.y = -SPEED;
            else
                velocity.y = 0;

            if (up || down || left || right)
                animation.play('walk');
            else
                animation.play('idle');
        }
}

class Kid extends FlxSprite
{
    public var indicator:FlxSprite;

    public function new(x:Float = 0, y:Float = 0, char:String)
    {
        super(x, y);
        
        frames = Paths.getSparrowAtlas('world_assets', 'preload');
        animation.addByIndices('idle', char, [0,1,2,3,4,5,6,7], "", 24, true);
        animation.play('idle');
        updateHitbox();
        immovable = true;
    }
}

class Indicator extends FlxSprite
{
    public function new(x:Float = 0, y:Float = 0)
        {
            super(x, y);
    
            frames = Paths.getSparrowAtlas('world_assets', 'preload');
            animation.addByPrefix('idle', 'indicator', 0, false);
            animation.play('idle');
            updateHitbox();
            visible = false;
            if (this != null)
                FlxTween.tween(this, {y: y - 35}, 0.45, {type: PINGPONG});
    
            immovable = true;
        }
}