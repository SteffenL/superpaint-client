package com.steffenl.superpaint.app.controls.toolstyle.generic {
import feathers.controls.Callout;
import org.osflash.signals.Signal;

import starling.display.DisplayObject;

public class PopupColorPicker {
    public function get colorSelected():Signal {
        return _picker.colorSelected;
    }

    private var _picker:ColorPicker = new ColorPicker();
    private var _callout:Callout = null;

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
