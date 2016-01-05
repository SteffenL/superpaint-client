package com.steffenl.superpaint.core.painting {
import com.steffenl.superpaint.core.painting.tools.ITool;
import com.steffenl.superpaint.core.painting.tools.IToolFactory;

public interface IToolManager {
    function registerTools(reg:IToolFactory):void;
    function getTool(id:String):ITool;
    function getTools():Vector.<ITool>;
    function signals():ToolManagerSignals;
    function getActiveTool():ITool;
    function setActiveTool(id:String):void;
}
}
