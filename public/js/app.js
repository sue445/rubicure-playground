function printWithDelay(text, delay, is_final_line) {
  return new Promise((resolve) => {
    setTimeout(() => {
      let output = $("#output").val();
      output += text + "\n"
      $("#output").val(output);

      // Scroll to bottom
      const pos = $("#output")[0].scrollHeight;
      $("#output").scrollTop(pos);

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
  $("#run").click(() => {
    $.ajax({
      url: "/run",
      type: "POST",
      dataType: "json",
      data: {
        input: $("#input").val()
      }
    }).done((data) => {
      $("#run").prop("disabled", true);
      $("#output").val("");
      const lines = data.output.split('\n');
      printLinesWithDelay(lines, 1000);
    })
  })
});
