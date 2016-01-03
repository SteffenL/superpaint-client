package com.steffenl.superpaint.core.document {
import org.osflash.signals.Signal;

/* TODO: Save state to long-term storage medium to...
     - Save memory.
     - Recovery after a crash.
*/
public class DocumentStateManager {
    private static const MAX_STATE_HISTORY:uint = 50;

    //public var added:Signal = new Signal();
    //public var stepped:Signal = new Signal();
    public var stateChanged:Signal = new Signal(DocumentState);

    private var _history:Vector.<DocumentState> = new <DocumentState>[];
    private var _historyIndex:int = -1;

    /**
     * Gets the number of entries of histories currently managed.
     * @return Number of history entries.
     */
    public function getHistoryLength():uint {
        return _history.length;
    }

    /**
     * Pushes an entry into the state history, forgetting any future history relative to the current index.
     * @return Current history index.
     */
    public function push(state:DocumentState):void {
        const numEntriesInFront:int = _history.length - (_historyIndex + 1);
        if (numEntriesInFront > 0) {
            _forgetFuture(_historyIndex + 1);
        }

        const numEntriesBehind:int = _historyIndex;
        if (numEntriesBehind > MAX_STATE_HISTORY) {
            _forgetPast(_historyIndex);
        }

        _history.push(state);
        ++_historyIndex;
        //added.dispatch();
        stateChanged.dispatch(getState());
    }

    public function getState():DocumentState {
        if (!hasState()) {
            throw new Error("There is no current state");
        }

        return _history[_historyIndex];
    }

    public function hasState():Boolean {
        return _history.length > 0 && _historyIndex >= 0 && _historyIndex < _history.length;
    }

    public function hasPast():Boolean {
        return _historyIndex > 0;
    }

    public function hasFuture():Boolean {
        return (_historyIndex + 1) < _history.length;
    }

    /**
     * Step backward in history while preserving future history.
     */
    public function stepBackward():void {
        if (!hasPast()) {
            throw new Error("No earlier history exists");
        }

        --_historyIndex;
        //stepped.dispatch();
        stateChanged.dispatch(getState());
    }

    /**
     * Step forward in history while preserving past history.
     */
    public function stepForward():void {
        if (!hasFuture()) {
            throw new Error("No later history exists");
        }

        ++_historyIndex;
        //stepped.dispatch();
        stateChanged.dispatch(getState());
    }

    /**
     * Forgets all future history from the specified index.
     * @param fromIndex
     */
    private function _forgetFuture(fromIndex:int):void {
        _validateHistoryIndex(fromIndex);
        const lastIndex:int = _history.length;
        const numEntriesToForget:int = lastIndex - fromIndex;
        if (numEntriesToForget > 0) {
            _history.splice(fromIndex, numEntriesToForget);
        }
    }

    /**
     * Forgets all past history until the specified index (exclusive).
     * @param untilIndex
     */
    private function _forgetPast(untilIndex:int):void {
        _validateHistoryIndex(untilIndex);
        const fromIndex:int = 0;
        const numEntriesToForget:int = (untilIndex - 1) - fromIndex;
        if (numEntriesToForget > 0) {
            _history.splice(fromIndex, numEntriesToForget);
        }
    }

    private function _validateHistoryIndex(index:int):void {
        if (index < 0 || index >= _history.length) {
            throw new Error("Invalid history index");
        }
    }
}
}
