(function () {
    var btn     = document.getElementById('navHamburger') || document.querySelector('.btn-hamburger');
    var links   = document.querySelector('.nav-links');
    var buttons = document.querySelector('.nav-buttons');
    var overlay = document.querySelector('.nav-overlay');

    if (!btn || !links || !overlay) return;

    function openMenu() {
        links.classList.add('open');
        if (buttons) buttons.classList.add('open');
        overlay.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
    }

    function closeMenu() {
        links.classList.remove('open');
        if (buttons) buttons.classList.remove('open');
        overlay.classList.remove('open');
        btn.setAttribute('aria-expanded', 'false');
    }

    btn.addEventListener('click', function (e) {
        e.stopPropagation();
        links.classList.contains('open') ? closeMenu() : openMenu();
    });

    // Overlay is pointer-events:none (visual only), so close on any outside click
    document.addEventListener('click', function (e) {
        if (!links.classList.contains('open')) return;
        if (links.contains(e.target)) return;
        if (buttons && buttons.contains(e.target)) return;
        if (btn.contains(e.target)) return;
        closeMenu();
    });
})();
