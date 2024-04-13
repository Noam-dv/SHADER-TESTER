package backend;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import haxe.io.Path;
import haxe.ui.Toolkit;
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

class FlxUIUtil
{
	public static function createButton(text:String, ?backgroundColor:String):Button
	{
		var button:Button = new Button();
		button.text = text == null ? 'null' : text;

		if (backgroundColor != null)
			button.backgroundColor = backgroundColor;

		return button;
	}

	public static function createLabelAndNumberStepper(text:String, max:Float, min:Float, pos:Float, onChange:UIEvent->Void):HBox
	{
		var hBox:HBox = new HBox();

		var label:Label = new Label();
		label.text = text == null ? 'null' : text;
		label.verticalAlign = 'center';
		hBox.addComponent(label);

		var numberStepper:NumberStepper = new NumberStepper();
		numberStepper.max = max;
		numberStepper.min = min;
		numberStepper.pos = pos;

		if (onChange != null)
			numberStepper.onChange = onChange;

		hBox.addComponent(numberStepper);

		return hBox;
	}

	public static function createCheckBox(text:String, selected:Bool):CheckBox
	{
		var checkBox:CheckBox = new CheckBox();
		checkBox.text = text == null ? 'null' : text;
		checkBox.selected = selected;
		return checkBox;
	}

	public static function createTabView(x:Int = 0, y:Int = 0, width:Int = 250, height:Int = 200, draggable:Bool = false):TabView
	{
		var ui = new TabView();
		ui.setPosition(0, 0);
		ui.setSize(200, 250);
		ui.draggable = false;
		ui.padding = 5;
		return ui;
	}
}
