import { Controller } from "@hotwired/stimulus"

/**
 * Dropdown Menu Controller
 * 
 * A simplified Stimulus controller that implements an accessible dropdown menu.
 * 
 * Usage:
 * <div data-controller="dropdown-menu" class="dropdown-menu">
 *   <button type="button" 
 *     data-dropdown-menu-target="trigger"
 *     data-action="click->dropdown-menu#toggle"
 *     aria-haspopup="menu" 
 *     aria-expanded="false" 
 *     class="btn-outline">Open</button>
 *   <div data-dropdown-menu-target="popover" aria-hidden="true">
 *     <div role="menu" data-dropdown-menu-target="menu">
 *       <!-- Menu items go here -->
 *       <div role="menuitem">Item 1</div>
 *       <div role="menuitem">Item 2</div>
 *     </div>
 *   </div>
 * </div>
 */
// Make sure the controller name matches the data-controller attribute
export default class DropdownMenuController extends Controller {
  static targets = ["trigger", "popover", "menu"]
  
  connect() {
    console.log("DropdownMenuController connected", this.element)
    
    // Make sure the popover is initially hidden
    if (this.hasPopoverTarget) {
      console.log("Found popover target, hiding it initially")
      this.popoverTarget.style.display = "none"
      this.popoverTarget.setAttribute("aria-hidden", "true")
    }
    
    // Set up trigger button
    if (this.hasTriggerTarget) {
      console.log("Found trigger target, setting initial state")
      this.triggerTarget.setAttribute("aria-expanded", "false")
      

    }
    
    // Set up click outside listener
    // Set up click outside listener (store bound reference for removal)
    this.outsideHandler = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.outsideHandler)

    // Set up keydown listener on trigger (for Enter/Space and Escape)
    if (this.hasTriggerTarget) {
      this.keydownHandler = this.keydown.bind(this)
      this.triggerTarget.addEventListener("keydown", this.keydownHandler)
    }
    
    console.log("Dropdown menu controller initialized")
  }
  
  disconnect() {
    // Clean up event listeners when controller is disconnected
    document.removeEventListener("click", this.outsideHandler)
    if (this.hasTriggerTarget && this.keydownHandler) {
      this.triggerTarget.removeEventListener("keydown", this.keydownHandler)
    }
    

  }
  
  // Handle clicks outside the dropdown
  handleClickOutside(event) {
    // If click is outside the dropdown and dropdown is open, close it
    if (this.hasTriggerTarget && 
        this.hasPopoverTarget && 
        !this.element.contains(event.target) && 
        this.triggerTarget.getAttribute("aria-expanded") === "true") {
      this.close()
    }
  }
  
  // Actions
  
  toggle(event) {
    console.log("Toggle method called", event)
    
    // Prevent default browser behavior
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    
    // Check if we have the necessary targets
    if (!this.hasTriggerTarget || !this.hasPopoverTarget) {
      console.error("Missing required targets for toggle")
      return
    }
    
    // Toggle based on current state
    const isExpanded = this.triggerTarget.getAttribute("aria-expanded") === "true"
    console.log("Current state:", isExpanded ? "expanded" : "collapsed")
    
    if (isExpanded) {
      this.close()
    } else {
      this.open()
    }
  }
  
  keydown(event) {
    // Handle keyboard navigation
    if (!this.hasTriggerTarget || !this.hasPopoverTarget) return
    
    const isExpanded = this.triggerTarget.getAttribute("aria-expanded") === "true"
    
    // Close on Escape key
    if (event.key === "Escape" && isExpanded) {
      this.close()
    }
    
    // Open on Enter or Space when closed
    if (!isExpanded && ["Enter", " "].includes(event.key)) {
      event.preventDefault()
      this.open()
    }
  }
  
  // Simple methods for opening and closing the dropdown
  open() {
    console.log("Opening dropdown")
    
    if (!this.hasTriggerTarget || !this.hasPopoverTarget) {
      console.error("Missing required targets for open method")
      return
    }
    
    // Update ARIA attributes
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.popoverTarget.setAttribute("aria-hidden", "false")
    
    // Show the dropdown
    this.popoverTarget.style.display = "block"
    this.popoverTarget.style.visibility = "visible"
    this.popoverTarget.classList.remove("hidden")
    
    console.log("Dropdown should now be visible")
  }
  
  close() {
    console.log("Closing dropdown")
    
    if (!this.hasTriggerTarget || !this.hasPopoverTarget) {
      console.error("Missing required targets for close method")
      return
    }
    
    // Update ARIA attributes
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.popoverTarget.setAttribute("aria-hidden", "true")
    
    // Hide the dropdown
    this.popoverTarget.style.display = "none"
    this.popoverTarget.style.visibility = "hidden"
    this.popoverTarget.classList.add("hidden")
    
    console.log("Dropdown should now be hidden")
  }
}
