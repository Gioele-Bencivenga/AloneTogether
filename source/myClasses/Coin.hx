package myClasses;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class Coin extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.coin__png, false, 8, 8);
	}

	override function kill() {
		alive = false;

		var randX = FlxG.random.int(-10, 10);
		var randY = FlxG.random.int(10, 20);

		FlxTween.tween(this, {alpha: 0, x: x + randX, y: y - randY}, 0.50, {ease: FlxEase.circOut, onComplete: function(_) exists = false});
	}
}
