const savedSelections = new WeakMap();

document.addEventListener("pointerdown", (event) => {
  const button = event.target.closest("[data-format]");
  if (!button) return;

  const toolbar = button.closest(".format-toolbar");
  const targetId = toolbar?.dataset.target;
  const textarea = targetId ? document.getElementById(targetId) : null;
  if (!textarea) return;

  savedSelections.set(button, {
    start: textarea.selectionStart,
    end: textarea.selectionEnd,
  });
});

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-format]");
  if (!button) return;

  const toolbar = button.closest(".format-toolbar");
  const targetId = toolbar?.dataset.target;
  const textarea = targetId ? document.getElementById(targetId) : null;
  if (!textarea) return;

  const formats = {
    bold: ["**", "**"],
    underline: ["<u>", "</u>"],
  };
  const [opening, closing] = formats[button.dataset.format] || [];
  if (!opening) return;

  const savedSelection = savedSelections.get(button);
  const start = savedSelection?.start ?? textarea.selectionStart;
  const end = savedSelection?.end ?? textarea.selectionEnd;
  savedSelections.delete(button);
  const selectedText = textarea.value.slice(start, end);
  const fallbackText = button.dataset.format === "bold" ? "bold text" : "underlined text";
  const content = selectedText || fallbackText;

  textarea.setRangeText(`${opening}${content}${closing}`, start, end, "end");
  textarea.focus();

  if (!selectedText) {
    textarea.setSelectionRange(start + opening.length, start + opening.length + content.length);
  }
});
