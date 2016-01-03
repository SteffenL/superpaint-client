package com.steffenl.superpaint.app.controls.toolstyle.generic {
import feathers.controls.Button;
import feathers.controls.ButtonGroup;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;

import org.osflash.signals.Signal;

import starling.events.Event;

public class ColorPicker extends LayoutGroup {
    public var styleChanged:Signal = new Signal(Number, Number);

    public function ColorPicker(color:uint, alpha:uint) {

    }

    protected override function initialize():void {
        super.initialize();

        // TODO: Implement color spectrum and custom colors

        layout = new VerticalLayout();

        var colorButtons:ButtonGroup = new ButtonGroup();
        colorButtons.layoutData = new HorizontalLayoutData();
        colorButtons.dataProvider = new ListCollection([
            { label: "Black", triggered: function(event:Event):void { colorButton_triggeredHandler(event, 0x000000, 0xff); } },
            { label: "Red", triggered: function(event:Event):void { colorButton_triggeredHandler(event, 0xff0000, 0xff); } },
            { label: "Green", triggered: function(event:Event):void { colorButton_triggeredHandler(event, 0x00ff00, 0xff); } },
            { label: "Blue", triggered: function(event:Event):void { colorButton_triggeredHandler(event, 0x0000ff, 0xff); } },
            { label: "White", triggered: function(event:Event):void { colorButton_triggeredHandler(event, 0xffffff, 0xff); } }
        ]);

        addChild(colorButtons);
    }

    private function colorButton_triggeredHandler(event:Event, color:Number, alpha:Number):void {
        styleChanged.dispatch(color, alpha);
    }
}
}
