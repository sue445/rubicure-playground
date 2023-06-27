function printWithDelay(text, delay, is_final_line) {
  const outputEditor = ace.edit("output");

  return new Promise((resolve) => {
    setTimeout(() => {
      let output = outputEditor.getValue();
      output += text + "\n"
      outputEditor.setValue(output);

      // Scroll to bottom
      outputEditor.gotoLine(outputEditor.session.getLength());

      if (is_final_line) {
        $("#run").prop("disabled", false);
      }
      resolve();
    }, delay);
  });
}

async function printLinesWithDelay(lines, delay) {
  for (let i = 0; i < lines.length; i++) {
    const is_final_line = i == lines.length - 1
    await printWithDelay(lines[i], delay, is_final_line);
  }
}

function createEditor(params) {
  const id = params.id;
  const height = params.height;
  const fontSize = params.fontSize;
  const readonly = params.readonly;
  const text = params.text;

  const editor = ace.edit(id);
  editor.setTheme("ace/theme/monokai");
  editor.session.setMode("ace/mode/ruby");
  editor.setFontSize(fontSize);
  editor.setReadOnly(readonly);

  if (text) {
    editor.setValue(text);
  }

  if (height != "") {
    editor.container.style.height = height;
    editor.resize();
  }

  return editor;
}

$(() => {
  const fontSize = $("#param_font_size").val();
  const readonly = $("#param_readonly").val() == "true";
  const editorHeight = $("#param_editor_height").val();

  const inputEditor = createEditor({
    id: "input", height: editorHeight, fontSize: fontSize,
    readonly: readonly, text: $("#param_input").val(),
  });

  const outputEditor = createEditor({
    id: "output", height: editorHeight, fontSize: fontSize,
    readonly: true,
  });

  $("#run").click(() => {
    const input = inputEditor.getValue();
    const query = `?readonly=${readonly}&editor_height=${editorHeight}&font_size=${fontSize}&input=${encodeURIComponent(input)}`;
    history.replaceState(null, "", query)

    $.ajax({
      url: "/run",
      type: "POST",
      dataType: "json",
      data: {
        input: input
      }
    }).done((data) => {
      $("#run").prop("disabled", true);

      outputEditor.setValue("");
      const lines = data.output.split('\n');
      printLinesWithDelay(lines, 1000);
    })
  })
});
