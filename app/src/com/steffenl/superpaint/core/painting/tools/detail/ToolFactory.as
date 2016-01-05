package com.steffenl.superpaint.core.painting.tools.detail {
import com.steffenl.superpaint.core.painting.tools.ITool;
import com.steffenl.superpaint.core.painting.tools.IToolFactory;

public class ToolFactory implements IToolFactory {
    public function create():Vector.<ITool> {
        return new <ITool>[
            new PencilTool(),
            new FakeTool()
        ];
    }
}
}
