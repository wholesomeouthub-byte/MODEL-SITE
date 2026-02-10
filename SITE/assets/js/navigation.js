/**
 * Navigation JavaScript for Game News Theme
 * Handles mobile menu toggle and accessibility
 */

class Navigation {
    constructor() {
        this.init();
    }

    init() {
        this.bindEvents();
        this.setupKeyboardNavigation();
    }

    bindEvents() {
        // Mobile menu toggle
        const menuToggle = document.querySelector('.menu-toggle');
        if (menuToggle) {
            menuToggle.addEventListener('click', (e) => {
                this.toggleMenu(e);
            });
        }

        // Search toggle
        const searchToggle = document.querySelector('.search-toggle');
        if (searchToggle) {
            searchToggle.addEventListener('click', (e) => {
                this.toggleSearch(e);
            });
        }

        // Close menus when clicking outside
        document.addEventListener('click', (e) => {
            this.closeMenusOnOutsideClick(e);
        });

        // Close menus on escape
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeAllMenus();
            }
        });
    }

    toggleMenu(event) {
        const toggle = event.currentTarget;
        const menu = document.querySelector('.nav-menu');
        const expanded = toggle.getAttribute('aria-expanded') === 'true';

        toggle.setAttribute('aria-expanded', !expanded);
        menu.classList.toggle('active');

        // Update button text for screen readers
        toggle.querySelector('.sr-only').textContent = expanded ? 'Menu' : 'Fechar menu';
    }

    toggleSearch(event) {
        const toggle = event.currentTarget;
        const form = document.getElementById('search-form');
        const expanded = toggle.getAttribute('aria-expanded') === 'true';

        toggle.setAttribute('aria-expanded', !expanded);
        form.hidden = expanded;

        if (!expanded) {
            // Focus on search input when opening
            setTimeout(() => {
                const input = form.querySelector('input[type="search"]');
                if (input) input.focus();
            }, 100);
        }
    }

    closeMenusOnOutsideClick(event) {
        // Close mobile menu
        const menuToggle = document.querySelector('.menu-toggle');
        const navMenu = document.querySelector('.nav-menu');

        if (menuToggle && navMenu &&
            !menuToggle.contains(event.target) &&
            !navMenu.contains(event.target) &&
            navMenu.classList.contains('active')) {
            menuToggle.setAttribute('aria-expanded', 'false');
            navMenu.classList.remove('active');
        }

        // Close search
        const searchToggle = document.querySelector('.search-toggle');
        const searchForm = document.getElementById('search-form');

        if (searchToggle && searchForm &&
            !searchToggle.contains(event.target) &&
            !searchForm.contains(event.target) &&
            !searchForm.hidden) {
            searchToggle.setAttribute('aria-expanded', 'false');
            searchForm.hidden = true;
        }
    }

    closeAllMenus() {
        // Close mobile menu
        const menuToggle = document.querySelector('.menu-toggle');
        const navMenu = document.querySelector('.nav-menu');

        if (menuToggle && navMenu) {
            menuToggle.setAttribute('aria-expanded', 'false');
            navMenu.classList.remove('active');
        }

        // Close search
        const searchToggle = document.querySelector('.search-toggle');
        const searchForm = document.getElementById('search-form');

        if (searchToggle && searchForm) {
            searchToggle.setAttribute('aria-expanded', 'false');
            searchForm.hidden = true;
        }
    }

    setupKeyboardNavigation() {
        // Add keyboard navigation for menu items
        const menuItems = document.querySelectorAll('.nav-menu a');

        menuItems.forEach((item, index) => {
            item.addEventListener('keydown', (e) => {
                const items = Array.from(menuItems);
                let targetIndex;

                switch(e.key) {
                    case 'ArrowDown':
                        e.preventDefault();
                        targetIndex = index + 1 < items.length ? index + 1 : 0;
                        items[targetIndex].focus();
                        break;
                    case 'ArrowUp':
                        e.preventDefault();
                        targetIndex = index - 1 >= 0 ? index - 1 : items.length - 1;
                        items[targetIndex].focus();
                        break;
                    case 'Home':
                        e.preventDefault();
                        items[0].focus();
                        break;
                    case 'End':
                        e.preventDefault();
                        items[items.length - 1].focus();
                        break;
                }
            });
        });
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new Navigation();
});
