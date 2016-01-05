package com.steffenl.superpaint.app.controls.features {

import feathers.controls.*;
import feathers.events.FeathersEventType;

import starling.events.Event;

/**
 * A feature that adds support for a tooltip for a button.
 * The tooltip is shown when the button has been pressed down for a "long" time.
 *
 * Add public get/set accessors in the composed class like this:
 * public function get tooltip():String { return _tooltipFeature.getTooltip(); }
 * public function set tooltip(value:String):void { _tooltipFeature.setTooltip(value); }
 */
public class ButtonTooltipFeature {
    public function ButtonTooltipFeature(base:Button) {
        base.isLongPressEnabled = true;
        base.addEventListener(FeathersEventType.LONG_PRESS, longPressHandler);
    }

    private var _tooltipText:String;

    public function setTooltip(text:String):void {
        _tooltipText = text;
    }

    public function getTooltip():String {
        return _tooltipText;
    }

    private function longPressHandler(event:Event):void {
        if (!_tooltipText) {
            return;
        }

        var button:Button = Button(event.currentTarget);
        // Note: Reusing the label here causes the text to disappear, so create a new one every time
        var label:Label = new Label();
        label.text = _tooltipText;
        Callout.show(label, button);
    }
}
}
