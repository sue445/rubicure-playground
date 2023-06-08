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

$(() => {
  const fontSize = $("#param_font_size").val();
  const readonly = $("#param_readonly").val() != "";

  const inputEditor = ace.edit("input");
  inputEditor.setTheme("ace/theme/monokai");
  inputEditor.session.setMode("ace/mode/ruby");
  inputEditor.setFontSize(fontSize);
  inputEditor.setValue($("#param_input").val());
  inputEditor.setReadOnly(readonly);

  const outputEditor = ace.edit("output");
  outputEditor.setTheme("ace/theme/monokai");
  outputEditor.session.setMode("ace/mode/ruby");
  outputEditor.setFontSize(fontSize);
  outputEditor.setReadOnly(true);

  $("#run").click(() => {
    const input = inputEditor.getValue();
    const query = `?readonly=${readonly}&font_size=${fontSize}&input=${encodeURIComponent(input)}`;
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
