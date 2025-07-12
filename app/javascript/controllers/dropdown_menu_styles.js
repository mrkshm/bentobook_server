// Add styles to ensure dropdown visibility
document.addEventListener('DOMContentLoaded', () => {
  // Create a style element
  const style = document.createElement('style');
  
  // Add CSS rules to ensure dropdown visibility
  style.textContent = `
    /* Container positioning */
    [data-controller="dropdown-menu"] {
      position: relative;
    }
    
    /* Visible state */
    [data-dropdown-menu-target="popover"][aria-hidden="false"] {
      display: block !important;
      visibility: visible !important;
      opacity: 1 !important;
      pointer-events: auto !important;
      z-index: 9999 !important;
    }
    
    /* Hidden state */
    [data-dropdown-menu-target="popover"][aria-hidden="true"] {
      display: none !important;
      visibility: hidden !important;
      pointer-events: none !important;
    }
    
    /* Temporary debugging styles */
    .dropdown-menu [data-dropdown-menu-target="popover"] {
      border: 2px solid red;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    
    /* Menu items styling */
    [data-dropdown-menu-target="menu"] [role="menuitem"] {
      cursor: pointer;
    }
    
    [data-dropdown-menu-target="menu"] [role="menuitem"].active {
      background-color: rgba(0, 0, 0, 0.1);
    }
  `;
  
  // Append the style element to the document head
  document.head.appendChild(style);
  
  console.log('Enhanced dropdown menu styles added');
});
