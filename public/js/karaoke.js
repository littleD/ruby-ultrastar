var i = -1;
actual_line = 0;
this_song = 0;

function play_karaoke() {
	obj = this_song.find('.lyrics');
	setTimeout(function(){
		play_karaoke(obj);
// obj.find('span').eq(i+1),attr('data-time') 
	}, (obj.find('span').eq(i+1).attr('data-time')- obj.find('span').eq(i).attr('data-time')));
//	$("span").css('color','red');
	var new_actual_line = obj.find('span').eq(i).parent();
	if (i == -1) {	
		actual_line = new_actual_line;
		}
	else {
		if (actual_line.not(new_actual_line).length) {
			actual_line.hide();
			actual_line = new_actual_line;
		}
		obj.find('span').eq(i-1).css({'color':'black','border':'0'});
		obj.find('span').eq(i).css({'color':'red','border-bottom':'3px solid red'});
	};
	i++;
}

$('.song button.play').live('click', function() {
	this_song = $(this).parent();
	$(this).siblings('.lyrics').show();
	this_song_id = this_song.find('object').attr('id');
	niftyplayer(this_song_id).playToggle();
	niftyplayer(this_song_id).registerEvent('onPlay', 'play_karaoke()');

});
$('.song button.search').live('click', function() {
$(this).parent().find('.lyrics').before('<div class="search">,,,</div>');
//alert($('input[name="q"]').attr('value'));
$(this).parent().find('div.search').load("/s",{q: $(this).parent().find('input[name="q"]').attr('value')});
$(this).hide();
});

$(document).ready( function () {
  $('.song .debug').hide();
  $('.song .lyrics').hide();
  $('.categories input').hide();
});

$('.b_debug').live('click', function() {
  $(this).siblings('.debug').toggle();
});
$('.categories img').live('click', function() {
  $(this).parent().find('input').toggle();
  $(this).parent().find('span').toggle();
});


$('.song h1').live('click', function() {
	this_container = $(this).parent();
  this_container.find('.lyrics').toggle();
});
