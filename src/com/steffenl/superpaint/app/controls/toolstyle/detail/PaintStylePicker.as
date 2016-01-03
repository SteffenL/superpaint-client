package com.steffenl.superpaint.app.controls.toolstyle.detail {
import com.steffenl.superpaint.app.controls.toolstyle.generic.ColorPicker;
import com.steffenl.superpaint.app.controls.toolstyle.generic.StrokeStylePicker;
import com.steffenl.superpaint.core.painting.detail.PaintStyles;

import feathers.controls.Button;

import feathers.controls.LayoutGroup;
import feathers.layout.VerticalLayout;

import org.osflash.signals.Signal;

import starling.events.Event;

public class PaintStylePicker extends LayoutGroup {
    public var done:Signal = new Signal();

    private var _paintStyles:PaintStyles;

    public function PaintStylePicker(paintStyles:PaintStyles) {
        _paintStyles = paintStyles;
    }

    protected override function initialize():void {
        super.initialize();

        layout = new VerticalLayout();

        const strokeStylePicker:StrokeStylePicker = new StrokeStylePicker(_paintStyles.strokeWidth);
        strokeStylePicker.styleChanged.add(function(strokeWidth:Number):void {
            _paintStyles.strokeWidth = strokeWidth;
        });
        addChild(strokeStylePicker);

        const colorPicker:ColorPicker = new ColorPicker(_paintStyles.strokeColor, _paintStyles.strokeAlpha);
        colorPicker.styleChanged.add(function(color:uint, alpha:uint):void {
            _paintStyles.strokeColor = color;
            _paintStyles.strokeAlpha = alpha;
        });
        addChild(colorPicker);

        const doneButton:Button = new Button();
        doneButton.label = "Done";
        doneButton.addEventListener(Event.TRIGGERED, doneButton_triggeredHandler);
        addChild(doneButton);
    }

    private function doneButton_triggeredHandler(event:Event):void {
        done.dispatch();
    }
}
}
