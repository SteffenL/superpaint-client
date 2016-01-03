package com.steffenl.superpaint.app.controls.toolstyle.generic {

import feathers.controls.Callout;
import org.osflash.signals.Signal;

import starling.display.DisplayObject;

public class PopupStrokeStylePicker {
    public function get widthChanged():Signal {
        return _picker.widthChanged;
    }

    public function get widthChanging():Signal {
        return _picker.widthChanging;
    }

    private var _picker:StrokeStylePicker;
    private var _callout:Callout = null;

    public function PopupStrokeStylePicker(initialWidth:Number) {
        _picker = new StrokeStylePicker(initialWidth);
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
