def gen_html_view(songdir)
	head = '
	<head>
	<style type="text/css">

	div.container {margin-left:10px;border-left:1px gray solid;background-color:#BEDCDE}
	div.container > h1 {font-size:16px;border: 1px solid #ccc; padding:5px; background-color:#9DE8EF;}
	div.unavalible {color:#bbb; border: 1px solid #eee}
	.song {background-color:#eee}

	</style>
	<script type="text/javascript" src="public/js/jquery.js"></script>
	<script type="text/javascript">
	$(document).ready(function() {
		$(".content").hide();
	});

	$(".container img").live("click", function() {
		if ($(this).attr("src") == "icons/folder_download_closed.png")
			$(this).attr("src","icons/folder_open.png");
		else if ($(this).attr("src") == "icons/folder_open.png")
			$(this).attr("src","icons/folder_download_closed.png");

		$(this).parent().siblings(".content").toggle();
	});
	$("#filtr").keydown(function(e) {
			if (e.which == 27) {	
				$(".song").show();
				$("[id=filtr]").val("");
			} 
			else {
				setInterval(function() {
					var filter = $("#filtr").val();
					filtruj(filter);
				}, 1000);
			}
		});
		function filtruj(filter) {
			var hide_them = new Array();
			$(".song").each(function () {
				if (($(this).text().search(new RegExp(filter, "i")) < 0)) {
					hide_them.push($(this));
				} else {
					$(this).show();
				}
			});
			if ( hide_them.length == $(".song").length || hide_them.length == 0) {
	//			$(".song").each(function () {
	//				$(this).show();
	//			});
				$("#filtr").css({color:"red"});
			}
			else {
				$.each(hide_them, function (index,value) {
					value.fadeOut();
				});
				$(".song").show(); //$("#filtr").css({color:"black"});
			}
		}
	</script>
	</head>
	'
	puts head+"<body><input id=\"filtr\" type=\"text\" />#{songdir}</body>"
end
