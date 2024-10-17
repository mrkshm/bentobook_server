export function initializeNavbar() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');

    if (mobileMenuButton && mobileMenu) {
        mobileMenuButton.removeEventListener('click', toggleMobileMenu);
        mobileMenuButton.addEventListener('click', toggleMobileMenu);
    }

    const themeSelectMobile = document.getElementById('theme-select-mobile');
    const themeSelect = document.getElementById('theme-select');

    if (themeSelectMobile && themeSelect) {
        themeSelectMobile.removeEventListener('change', updateMainThemeSelect);
        themeSelectMobile.addEventListener('change', updateMainThemeSelect);
    }
}

function toggleMobileMenu(event) {
    event.preventDefault();
    event.stopPropagation();
    const mobileMenu = document.getElementById('mobile-menu');
    
    if (mobileMenu.dataset.toggling === 'true') {
        return;
    }

    mobileMenu.dataset.toggling = 'true';
    
    if (mobileMenu.style.display === 'none' || mobileMenu.style.display === '') {
        mobileMenu.style.display = 'block';
    } else {
        mobileMenu.style.display = 'none';
    }

    setTimeout(() => {
        mobileMenu.dataset.toggling = 'false';
    }, 100);
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