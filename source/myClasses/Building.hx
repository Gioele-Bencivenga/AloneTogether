package myClasses;

import flixel.ui.FlxBar;
import myClasses.Pickup.PickupType;
import myClasses.Item.ItemType;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;

enum abstract BuildingType(Int) to Int {
	var Research = 0;
	var Pharmacy = 1;
}

class Building extends FlxSprite {
	var player:Player;

	public var type(default, null):BuildingType;

	var coinAmount:Int;
	var coinNeededForCure:Int;

	public var cureProgressBar(default, null):FlxBar;
	public var cureProgressText(default, null):FlxText;

	public var cureFound(default, null):Bool;

	var buildingName:String;

	public var titleText(default, null):FlxText; // text displaying the building's title

	var canInteract:Bool; // used to prevent multiple interaction with one button press

	var interactOptions:String;

	var proxTextXpos:Float; // used for displaying text on the right if research, left if pharmacy

	public var proximityText(default, null):FlxText; // text displayed when player is nearby
	public var isTextVisible(default, null):Bool;

	var textDissolver:FlxTimer; // after switching isTextVisible on the timer switches it off

	/// AUDIO
	var interactSuccSound:String;
	var interactFailSound:String;

	public function new(_x:Float, _y:Float, _type:BuildingType, _player:Player) {
		super(_x, _y);

		type = _type;
		player = _player;

		alpha = 0.001; // this object's sprite shouldn't be visible but setting this to 0 makes the hitbox disappear for some reason

		canInteract = true;
		coinAmount = FlxG.random.int(0, 20);
		coinNeededForCure = FlxG.random.int(130, 150);
		cureFound = false;

		textDissolver = new FlxTimer();

		/// BUILDING TITLE AND HITBOX
		makeGraphic(16, 16);
		switch type {
			case Research:
				buildingName = "RESEARCH CENTER";
				setSize(160, 130);

			case Pharmacy:
				buildingName = "PHARMACY";
				setSize(120, 140);
		}
		centerOffsets(true);
		titleText = new FlxText(x, y, 0, buildingName);
		titleText.setPosition((x + width / 2) - (titleText.width / 2), y + 10);
		titleText.setBorderStyle(OUTLINE_FAST, FlxColor.BROWN, 2);

		/// INTERACTION TEXT
		switch type {
			case Research:
				interactOptions = "Donate money to find a cure!\n\nPress [1] for 2 coins\nPress [2] for 10 coins\nPress [3] for 20 coins\nPress [4] for 30 coins";
				proxTextXpos = x + width;

			case Pharmacy:
				interactOptions = "Buy medical supplies!\n\nPress [1] for facemask (10 coins)\nPress [2] for gloves (3 coins)\nPress [3] for hand sanitizer (7 coins)\nPress [4] for paracetamol (4 coins)";
				proxTextXpos = x - width;
		}
		proximityText = new FlxText(proxTextXpos, y, 0, interactOptions);
		proximityText.setBorderStyle(OUTLINE_FAST, FlxColor.BLUE, 1);
		hideProximityText();

		/// PROGRESS BAR AND TEXT
		if (type == BuildingType.Research) {
			// bar
			cureProgressBar = new FlxBar(x, y, LEFT_TO_RIGHT, 120, 13, this, "coinAmount", 0, coinNeededForCure, true);
			cureProgressBar.setPosition((x + (width / 2)) - (cureProgressBar.width / 2), titleText.y + 15);
			cureProgressBar.createColoredEmptyBar(FlxColor.fromRGB(175, 50, 0, 250), true, FlxColor.ORANGE);
			cureProgressBar.createColoredFilledBar(FlxColor.fromRGB(200, 130, 0, 255), true, FlxColor.ORANGE);
			// text
			cureProgressText = new FlxText(x, y, 0, "cure progress");
			cureProgressText.setPosition((x + (width / 2)) - (cureProgressText.width / 2), cureProgressBar.y);
			cureProgressText.setBorderStyle(SHADOW, FlxColor.BLACK, 1);
		}

		/// AUDIO
		interactSuccSound = AssetPaths.interactionSuccess__wav;
		interactFailSound = AssetPaths.interactionFailed__wav;
	}

	public function showProximityText() {
		FlxTween.tween(proximityText, {alpha: 1}, 0.6, {
			onComplete: function(_) {
				isTextVisible = true;
				textDissolver.start(1, function(_) hideProximityText());
			}
		});
	}

	public function hideProximityText() {
		FlxTween.tween(proximityText, {alpha: 0}, 0.6, {onComplete: function(_) isTextVisible = false});
	}

	public function interact(_interactOption:Int) {
		if (canInteract) {
			canInteract = false;
			var t = new FlxTimer().start(0.2, function(_) canInteract = true);

			var interactSuccess:Bool = false;

			switch type {
				case Research:
					switch _interactOption {
						case 1:
							if (player.coinAmount >= 2) {
								player.loseCoins(2);
								gainCoins(2);

								interactSuccess = true;
							}
						case 2:
							if (player.coinAmount >= 10) {
								player.loseCoins(10);
								gainCoins(10);

								interactSuccess = true;
							}
						case 3:
							if (player.coinAmount >= 20) {
								player.loseCoins(20);
								gainCoins(20);

								interactSuccess = true;
							}
						case 4:
							if (player.coinAmount >= 30) {
								player.loseCoins(30);
								gainCoins(30);

								interactSuccess = true;
							}
					}

				case Pharmacy:
					switch _interactOption {
						case 1:
							if (player.coinAmount >= 10) {
								player.loseCoins(10);
								spitItem(ItemType.Mask);

								interactSuccess = true;
							}
						case 2:
							if (player.coinAmount >= 3) {
								player.loseCoins(3);
								spitItem(ItemType.Gloves);

								interactSuccess = true;
							}
						case 3:
							if (player.coinAmount >= 7) {
								player.loseCoins(7);
								spitItem(ItemType.Sanitizer);

								interactSuccess = true;
							}
						case 4:
							if (player.coinAmount >= 4) {
								player.loseCoins(4);
								spitPickup(PickupType.Paracetamol);

								interactSuccess = true;
							}
					}
			}

			if (interactSuccess) {
				DeanSound.playSound(interactSuccSound, 1, this, PlayState.player, 100);
			} else {
				DeanSound.playSound(interactFailSound, 1, this, PlayState.player, 100);
			}
		}
	}

	function gainCoins(_amount:Int) {
		coinAmount += _amount;

		if (coinAmount >= coinNeededForCure) {
			completeCure(_amount);
		}
	}

	function completeCure(_amountToSpit:Int) {
		cureFound = true;
		player.hasFoundCure = true;

		if (type == BuildingType.Research) {
			interactOptions = "A cure has been found!\nDeliver it to the denizens!\nKeep donating money to produce the cure for everyone!\nOne syringe delivered to all medical\ncenters for each coin donated.\n\nPress [1] for 2 coins\nPress [2] for 10 coins\nPress [3] for 20 coins\nPress [4] for 30 coins";
			proximityText.text = interactOptions;
		}

		for (building in PlayState.buildings) {
			for (i in 0..._amountToSpit) {
				building.spitItem(ItemType.Syringe);
			}
		}
	}

	function spitItem(_itemType:ItemType) {
		var newItem = PlayState.items.recycle(Item.new);
		newItem.initialize(getMidpoint().x - 8, y + 95, _itemType);
		newItem.velocity.set(FlxG.random.int(-200, 200), FlxG.random.int(50, 400));
		PlayState.items.add(newItem);
		PlayState.collidingObjects.add(newItem);
	}

	function spitPickup(_pickupType:PickupType) {
		var newPickup = PlayState.pickups.recycle(Pickup.new);
		newPickup.initialize(getMidpoint().x - 8, y + 95, _pickupType);
		newPickup.velocity.set(FlxG.random.int(-200, 200), FlxG.random.int(50, 300));
		PlayState.pickups.add(newPickup);
		PlayState.collidingObjects.add(newPickup);
	}
}
