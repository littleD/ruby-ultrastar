$(document).ready( function () {
  $('.subdirs').hide();
});
$('.dir button.unhide').live('click', function() {
  $(this).siblings('.subdirs').toggle();
});
