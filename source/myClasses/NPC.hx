package myClasses;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import myClasses.Pickup.PickupType;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.FlxG;

class NPC extends Human {
	var idleTimer:FlxTimer;

	var isUpFree:Bool;
	var isDownFree:Bool;
	var isLeftFree:Bool;
	var isRightFree:Bool;

	var viewLenght:Int;

	public var thanksText(default, null):FlxText;

	public function new() {
		super();

		idleTimer = new FlxTimer();

		thanksText = new FlxText(x, y, 0, "");
		thanksText.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 1);
		thanksText.alpha = 0;
	}

	override public function initialize(_x:Float, _y:Float, ?_sprite:String) {
		super.initialize(_x, _y, _sprite);

		isUpFree = true;
		isDownFree = true;
		isLeftFree = true;
		isRightFree = true;

		viewLenght = 100;
	}

	override function update(elapsed:Float) {
		idle();

		super.update(elapsed);
	}

	function idle() {
		if (!idleTimer.active) {
			idleTimer.start(FlxG.random.float(0, 3), MoveInRandomDirection);
		}
	}

	function MoveInRandomDirection(_) {
		var upTimer:FlxTimer = new FlxTimer();
		var downTimer:FlxTimer = new FlxTimer();
		var leftTimer:FlxTimer = new FlxTimer();
		var rightTimer:FlxTimer = new FlxTimer();

		var currXDir = FlxG.random.getObject(["left", "right"]);
		var currYDir = FlxG.random.getObject(["up", "down"]);
		if (!isLeftFree) {
			currXDir = "right";
		} else if (!isRightFree) {
			currXDir = "left";
		} else if (!isLeftFree && !isRightFree) {
			currXDir = "none";
		}
		if (!isUpFree) {
			currYDir = "down";
		} else if (!isDownFree) {
			currYDir = "up";
		} else if (!isUpFree && !isDownFree) {
			currYDir = "none";
		}

		var maxWalkTime:Float = FlxG.random.float(1, 6.5);
		if (FlxG.random.bool(30)) { // chance of running instead of walking
			running = true;
		}

		if (currXDir == "left") {
			left = true;
			leftTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				left = false;
				running = false;
			});
		} else if (currXDir == "right") {
			right = true;
			rightTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				right = false;
				running = false;
			});
		}
		if (currYDir == "up") {
			up = true;
			upTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				up = false;
				running = false;
			});
		} else if (currYDir == "down") {
			down = true;
			downTimer.start(FlxG.random.float(0, maxWalkTime), function(_) {
				down = false;
				running = false;
			});
		}
	}

	public function detectSurroundings(_tilemap:FlxTilemap) {
		if (_tilemap.ray(getPosition(), getPosition().add(viewLenght, 0))) {
			isRightFree = true;
		} else {
			isRightFree = false;
		}
		if (_tilemap.ray(getPosition(), getPosition().subtract(viewLenght, 0))) {
			isLeftFree = true;
		} else {
			isLeftFree = false;
		}
		if (_tilemap.ray(getPosition(), getPosition().add(0, viewLenght))) {
			isDownFree = true;
		} else {
			isDownFree = false;
		}
		if (_tilemap.ray(getPosition(), getPosition().subtract(0, viewLenght))) {
			isUpFree = true;
		} else {
			isUpFree = false;
		}
	}

	override function equipItem(_item:Item) {
		super.equipItem(_item);

		// npcs drop coins as thanks when receiving items
		var coinAmount = FlxG.random.int(1, 5);
		for (i in 0...coinAmount) {
			canPickUp = false;
			var newCoin = PlayState.pickups.recycle(Pickup.new);
			newCoin.initialize(x, y, PickupType.Coin);
			PlayState.pickups.add(newCoin);

			if (getPosition().distanceTo(PlayState.player.getPosition()) < 200) {
				FlxTween.tween(newCoin, {
					x: PlayState.player.getMidpoint().x,
					y: PlayState.player.getMidpoint().y
				}, 0.4);
			} else {
				var maxVel = 300;
				newCoin.velocity.set(FlxG.random.float(-maxVel, maxVel), FlxG.random.float(-maxVel, maxVel));
			}
		}
		var t = new FlxTimer().start(0.5, function(_) canPickUp = true);

		var randomThanks = FlxG.random.getObject([
			"Thanks.",
			"Thanks!",
			"Thank you",
			"Very good!",
			"Awesome!",
			"Thank you kind stranger",
			"Many thanks",
			"My day is better!",
			"thx m8",
			"Nice one",
			"Whatever...",
			"I didn't want this",
			"Have some gold in return",
			"Take this you nasty virus!"
		]);
		thanksText.setPosition(x, y - 15);
		thanksText.text = randomThanks;
		thanksText.alpha = 1;
		FlxTween.tween(thanksText, {
			alpha: 0
		}, 3);
	}
}
