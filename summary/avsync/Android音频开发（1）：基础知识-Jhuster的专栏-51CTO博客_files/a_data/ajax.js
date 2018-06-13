var step = 1;
$("a.change").bind('click', function() {
    if (step >= 4) {
    	step = 0;
    }
	$.get("/php/change_today.php", { step: step, num_perpage: '8' },
        function(data, status){
			var str = '';
			for (var i in data) {
				str += '<li>';
				str += '<a href="'+data[i].type_url+'" target="_blank"><i class="tcolor">'+data[i].arttype+'</i></a>';
		        str += '<a href="'+data[i].url+'" title="'+data[i].title+'" target="_blank">';
		        str += '<span>'+data[i].title+'</span></a>';
		        str += '</li>';
			}
			$("div.zd-list ul").html(str);
		    step += 1;
        }, 'json');
});

this.page = 1;
_self = this;
$("div.home-left-nav a").each(function() {
	var id = $(this).attr("id");
	$(this).bind('click', function() {
		_self.page = 1;
		if (id >0) {
		$.get('/php/get_channel_artlist.php', { id: id }, 
			function(data) {
				var str = '';
				var n = 0;
				for (var i in data[0]) {
					n += 1;
					str += '<li>';
					if (id == 9999) {
						str += '<div class="blog_pic">';
					} else {
						str += '<div class="pic">';
					}
					str += '<a href="'+data[0][i].url+'"><img src="'+data[0][i].picname+'"></a>';
					str += '<p><a href="'+data[0][i].typedomain+'" target="_blank">'+data[0][i].typename+'</a></p>';
					str += '</div>';
					if (id == 9999) {
						str += '<div class="blog_rinfo">';
					} else {
						str += '<div class="rinfo">';
					}
					str += '<a href="'+data[0][i].url+'" title="'+data[0][i].title+'" target="_blank">'+data[0][i].title+'</a>';
					str += '<p>'+data[0][i].info+'</p>';
					str += '<div class="time">';
					str += '<i>'+data[0][i].stime+'</i>';
					str += '<span>';
					str += data[0][i].keywords;
					str += '</span>';
					str += '</div>';
					str += '</div>';
					str += '<div class="fx">';
					str += '<div class="fxlist bdsharebuttonbox" id="share">';
					str += '<p>';
					str += '<a class="bds_tsina" data-cmd="tsina"></a>';
					str += '<a class="bds_qzone" data-cmd="qzone"></a>';
					str += '<a class="bds_sqq" data-cmd="sqq"></a>';
					str += '<a class="bds_weixin" data-cmd="weixin"></a>';
					str += '</p>';
					str += '</div>';
					str += '</div>';
					str += '</li>';
					if (n == 5 && data[1] != 0 && data[1] != null) {
						str += data[1].replace(/\\/g,'');
					}	
					if (n == 10 && data[2] != 0 && data[1] != null) {
						str += data[2].replace(/\\/g,'');
					}
					
				}
				$("#show-list ul").html(str);
				$(".home-left-list").hide();
				$("#show-list").show();
				$("div.home-left-list ul li").each(function() {
					 $(this).bind('mouseover', function() {
					    share_pic = $(this).find("div.pic img").attr("src");
					    share_text = $(this).find("div.rinfo a:eq(0)").text();
					    share_url = $(this).find("div.rinfo a:eq(0)").attr("href");
					    $('#fx_text').attr('data', share_text);
					    $('#fx_url').attr('data', share_url);
					    $('#fx_pic').attr('data', share_pic);
					});
				});
				window._bd_share_main.init();
			}, 'json'); 
		}
	});
});


$("div.more a").click(function() {
	var id = $("div.home-left-nav").find("a.cur").attr("id");
	$.get('/php/get_channel_artlist.php', { id: id, page: _self.page },
			function(data) {
				for (var i in data[0]) {
					var str = '';
					str += '<li>';
					if (id == 9999) {
						str += '<div class="blog_pic">';
					} else {
						str += '<div class="pic">';
					}
					str += '<a href="'+data[0][i].url+'"><img  src="'+data[0][i].picname+'"></a>';
					str += '<p><a href="'+data[0][i].typedomain+'">'+data[0][i].typename+'</a></p>';
					str += '</div>';
					if (id == 9999) {
						str += '<div class="blog_rinfo">';
					} else {
						str += '<div class="rinfo">';
					}
					str += '<a href="'+data[0][i].url+'" title="'+data[0][i].title+'" target="_blank">'+data[0][i].title+'</a>';
					str += '<p>'+data[0][i].info+'</p>';
					str += '<div class="time">';
					str += '<i>'+data[0][i].stime+'</i>';
					str += '<span>';
					str += data[0][i].keywords;
					str += '</span>';
					str += '</div>';
					str += '</div>';
					str += '<div class="fx">';
					str += '<div class="fxlist bdsharebuttonbox" id="share">';
					str += '<p>';
					str += '<a class="bds_tsina" data-cmd="tsina"></a>';
					str += '<a class="bds_qzone" data-cmd="qzone"></a>';
					str += '<a class="bds_sqq" data-cmd="sqq"></a>';
					str += '<a class="bds_weixin" data-cmd="weixin"></a>';
					str += '</p>';
					str += '</div>';
					str += '</div>';
					str += '</li>';
					if (id == 0) {
						$("div.home-left-list:eq(0) ul").append(str);
					} else {
						$("#show-list ul").append(str);
					}
				}
				_self.page += 1;
				$("div.home-left-list ul li").each(function() {
					 $(this).bind('mouseover', function() {
					    share_pic = $(this).find("div.pic img").attr("src");
					    share_text = $(this).find("div.rinfo a:eq(0)").text();
					    share_url = $(this).find("div.rinfo a:eq(0)").attr("href");
					    $('#fx_text').attr('data', share_text);
					    $('#fx_url').attr('data', share_url);
					    $('#fx_pic').attr('data', share_pic);
					});
				});
				window._bd_share_main.init();
			}, 'json');
	if (_self.page > 3) {
		if (id == 9999) {
			window.open('http://blog.51cto.com/artcommend');
		} else {
			window.open('recommnews/list1.htm');
		}
		
	}
});