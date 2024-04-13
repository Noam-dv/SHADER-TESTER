package states;

import backend.*;
import flixel.FlxCamera;
import flixel.FlxG;
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
import sys.io.File;

using StringTools;

class PlayState extends FlxState
{
	var shaders:Array<NShader> = [];
	var list:ListView;
	var shadersPage:ContinuousHBox;
	var propertiesPage:ContinuousHBox;
	var uniformsPage:ContinuousHBox;
	var ui:TabView;

	var originalWidth:Int;
	var originalHeight:Int;

	var CAM_UI:FlxCamera;
	var CAM_MAIN:FlxCamera;

	override public function create()
	{
		super.create();

		CAM_UI = new FlxCamera();
		CAM_MAIN = new FlxCamera();
		CAM_UI.bgColor.alpha = 0;

		FlxG.cameras.reset(CAM_MAIN);
		FlxG.cameras.add(CAM_UI, false);

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
	}
}
