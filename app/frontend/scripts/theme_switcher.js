function initializeThemeSwitcher() {
    const themeSelect = document.getElementById('theme-select');
    if (themeSelect) {
      const currentTheme = localStorage.getItem('theme') || 'light';
      document.documentElement.setAttribute('data-theme', currentTheme);
      themeSelect.value = currentTheme;
  
      themeSelect.addEventListener('change', (e) => {
        const newTheme = e.target.value;
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
      });
    }
  }
  
  document.addEventListener('turbo:load', initializeThemeSwitcher);
  document.addEventListener('DOMContentLoaded', initializeThemeSwitcher);