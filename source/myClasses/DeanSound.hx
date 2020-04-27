package myClasses;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.system.FlxSoundGroup;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.system.FlxAssets.FlxSoundAsset;

// thanks a lot to @dean on the Haxe Discord for this fantastic function
class DeanSound {
	public static function playSound(sound:FlxSoundAsset, volume:Float = 1, ?target:FlxObject, ?player:FlxObject, ?range:Float, looped:Bool = false,
			?group:FlxSoundGroup, autoDestroy:Bool = true, ?onComplete:Void->Void):FlxSound {
		if (target == null || player == null) {
			return FlxG.sound.play(sound, volume, looped, group, autoDestroy, onComplete);
		}

		if (range == null)
			range = 100;

		var targetPoint = target.getMidpoint(FlxPoint.get());
		var playerPoint = player.getMidpoint(FlxPoint.get());
		var distance = playerPoint.distanceTo(targetPoint);

		if (distance > range) {
			targetPoint.put();
			playerPoint.put();

			if (onComplete != null)
				return FlxG.sound.play(sound, 0, looped, group, autoDestroy, onComplete);
			else
				return null;
		}

		var vol = FlxMath.bound(1 - (distance / range), 0, 1) * volume;
		var pan = FlxMath.bound(distance / range, 0, 1);

		if (playerPoint.x > targetPoint.x)
			pan = -pan;

		targetPoint.put();
		playerPoint.put();

		var soundObj = FlxG.sound.load(sound, vol, looped, group, autoDestroy, false, null, onComplete);

		soundObj.pan = pan;

		return soundObj.play(true);
	}
}
