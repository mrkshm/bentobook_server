export function initializeNavbar() {
    const themeSelectMobile = document.getElementById('theme-select-mobile');
    const themeSelect = document.getElementById('theme-select');

    if (themeSelectMobile && themeSelect) {
        themeSelectMobile.removeEventListener('change', updateMainThemeSelect);
        themeSelectMobile.addEventListener('change', updateMainThemeSelect);
    }
}

function updateMainThemeSelect(e) {
    const themeSelect = document.getElementById('theme-select');
    themeSelect.value = e.target.value;
    themeSelect.dispatchEvent(new Event('change'));
}

document.addEventListener('turbo:load', initializeNavbar);
document.addEventListener('turbo:render', initializeNavbar);

// Fallback to 'DOMContentLoaded' for non-Turbo pages
document.addEventListener('DOMContentLoaded', () => {
    if (typeof Turbo === 'undefined') {
        initializeNavbar();
    }
});