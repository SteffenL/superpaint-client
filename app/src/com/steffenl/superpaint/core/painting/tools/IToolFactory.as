package com.steffenl.superpaint.core.painting.tools {

import com.steffenl.superpaint.core.painting.tools.ITool;

public interface IToolFactory {
    function create():Vector.<ITool>;
}
}
