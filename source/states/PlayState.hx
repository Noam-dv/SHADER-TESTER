package states;

import backend.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Constraints.FlatEnum;
import haxe.io.Path;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Label;
import haxe.ui.components.NumberStepper;
import haxe.ui.containers.ContinuousHBox;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ListView;
import haxe.ui.containers.TabView;
import haxe.ui.containers.VBox;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.xml.Access;
import lime.app.Application;
import math.Vectors.Vector2;
import sys.io.File;

using StringTools;

class PlayState extends FlxState
{
	private var shaders:Array<NShader> = [];
	private var list:ListView;
	private var shadersPage:ContinuousHBox;
	private var propertiesPage:ContinuousHBox;
	private var uniformsPage:ContinuousHBox;
	private var ui:TabView;

	var originalWidth:Int;
	var originalHeight:Int;

	// store future positions for sprites when dragging around
	var spriteTargets:Map<FlxSprite, SpriteTarget> = new Map<FlxSprite, SpriteTarget>();

	public var CAM_UI:FlxCamera;
	public var CAM_MAIN:FlxCamera;

	// array storing all sprites that can be dragged
	public var draggableObjects:Array<FlxSprite> = [];

	override public function create()
	{
		super.create();

		// initalize cameras
		CAM_UI = new FlxCamera();
		CAM_MAIN = new FlxCamera();
		CAM_UI.bgColor.alpha = 0;

		FlxG.cameras.reset(CAM_MAIN);
		FlxG.cameras.add(CAM_UI, false);

		// initialize shaders
		for (i in StupidUtil.readFolder("shaders"))
		{
			if (i.endsWith(".frag") || i.endsWith(".vert") || i.endsWith(".txt") || i.endsWith(".hx"))
			{
				NLogs.print(i);
				try
				{
					var s = new NShader(i.split(".")[0] /* REMOVES FILE EXTENSION */, sys.io.File.getContent(AssetPaths.shader(i)));
					s.setFloat('iTime', 0.0); // init dtime
					shaders.push(s);
				}
				catch (_)
				{
					var ERROR:FlxText = new FlxText(0, 0);
					ERROR.text = _.message;
					ERROR.color = FlxColor.RED;
					add(ERROR);
					ERROR.size *= 3;
					ERROR.screenCenter();
					ERROR.alignment = 'center';
					FlxTween.tween(ERROR, {alpha: 0}, 0.3, {
						ease: FlxEase.sineOut,
						startDelay: 1.5,
						onComplete: function(__)
						{
							ERROR.destroy();
						}
					});
				}
			}
		}

		// initialize UI and Store original window resolution into variable for the wdith and height thingys on the UI
		originalWidth = Application.current.window.width;
		originalHeight = Application.current.window.height;

		ui = new TabView();
		ui.setPosition(0, 0);
		ui.setSize(200, 250);
		ui.draggable = false;
		ui.padding = 5;
		ui.camera = CAM_UI;

		addTabs();
		addProperties();
		addShaders();
		add(ui);

		// initialize drag and dropping functionality
		FlxG.stage.window.onDropFile.add(function(path:String)
		{
			if (path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".jpeg"))
			{
				var bitmap:openfl.display.BitmapData = openfl.display.BitmapData.fromFile(path);
				var sprite:FlxSprite = new FlxSprite(0, 0, bitmap);
				sprite.updateHitbox();
				sprite.cameras = [CAM_MAIN];
				add(sprite);
				sprite.screenCenter();
				draggableObjects.push(sprite);
				spriteTargets.set(sprite, new SpriteTarget(new Vector2(0, 0), sprite));
			}
			else
				NLogs.print('[ERROR]: ASSET PATH \"${path}\" IS NOT AN IMAGE.', 'red');
		});
	}

	private inline function addTabs()
	{
		propertiesPage = new ContinuousHBox();
		propertiesPage.text = 'Properties';
		ui.addComponent(propertiesPage);
		shadersPage = new ContinuousHBox();
		shadersPage.text = 'Shaders';
		ui.addComponent(shadersPage);
		uniformsPage = new ContinuousHBox();
		uniformsPage.text = 'Uniform Variables';
	}

	private inline function addProperties()
	{
		if (propertiesPage == null)
			return;

		var vBox:VBox = new VBox();
		vBox.addComponent(FlxUIUtil.createLabelAndNumberStepper('Width', Math.POSITIVE_INFINITY, 0, 640, function(_:UIEvent)
		{
			originalWidth = Std.int(cast(_.target, NumberStepper).pos);
			reloadWindowSize();
		}));
		vBox.addComponent(FlxUIUtil.createLabelAndNumberStepper('Height', Math.POSITIVE_INFINITY, 0, 480, function(_:UIEvent)
		{
			originalHeight = Std.int(cast(_.target, NumberStepper).pos);

			reloadWindowSize();
		}));

		var checkBox:CheckBox = FlxUIUtil.createCheckBox('Drag UI', false);
		checkBox.onClick = function(_:MouseEvent)
		{
			ui.draggable = cast(_.target, CheckBox).selected;
		}
		vBox.addComponent(checkBox);

		var checkBox:CheckBox = FlxUIUtil.createCheckBox('Borderless Window', false);
		checkBox.onClick = function(_:MouseEvent)
		{
			Application.current.window.borderless = cast(_.target, CheckBox).selected;
		}
		vBox.addComponent(checkBox);

		for (option in ['Reset State', 'Save Shader Uniforms'])
		{
			switch (option)
			{
				case 'Reset Room':
					var button:Button = FlxUIUtil.createButton(option);
					button.onClick = (event:MouseEvent) -> FlxG.resetState();
					vBox.addComponent(button);
				case 'Save Shader Uniforms':
					var button:Button = FlxUIUtil.createButton(option);
					button.onClick = (event:MouseEvent) -> FlxG.resetState();
					vBox.addComponent(button);
			}
		}

		propertiesPage.addComponent(vBox);
	}

	private inline function reloadWindowSize()
	{
		Application.current.window.resize(originalWidth, originalHeight);
	}

	private inline function addShaders()
	{
		if (shadersPage == null)
			return;

		var vBox:VBox = new VBox();
		list = new ListView();
		list.setSize(100, 200);
		for (s in shaders)
			list.dataSource.add(s.name);

		list.onClick = function(_:MouseEvent)
		{
			var selectedShader = shaders[list.selectedIndex];
			displayUniforms(selectedShader);
			ui.addComponent(uniformsPage);
		}

		vBox.addComponent(list);
		shadersPage.addComponent(vBox);
	}

	var iTimeComponent:NumberStepper;

	private function displayUniforms(shader:NShader):Void
	{
		uniformsPage.removeAllComponents();
		var vBox:VBox = new VBox();

		for (uni in shader.getUniformVariables())
		{
			var uniformName:String = uni[0];
			var uniformType:Dynamic = uni[1];
			var component:Dynamic;

			switch (uniformType)
			{
				case Int:
					component = FlxUIUtil.createLabelAndNumberStepper(uniformName, Std.int(Math.POSITIVE_INFINITY), Std.int(Math.NEGATIVE_INFINITY), 0,
						function(_:UIEvent)
						{
							shader.setInt(uniformName, Std.int(cast(_.target, NumberStepper).pos));
							setShader();
						});
					shader.setInt(uniformName, 1);

					vBox.addComponent(component);
				case Float:
					component = FlxUIUtil.createLabelAndNumberStepper(uniformName, Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, 0, function(_:UIEvent)
					{
						shader.setFloat(uniformName, Std.int(cast(_.target, NumberStepper).pos));
						if (uniformName == "iTime")
							iTimeComponent = cast(_.target, NumberStepper);
						setShader();
					});
					shader.setFloat(uniformName, 1.0);

					vBox.addComponent(component);
				case Bool:
					component = FlxUIUtil.createCheckBox(uniformName, false);
					shader.setBool(uniformName, cast(component, CheckBox).selected);
					component.onClick = function(_:MouseEvent)
					{
						shader.setBool(uniformName, cast(_.target, CheckBox).selected);
						setShader();
					}
					vBox.addComponent(component);
			}
		}
		uniformsPage.addComponent(vBox);
	}

	public function setShader()
	{
		try
		{
			FlxG.camera.setFilters([new openfl.filters.ShaderFilter(shaders[list.selectedIndex])]);
		}
		catch (_)
		{
			var ERROR:FlxText = new FlxText(0, 0);
			ERROR.text = _.message;
			ERROR.color = FlxColor.RED;
			add(ERROR);
			ERROR.size *= 3;
			ERROR.screenCenter();
			ERROR.alignment = 'center';
			FlxTween.tween(ERROR, {alpha: 0}, 0.3, {
				ease: FlxEase.sineOut,
				startDelay: 1.5,
				onComplete: function(__)
				{
					ERROR.destroy();
				}
			});
		}
	}

	var elapsedTime:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		elapsedTime += elapsed;

		for (shader in shaders)
		{
			try
			{
				shader.setFloat("iTime", elapsedTime);
			}
			catch (e) {}
		}

		if (iTimeComponent != null)
		{
			try
			{
				iTimeComponent.pos = shaders[0].getFloat("iTime");
			}
		}

		handleDraggable(elapsed);
	}

	private function handleDraggable(elapsed:Float)
	{
		for (sprite in spriteTargets.keys())
		{
			var ov:FlxSprite = spriteTargets.get(sprite).sprite != null ? spriteTargets.get(sprite).sprite : sprite;
			var getter:SpriteTarget = spriteTargets.get(sprite);
			if (FlxG.mouse.pressed && FlxG.mouse.overlaps(ov) && !FlxG.mouse.overlaps(ui))
			{
				getter.position.x = FlxG.mouse.x;
				getter.position.y = FlxG.mouse.y;
				getter.scale.add(new Vector2(FlxG.mouse.wheel / 2, FlxG.mouse.wheel / 2));
			}
			// i just learnt lerp meant linear interpolation am i stupid gang
			ov.scale.x = ov.scale.y = flixel.math.FlxMath.lerp(ov.scale.x, getter.scale.x, elapsed * 7);
			ov.x = flixel.math.FlxMath.lerp(ov.x, spriteTargets.get(sprite).position.x - sprite.width / 2, elapsed * 10);
			ov.y = flixel.math.FlxMath.lerp(ov.y, spriteTargets.get(sprite).position.y - sprite.height / 2, elapsed * 10);
		}
	}
}
