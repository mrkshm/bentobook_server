export function initializeThemeSwitcher() {
  const themeToggle = document.getElementById('theme-toggle');
  if (!themeToggle) return;

  // Always set the current theme from localStorage first
  const currentTheme = localStorage.getItem('theme') || 'light';
  document.body.setAttribute('data-theme', currentTheme);
  updateThemeIcon(themeToggle, currentTheme);

  // Remove any existing click listeners to prevent duplicates
  themeToggle.removeEventListener('click', handleThemeToggle);
  // Add the click listener
  themeToggle.addEventListener('click', handleThemeToggle);
}

function handleThemeToggle() {
  const newTheme = document.body.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
  document.body.setAttribute('data-theme', newTheme);
  localStorage.setItem('theme', newTheme);
  updateThemeIcon(document.getElementById('theme-toggle'), newTheme);
}

function updateThemeIcon(button, theme) {
  if (!button) return;
  
  // Update button icon and aria-label
  button.innerHTML =
    theme === 'light'
      ? '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>'
      : '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>';
  button.setAttribute(
    'aria-label',
    `Switch to ${theme === 'light' ? 'dark' : 'light'} theme`
  );
}

// Initialize on various page load events to ensure it works in all scenarios
document.addEventListener('turbo:load', initializeThemeSwitcher);
document.addEventListener('turbo:render', initializeThemeSwitcher);
document.addEventListener('DOMContentLoaded', initializeThemeSwitcher);
