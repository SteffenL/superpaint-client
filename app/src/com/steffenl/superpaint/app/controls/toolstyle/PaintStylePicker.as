package com.steffenl.superpaint.app.controls.toolstyle {
import com.steffenl.superpaint.app.controls.toolstyle.detail.*;
import com.steffenl.superpaint.app.controls.toolstyle.detail.ColorPicker;
import com.steffenl.superpaint.app.controls.toolstyle.detail.StrokeStylePicker;
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

        const strokeStylePicker:StrokeStylePicker = new StrokeStylePicker(_paintStyles.strokeWidth, _paintStyles.strokeColor, _paintStyles.strokeAlpha);
        strokeStylePicker.styleChanged.add(function(strokeWidth:Number):void {
            _paintStyles.strokeWidth = strokeWidth;
        });
        addChild(strokeStylePicker);

        const colorPicker:ColorPicker = new ColorPicker(_paintStyles.strokeColor, _paintStyles.strokeAlpha);
        colorPicker.styleChanged.add(function(color:uint, alpha:uint):void {
            _paintStyles.strokeColor = color;
            _paintStyles.strokeAlpha = alpha;
            strokeStylePicker.setColor(color, alpha);
        });
        addChild(colorPicker);
    }
}
}
