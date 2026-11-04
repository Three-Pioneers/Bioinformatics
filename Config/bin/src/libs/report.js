/* 每个模块独立切换比较，切换后调整表格宽度。 */
document.addEventListener('DOMContentLoaded', function () {
  function adjustTables() {
    window.dispatchEvent(new Event('resize'));
    if (window.jQuery && jQuery.fn.dataTable) {
      jQuery.fn.dataTable.tables({visible: true, api: true}).columns.adjust();
    }
  }
  document.querySelectorAll('.result-module').forEach(function (module) {
    var select = module.querySelector('.comparison-select');
    function update() {
      module.querySelectorAll('.result-panel').forEach(function (panel) {
        panel.hidden = select.value !== 'all' && panel.dataset.choice !== select.value;
      });
      window.requestAnimationFrame(adjustTables);
    }
    select.addEventListener('change', update);
    update();
  });

  /* GSEA 保留单通路下拉选择，每次只展示所选曲线。 */
  document.querySelectorAll('.curve-gallery').forEach(function (gallery) {
    var select = gallery.querySelector('.curve-select');
    function updateCurve() {
      gallery.querySelectorAll('.curve-panel').forEach(function (panel) {
        panel.hidden = panel.dataset.choice !== select.value;
      });
    }
    select.addEventListener('change', updateCurve);
    updateCurve();
  });
});
