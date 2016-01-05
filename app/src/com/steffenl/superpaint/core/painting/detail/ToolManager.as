package com.steffenl.superpaint.core.painting.detail {
import com.steffenl.superpaint.core.painting.IToolManager;
import com.steffenl.superpaint.core.painting.ToolManagerSignals;
import com.steffenl.superpaint.core.painting.tools.*;

import org.osflash.signals.Signal;

public class ToolManager implements IToolManager {
    private var _signals:ToolManagerSignals = new ToolManagerSignals();

    private var _tools:Object = {};
    private var _previousTool:ITool = null;
    private var _activeTool:ITool = null;

    public function ToolManager() {
    }

    public function registerTools(factory:IToolFactory):void {
        for each (var tool:ITool in factory.create()) {
            _registerTool(tool);
        }
    }

    public function getTool(id:String):ITool {
        if (!_tools.hasOwnProperty(id)) {
            throw new Error("Tool is not registered: " + id);
        }

        return _tools[id];
    }

    public function signals():ToolManagerSignals {
        return _signals;
    }

    public function getActiveTool():ITool {
        return _activeTool;
    }

    public function setActiveTool(id:String):void {
        /*if (_previousTool && _previousTool.getId() === id) {
            // Tool is already active
            return;
        }*/

        _previousTool = _activeTool;
        _activeTool = getTool(id);
        _signals.activeToolChanged.dispatch(_activeTool, _previousTool);
    }

    public function getTools():Vector.<ITool> {
        var result:Vector.<ITool> = new <ITool>[];
        for (var k:String in _tools) {
            result.push(_tools[k]);
        }

        return result;
    }

    private function _registerTool(tool:ITool):void {
        if (_tools.hasOwnProperty(tool.getId())) {
            throw new Error("Tool was already registered: " + tool.getId());
        }

        _tools[tool.getId()] = tool;
        signals().toolAdded.dispatch(tool);
    }
}
}
