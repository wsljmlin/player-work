//javascript Document

document.getElementById("ad_1").innerHTML = document.getElementById("ad1").innerHTML;
document.getElementById("ad_3").innerHTML = document.getElementById("ad3").innerHTML;
document.getElementById("ad_4").innerHTML = document.getElementById("ad4").innerHTML;
document.getElementById("ad_5").innerHTML = document.getElementById("ad5").innerHTML;
document.getElementById("ad_6").innerHTML = document.getElementById("ad6").innerHTML;
document.getElementById("ad_7").innerHTML = document.getElementById("ad7").innerHTML;
document.getElementById("ad_8").innerHTML = document.getElementById("ad8").innerHTML;
document.getElementById("ad_9").innerHTML = document.getElementById("ad9").innerHTML;
document.getElementById("ad_13").innerHTML = document.getElementById("ad13").innerHTML; 
document.getElementById("ad_14").innerHTML = document.getElementById("ad14").innerHTML;

jQuery(".slideBox").slide({mainCell:".bd ul",effect:"leftLoop",autoPlay:true,easing:"easeOutCirc",delayTime:700,interTime:5000});
$(".slideBox").hover(function(){
		$(".slideArrow").fadeIn(100)					  
	},function(){
	    $(".slideArrow").fadeOut(100)
	})	

function cto(){
	this.init();
}
cto.prototype = {
	constructor: cto,
	init: function(){		
		this._initBackTop();
	},	
	_initBackTop: function(){
		var $backTop = this.$backTop = $('<div class="cbbfixed">'+
						'<a class="cweixin cbbtn"">'+
							'<span class="weixin-icon"></span><div></div>'+
						'</a>'+
						'<a class="gotop cbbtn">'+
							'<span class="up-icon"></span>'+
						'</a>'+
					'</div>');
		$('body').append($backTop);
		
		$backTop.click(function(){
			$("html, body").animate({
				scrollTop: 0
			}, 120);
		});

		var timmer = null;
		$(window).bind("scroll",function() {
            var d = $(document).scrollTop(),
            e = $(window).height();
            0 < d ? $backTop.css("bottom", "30px") : $backTop.css("bottom", "-90px");
			clearTimeout(timmer);
			timmer = setTimeout(function() {
                clearTimeout(timmer)
            },100);
	   });
	}
	
}
var cto = new cto();

$(function(){
		 $(".home-left-nav a").click(function(){
				var i= $(".home-left-nav a").index(this)
				$(".home-left-nav a").removeClass("cur")
				$(this).addClass("cur");
				$(".home-left-list").eq(i).show().siblings(".home-left-list").hide();						
		});
		var _leftNav = $('.nav-scroll');
		$(window).scroll(function () {
			_top = $(document).scrollTop();
			if (_top > 912) {
				_leftNav.addClass('left-flow');
				if (!-[1, ] && !window.XMLHttpRequest) {
					timer = setTimeout (function () {
						_leftNav.stop (true, false).animate ({
								top: _top - 386
							},
							200);
					}, 600
				);
				}
			} else {
				if (_top < 912) {
					_leftNav.removeClass('left-flow');
				}
			}
		}); 
		 
		 var _sideBox = $ ('.scrollTop');
		   $ (window).scroll (function () {
				_top = $ (document).scrollTop();
				if (_top > 4730) {
					_sideBox.addClass ('modScroll');
					if (!-[1, ] && !window.XMLHttpRequest) {
						timer = setTimeout (function () {
								_sideBox.stop (true, false).animate ({
										top: _top - 386
									},
									200);
							}, 600
						);
					}
				} else {
					if (_top < 4730) {
						_sideBox.removeClass ('modScroll');
					}
				}
			}); 
	$('.morenav').click(function(){
		$('.morenav-list').css('diplay', 'inline-table');
		var sd = $(".morenav-list")[0].style.display;
		if (sd && sd == 'inline-table') {
			$(".morenav-list")[0].style.display = '';
			$(".morenav").css('background-color', '');
			$(".morenav").css('border-left', '');
		} else {
			
			$(".morenav-list")[0].style.display = 'inline-table';
			$(".morenav").css('background-color', '#fff');
			$(".morenav").css('border-left', '1px solid #DFDFDF');
		}
	})
 })
 
 function addFavorite(url, title) {
	try {
		window.external.addFavorite(url, title);
	} catch (e){
		try {
			window.sidebar.addPanel(title, url, '');
        	} catch (e) {
			//showDialog("请按 Ctrl+D 键添加到收藏夹", 'notice');
			alert('请按 Ctrl+D 键添加到收藏夹');
		}
	}
}
