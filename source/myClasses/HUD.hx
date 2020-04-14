package myClasses;

import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class HUD extends FlxTypedGroup<FlxSprite> {
	var background:FlxSprite;
	var backgroundHeight:Int;
	var backgroundColor:FlxColor;

	var dividerHeight:Int;
	var dividerColor:FlxColor;

	var txtHealth:FlxText;
	var txtInfected:FlxText;

	var healthBar:FlxBar;
	var barWidth:Int;

	var player:Player;
	var actors:FlxTypedGroup<Human>;

	var nOfInfected:Int;

	var refreshTimer:FlxTimer;

	public function new(_player:Player, _actors:FlxTypedGroup<Human>) {
		super();

		player = _player;
		actors = _actors;

		backgroundHeight = 40;
		backgroundColor = FlxColor.fromRGB(0, 0, 255, 110);
		dividerHeight = 2;
		dividerColor = FlxColor.fromRGB(0, 0, 255, 255);

		background = new FlxSprite(0, FlxG.height - backgroundHeight);
		background.makeGraphic(FlxG.width, backgroundHeight, backgroundColor);
		FlxSpriteUtil.drawRect(background, 0, 0, FlxG.width, dividerHeight, dividerColor);
		add(background);

		barWidth = 400;
		healthBar = new FlxBar((FlxG.width / 2) - (barWidth / 2), background.y + 7, LEFT_TO_RIGHT, barWidth, backgroundHeight - 10, player, 'health', 0,
			player.MAX_HEALTH, false);
		healthBar.createColoredEmptyBar(FlxColor.fromRGB(0, 0, 0, 140), true, dividerColor);
		healthBar.createColoredFilledBar(FlxColor.fromRGB(0, 175, 255, 170), true, dividerColor);
		add(healthBar);

		txtHealth = new FlxText((FlxG.width / 2) - 80, background.y + 5, 160, " ", 25);
		add(txtHealth);

		txtInfected = new FlxText(FlxG.width - 300, background.y + 5, 400, " ", 25);
		add(txtInfected);

		// we call the function on each element, by setting scrollFactor to 0,0 the elements won't scroll based on camera movements
		forEach(function(el:FlxSprite) {
			el.scrollFactor.set(0, 0);
		});

		/// REFRESH TIMER
		refreshTimer = new FlxTimer();
		refreshTimer.start(1, function(_) {
			updateInfectedNumber();
			updateHUD();
		}, 0);
	}

	public function updateHUD() {
		txtHealth.text = 'HP: ${player.health}/${player.MAX_HEALTH}';

		txtInfected.text = 'INFECTED: ${nOfInfected} / ${actors.countLiving()}'; // fix this
	}

	// need timer to run this function
	function updateInfectedNumber() {
		var i = 0;
		for (actor in actors) {
			if (actor.isInfected) {
				i++;
			}
		}
		nOfInfected = i;
	}
}
