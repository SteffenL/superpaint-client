package com.steffenl.superpaint.app.controls.toolstyle.detail {

import com.steffenl.superpaint.core.painting.detail.PaintStyles;

import feathers.controls.Callout;

import feathers.controls.LayoutGroup;

import org.osflash.signals.Signal;

import starling.display.DisplayObject;

public class PopupPenStylePicker extends LayoutGroup {
    public function get done():Signal {
        return _picker.done;
    }

    private var _picker:PaintStylePicker;
    private var _callout:Callout = null;

    public function PopupPenStylePicker(paintStyles:PaintStyles) {
        _picker = new PaintStylePicker(paintStyles);
        _picker.done.add(function():void {
            close();
        });
    }

    public function show(origin:DisplayObject):void {
        if (!_callout) {
            _callout = Callout.show(_picker, origin);
        }
        else {
            _callout.visible = true;
        }
    }

    public function close(dispose:Boolean = false):void {
        if (_callout) {
            _callout.close(dispose);
        }
    }
}
}
