window.HOMEDAYCARE_WEB = { service: 'homedaycare-web', version: '2026-08-07b' };

const form = document.getElementById('inquiryForm');
const copyButton = document.getElementById('copyInquiry');
const statusEl = document.getElementById('formStatus');
const CONTACT_EMAIL = 'hello@example.com';

function buildInquiry() {
  const parent = document.getElementById('parentName')?.value.trim() || 'Parent';
  const age = document.getElementById('childAge')?.value || 'not selected';
  const meals = document.getElementById('mealsNeeded')?.value || 'not sure yet';
  const notes = document.getElementById('careNotes')?.value.trim() || 'No extra notes yet.';
  return `Home daycare inquiry
Parent: ${parent}
Child age: ${age}
Meals needed: ${meals}
Notes: ${notes}`;
}

form?.addEventListener('submit', (event) => {
  event.preventDefault();
  if (!form.reportValidity()) return;
  const subject = encodeURIComponent('Home daycare availability inquiry');
  const body = encodeURIComponent(buildInquiry());
  window.location.href = `mailto:${CONTACT_EMAIL}?subject=${subject}&body=${body}`;
  statusEl.textContent = 'Email draft opened with the daycare inquiry details.';
});

copyButton?.addEventListener('click', async () => {
  const text = buildInquiry();
  try {
    await navigator.clipboard.writeText(text);
    statusEl.textContent = 'Inquiry details copied.';
  } catch {
    statusEl.textContent = text;
  }
});
