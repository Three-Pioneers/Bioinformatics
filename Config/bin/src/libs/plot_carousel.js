/* 同类图逐张切换；每个轮播独立，支持左右按钮及方向键。 */
(function () {
  function initialize() {
    document.querySelectorAll('.plot-carousel').forEach(function (gallery) {
      if (gallery.dataset.carouselReady) return;
      var slides = Array.from(gallery.querySelectorAll('.carousel-slide'));
      if (!slides.length) return;
      var previous = gallery.querySelector('[data-carousel-prev]');
      var next = gallery.querySelector('[data-carousel-next]');
      var current = 0;
      gallery.dataset.carouselReady = 'true';
      gallery.dataset.count = String(slides.length);
      function show(index) {
        current = (index + slides.length) % slides.length;
        slides.forEach(function (slide, i) {
          slide.hidden = i !== current;
          slide.setAttribute('aria-hidden', String(i !== current));
        });
      }
      if (previous) previous.addEventListener('click', function () { show(current - 1); });
      if (next) next.addEventListener('click', function () { show(current + 1); });
      gallery.addEventListener('keydown', function (event) {
        if (slides.length < 2 || event.target.closest('input, select, textarea, [contenteditable="true"]')) return;
        if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
          event.preventDefault();
          show(current + (event.key === 'ArrowLeft' ? -1 : 1));
        }
      });
      show(0);
    });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initialize);
  else initialize();
})();
