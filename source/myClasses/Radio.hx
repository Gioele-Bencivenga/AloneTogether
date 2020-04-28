package myClasses;

import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

class Radio extends FlxSprite {
	var track1:String;
	var track2:String;
	var track3:String;

	var track1Sound:FlxSound;
	var track2Sound:FlxSound;
	var track3Sound:FlxSound;

	var trackPlaying:Int;

	var musicVolume:Float;

	public var proximityText(default, null):FlxText; // text displayed when player is nearby
	public var isTextVisible(default, null):Bool;

	var textDissolver:FlxTimer; // after switching isTextVisible on the timer switches it off

	public function new(_x:Float, _y:Float) {
		super(_x, _y);

		textDissolver = new FlxTimer();

		loadGraphic(AssetPaths.radio__png);
		setSize(30, 30);
		centerOffsets();

		track1 = FlxG.random.getObject([
			AssetPaths.achaidh_cheide_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.acid_trumpet_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.b_roll_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.carpe_diem_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.clear_air_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.cold_funk_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.feelin_good_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.somewhere_sunny_ver_2_by_kevin_macleod_from_filmmusic_io__mp3,
			AssetPaths.wallpaper_by_kevin_macleod_from_filmmusic_io__mp3
		]);

		var hasToPickAnother = true;
		while (hasToPickAnother) {
			track2 = FlxG.random.getObject([
				AssetPaths.achaidh_cheide_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.acid_trumpet_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.b_roll_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.carpe_diem_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.clear_air_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.cold_funk_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.feelin_good_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.somewhere_sunny_ver_2_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.wallpaper_by_kevin_macleod_from_filmmusic_io__mp3
			]);

			if (track2 != track1) {
				hasToPickAnother = false;
			}
		}

		hasToPickAnother = true;
		while (hasToPickAnother) {
			track3 = FlxG.random.getObject([
				AssetPaths.achaidh_cheide_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.acid_trumpet_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.b_roll_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.carpe_diem_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.clear_air_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.cold_funk_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.feelin_good_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.somewhere_sunny_ver_2_by_kevin_macleod_from_filmmusic_io__mp3,
				AssetPaths.wallpaper_by_kevin_macleod_from_filmmusic_io__mp3
			]);

			if (track3 != track2 && track3 != track1) {
				hasToPickAnother = false;
			}
		}

		track1Sound = FlxG.sound.load(track1, 0);
		track1Sound.onComplete = playTrack2;
		track2Sound = FlxG.sound.load(track2, 0);
		track2Sound.onComplete = playTrack3;
		track3Sound = FlxG.sound.load(track3, 0);
		track3Sound.onComplete = playTrack1;

		musicVolume = 0.5;
		playTrack1();

		/// TEXT
		proximityText = new FlxText(x, y, 0, "[E] to change song");
		proximityText.setPosition(getGraphicMidpoint().x - (proximityText.width / 2), y - FlxG.random.int(10, 50));
		proximityText.setBorderStyle(SHADOW, FlxColor.ORANGE, 1);
		proximityText.shadowOffset.set(-1, 1);
		hideProximityText();
	}

	function playTrack1() {
		track1Sound.play(true).fadeIn(0.5, 0, musicVolume).proximity(x, y, PlayState.player, 500);
		trackPlaying = 1;
	}

	function playTrack2() {
		track2Sound.play(true).fadeIn(0.5, 0, musicVolume).proximity(x, y, PlayState.player, 500);
		trackPlaying = 2;
	}

	function playTrack3() {
		track3Sound.play(true).fadeIn(0.5, 0, musicVolume).proximity(x, y, PlayState.player, 500);
		trackPlaying = 3;
	}

	public function interact() {
		if (trackPlaying == 1) {
			track1Sound.stop();
			playTrack2();
		} else if (trackPlaying == 2) {
			track2Sound.stop();
			playTrack3();
		} else if (trackPlaying == 3) {
			track3Sound.stop();
			playTrack1();
		}
	}

	public function showProximityText() {
		FlxTween.tween(proximityText, {alpha: 1}, 0.6, {
			onComplete: function(_) {
				isTextVisible = true;
				textDissolver.start(0.5, function(_) hideProximityText());
			}
		});
	}

	public function hideProximityText() {
		FlxTween.tween(proximityText, {alpha: 0}, 0.6, {onComplete: function(_) isTextVisible = false});
	}
}
