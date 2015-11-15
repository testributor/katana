!function($) {
    "use strict";

    var CodeEditor = function() {};

    CodeEditor.prototype.getSelectedRange = function(editor) {
        return { from: editor.getCursor(true), to: editor.getCursor(false) };
    },
    CodeEditor.prototype.autoFormatSelection = function(editor) {
        var range = this.getSelectedRange(editor);
        editor.autoFormatRange(range.from, range.to);
    },
    CodeEditor.prototype.commentSelection = function(isComment, editor) {
        var range = this.getSelectedRange(editor);
        editor.commentRange(isComment, range.from, range.to);
    },
    CodeEditor.prototype.init = function() {
        var $this = this;
        //example 2
        CodeMirror.fromTextArea(document.getElementsByClassName("code")[0], {
            mode: {name: "yaml"},
            lineNumbers: true,
            theme: 'neat'
        });

        //binding controlls
        $('.autoformat').click(function(){
            $this.autoFormatSelection(editor);
        });

        $('.comment').click(function(){
            $this.commentSelection(true, editor);
        });

        $('.uncomment').click(function(){
            $this.commentSelection(false, editor);
        });
    },
    //init
    $.CodeEditor = new CodeEditor, $.CodeEditor.Constructor = CodeEditor
}(window.jQuery),

//initializing
function($) {
    "use strict";
    $.CodeEditor.init()
}(window.jQuery);
