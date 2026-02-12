const storageKey = "exam-pulse-pro.exams.v1";
const examForm = document.querySelector("#exam-form");
const examList = document.querySelector("#exam-list");
const cardTemplate = document.querySelector("#exam-card-template");
const totalExamsEl = document.querySelector("#total-exams");
const nextExamEl = document.querySelector("#next-exam");
const timezoneLabel = document.querySelector("#timezone-label");
const clearAllBtn = document.querySelector("#clear-all");
const bulkInput = document.querySelector("#bulk-input");
const bulkImportBtn = document.querySelector("#bulk-import");

/** @type {Array<{id: string, title: string, datetime: string, notes: string}>} */
let exams = readExams();

timezoneLabel.textContent = Intl.DateTimeFormat().resolvedOptions().timeZone;

examForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const formData = new FormData(examForm);
  const title = String(formData.get("title") || "").trim();
  const date = String(formData.get("date") || "");
  const time = String(formData.get("time") || "");
  const notes = String(formData.get("notes") || "").trim();

  if (!title || !date) {
    return;
  }

  const datetime = time ? `${date}T${time}` : `${date}T09:00`;
  exams.push({
    id: crypto.randomUUID(),
    title,
    datetime,
    notes,
  });

  persistAndRender();
  examForm.reset();
});

bulkImportBtn.addEventListener("click", () => {
  const rows = bulkInput.value
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);

  const additions = [];

  rows.forEach((line) => {
    const [rawTitle, rawDate, rawTime] = line.split("|").map((part) => part?.trim() || "");
    if (!rawTitle || !rawDate) {
      return;
    }

    additions.push({
      id: crypto.randomUUID(),
      title: rawTitle,
      datetime: rawTime ? `${rawDate}T${rawTime}` : `${rawDate}T09:00`,
      notes: "",
    });
  });

  if (additions.length) {
    exams = exams.concat(additions);
    persistAndRender();
    bulkInput.value = "";
  }
});

clearAllBtn.addEventListener("click", () => {
  if (!exams.length) {
    return;
  }

  const confirmed = window.confirm("Remove all exams from this device?");
  if (!confirmed) {
    return;
  }

  exams = [];
  persistAndRender();
});

examList.addEventListener("click", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLButtonElement)) {
    return;
  }

  const id = target.dataset.id;
  if (!id) {
    return;
  }

  exams = exams.filter((exam) => exam.id !== id);
  persistAndRender();
});

setInterval(() => {
  render();
}, 1000);

render();

function persistAndRender() {
  localStorage.setItem(storageKey, JSON.stringify(exams));
  render();
}

function readExams() {
  const raw = localStorage.getItem(storageKey);
  if (!raw) {
    return [];
  }

  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed.filter((item) => item?.id && item?.title && item?.datetime);
  } catch {
    return [];
  }
}

function render() {
  const sorted = [...exams].sort((a, b) => new Date(a.datetime).getTime() - new Date(b.datetime).getTime());
  totalExamsEl.textContent = String(sorted.length);
  nextExamEl.textContent = sorted[0] ? sorted[0].title : "None yet";

  examList.innerHTML = "";

  if (!sorted.length) {
    const empty = document.createElement("p");
    empty.className = "empty";
    empty.textContent = "No exams yet. Add one on the left to start your precision countdown dashboard.";
    examList.append(empty);
    return;
  }

  sorted.forEach((exam) => {
    const fragment = cardTemplate.content.cloneNode(true);
    const card = fragment.querySelector(".exam-card");
    const title = fragment.querySelector("h3");
    const dateRow = fragment.querySelector(".date-row");
    const countdown = fragment.querySelector(".countdown");
    const notes = fragment.querySelector(".notes");
    const deleteBtn = fragment.querySelector("[data-action='delete']");

    if (!card || !title || !dateRow || !countdown || !notes || !deleteBtn) {
      return;
    }

    const dateValue = new Date(exam.datetime);
    title.textContent = exam.title;
    dateRow.textContent = `${dateValue.toLocaleDateString()} at ${dateValue.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`;
    countdown.textContent = formatCountdown(dateValue);
    notes.textContent = exam.notes || "No notes";
    deleteBtn.dataset.id = exam.id;

    examList.append(card);
  });
}

function formatCountdown(dateValue) {
  const diff = dateValue.getTime() - Date.now();
  if (Number.isNaN(diff)) {
    return "Invalid exam date";
  }

  if (diff <= 0) {
    return "Exam time reached";
  }

  const totalSeconds = Math.floor(diff / 1000);
  const days = Math.floor(totalSeconds / 86400);
  const hours = Math.floor((totalSeconds % 86400) / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  return `${days}d ${hours}h ${minutes}m ${seconds}s remaining`;
}
