jQuery(function($){

var CHAKRA = window.CHAKRA || {};

/* ==================================================
   Mobile Navigation
================================================== */
/* Clone Menu for use later */
var mobileMenuClone = $('#menu').clone().attr('id', 'navigation-mobile');

CHAKRA.mobileNav = function(){
	var windowWidth = $(window).width();
	
	// Show Menu or Hide the Menu
	if( windowWidth <= 979 ) {
		if( $('#mobile-nav').length > 0 ) {
			mobileMenuClone.insertAfter('#menu');
			$('#navigation-mobile #menu-nav').attr('id', 'menu-nav-mobile');
		}
	} else {
		$('#navigation-mobile').css('display', 'none');
		if ($('#mobile-nav').hasClass('open')) {
			$('#mobile-nav').removeClass('open');	
		}
	}
}

// Call the Event for Menu 
CHAKRA.listenerMenu = function(){
	$('#mobile-nav').on('click', function(e){
		$(this).toggleClass('open');
		
		$('#navigation-mobile').stop().slideToggle(350, 'easeOutExpo');
		
		e.preventDefault();
	});
	
	$('#menu-nav-mobile a').on('click', function(){
		$('#mobile-nav').removeClass('open');
		$('#navigation-mobile').slideUp(350, 'easeOutExpo');
	});
}


/* ==================================================
   Slider Options
================================================== */

CHAKRA.slider = function(){
	$.supersized({
		// Functionality
		slideshow               :   1,			// Slideshow on/off
		autoplay				:	1,			// Slideshow starts playing automatically
		start_slide             :   1,			// Start slide (0 is random)
		stop_loop				:	0,			// Pauses slideshow on last slide
		random					: 	0,			// Randomize slide order (Ignores start slide)
		slide_interval          :   12000,		// Length between transitions
		transition              :   2, 			// 0-None, 1-Fade, 2-Slide Top, 3-Slide Right, 4-Slide Bottom, 5-Slide Left, 6-Carousel Right, 7-Carousel Left
		transition_speed		:	300,		// Speed of transition
		new_window				:	1,			// Image links open in new window/tab
		pause_hover             :   0,			// Pause slideshow on hover
		keyboard_nav            :   1,			// Keyboard navigation on/off
		performance				:	1,			// 0-Normal, 1-Hybrid speed/quality, 2-Optimizes image quality, 3-Optimizes transition speed // (Only works for Firefox/IE, not Webkit)
		image_protect			:	1,			// Disables image dragging and right click with Javascript
												   
		// Size & Position						   
		min_width		        :   0,			// Min width allowed (in pixels)
		min_height		        :   0,			// Min height allowed (in pixels)
		vertical_center         :   1,			// Vertically center background
		horizontal_center       :   1,			// Horizontally center background
		fit_always				:	0,			// Image will never exceed browser width or height (Ignores min. dimensions)
		fit_portrait         	:   1,			// Portrait images will not exceed browser height
		fit_landscape			:   0,			// Landscape images will not exceed browser width
												   
		// Components							
		slide_links				:	'blank',	// Individual links for each slide (Options: false, 'num', 'name', 'blank')
		thumb_links				:	0,			// Individual thumb links for each slide
		thumbnail_navigation    :   0,			// Thumbnail navigation
		slides 					:  	[			// Slideshow Images
											{image : '/assets/chakra/slider-images/image01.jpg', title : '<div class="slide-content"><h1>Yhteinen</h1><p>Yhteinen on tammikuussa 2012 perustettu yhteisö, joka järjestää matalan kynnyksen luovaa toimintaa ja tapahtumia, tiedottaa tapahtumista ja saattaa ihmisiä yhteen. Yhteisen takana on joukko yhteisöllisyydestä, rakentavasta keskustelusta ja kantaaottavasta luovuudesta kiinnostuneita ihmisiä.</p></div>', thumb : '', url : ''},
											{image : '/assets/chakra/slider-images/image02.jpg', title : '<div class="slide-content"><h1>Yhteinen</h1><p>Tällä sivustolla suunnitellaan ja toteutetaan projekteja, linkkaillaan inspiroivaa sisältöä ja käydään keskustelua yhteisön jäseniä kiinnostavista aiheista sääntöjen puitteissa.</p></div>', thumb : '', url : ''},
											{image : '/assets/chakra/slider-images/image03.jpg', title : '<div class="slide-content">Ystävänpäivän siirappinen katujuhla</div>', thumb : '', url : ''},
											//{image : '/assets/chakra/slider-images/image04.jpg', title : '<div class="slide-content">Showcase Your Work</div>', thumb : '', url : ''}  
									],
									
		// Theme Options			   
		progress_bar			:	0,			// Timer for each slide							
		mouse_scrub				:	0
		
	});

}


/* ==================================================
   Navigation Fix
================================================== */

CHAKRA.nav = function(){
	$('.sticky-nav').waypoint('sticky');
}


/* ==================================================
   Filter Works
================================================== */

CHAKRA.filter = function (container){
	//if($('#projects').length > 0){		
		var $container = $('#' + container);
		
		$container.imagesLoaded(function() {
			$container.isotope({
			  // options
			  animationEngine: 'best-available',
			  itemSelector : '.item-thumbs',
			  layoutMode : 'fitRows'
			});
		});
	
		
		// filter items when filter link is clicked
		var $optionSets = $('#' + container + '-options .option-set'),
			$optionLinks = $optionSets.find('a');
	
		  $optionLinks.click(function(){
			var $this = $(this);
			// don't proceed if already selected
			if ( $this.hasClass('selected') ) {
			  return false;
			}
			var $optionSet = $this.parents('.option-set');
			$optionSet.find('.selected').removeClass('selected');
			$this.addClass('selected');
	  
			// make option object dynamically, i.e. { filter: '.my-filter-class' }
			var options = {},
				key = $optionSet.attr('data-option-key'),
				value = $this.attr('data-option-value');
			// parse 'false' as false boolean
			value = value === 'false' ? false : value;
			options[ key ] = value;
			if ( key === 'layoutMode' && typeof changeLayoutMode === 'function' ) {
			  // changes in layout modes need extra logic
			  changeLayoutMode( $this, options )
			} else {
			  // otherwise, apply new options
			  $container.isotope( options );
			}
			
			return false;
		});
	//}
}


/* ==================================================
   FancyBox
================================================== */

CHAKRA.fancyBox = function(){
	if($('.fancybox').length > 0 || $('.fancybox-media').length > 0 || $('.fancybox-various').length > 0){
		
		$(".fancybox").fancybox({				
			padding : 0,
			beforeShow: function () {
				this.title = $(this.element).attr('title');
				this.title = '<h4>' + this.title + '</h4>' + '<p>' + $(this.element).parent().find('img').attr('alt') + '</p>';
			},
			helpers : {
				title : { type: 'inside' },
			}
		});
			
		$('.fancybox-media').fancybox({
			openEffect  : 'none',
			closeEffect : 'none',
			helpers : {
				media : {}
			}
		});
		
		$(".fancybox-various").fancybox({
			maxWidth	: 800,
			maxHeight	: 600,
			fitToView	: false,
			width		: '70%',
			height		: '70%',
			autoSize	: false,
			closeClick	: false,
			openEffect	: 'none',
			closeEffect	: 'none'
		});
	}
}


/* ==================================================
   Contact Form
================================================== */

CHAKRA.contactForm = function(){
	$("#contact-submit").on('click',function() {
		$contact_form = $('#contact-form');
		
		var fields = $contact_form.serialize();
		
		$.ajax({
			type: "POST",
			url: "_include/php/contact.php",
			data: fields,
			dataType: 'json',
			success: function(response) {
				
				if(response.status){
					$('#contact-form input').val('');
					$('#contact-form textarea').val('');
				}
				
				$('#response').empty().html(response.html);
			}
		});
		return false;
	});
}


/* ==================================================
   Twitter Feed
================================================== */

CHAKRA.tweetFeed = function(){
	
	var valueTop = -64; // Margin Top Value
	
    $("#ticker").tweet({
          modpath: '_include/js/twitter/',
          username: "Bluxart", // Change this with YOUR ID
          page: 1,
          avatar_size: 0,
          count: 10,
		  template: "{text}{time}",
		  filter: function(t){ return ! /^@\w+/.test(t.tweet_raw_text); },
          loading_text: "loading ..."
	}).bind("loaded", function() {
	  var ul = $(this).find(".tweet_list");
	  var ticker = function() {
		setTimeout(function() {
			ul.find('li:first').animate( {marginTop: valueTop + 'px'}, 500, 'linear', function() {
				$(this).detach().appendTo(ul).removeAttr('style');
			});	
		  ticker();
		}, 5000);
	  };
	  ticker();
	});
	
}


/* ==================================================
   Menu Highlight
================================================== */

CHAKRA.menu = function(){
	$('#menu-nav, #menu-nav-mobile').onePageNav({
		currentClass: 'current',
    	changeHash: false,
    	scrollSpeed: 750,
    	scrollOffset: 30,
    	scrollThreshold: 0.5,
		easing: 'easeOutExpo',
		filter: ':not(.external)'
	});
}

/* ==================================================
   Next Section
================================================== */

CHAKRA.goSection = function(){
	$('#nextsection').on('click', function(){
		$target = $($(this).attr('href')).offset().top-30;
		
		$('body, html').animate({scrollTop : $target}, 750, 'easeOutExpo');
		return false;
	});
}

/* ==================================================
   GoUp
================================================== */

CHAKRA.goUp = function(){
	$('#goUp').on('click', function(){
		$target = $($(this).attr('href')).offset().top-30;
		
		$('body, html').animate({scrollTop : $target}, 750, 'easeOutExpo');
		return false;
	});
}


/* ==================================================
	Scroll to Top
================================================== */

CHAKRA.scrollToTop = function(){
	var windowWidth = $(window).width(),
		didScroll = false;

	var $arrow = $('#back-to-top');

	$arrow.click(function(e) {
		$('body,html').animate({ scrollTop: "0" }, 750, 'easeOutExpo' );
		e.preventDefault();
	})

	$(window).scroll(function() {
		didScroll = true;
	});

	setInterval(function() {
		if( didScroll ) {
			didScroll = false;

			if( $(window).scrollTop() > 1000 ) {
				$arrow.css('display', 'block');
			} else {
				$arrow.css('display', 'none');
			}
		}
	}, 250);
}

/* ==================================================
   Thumbs / Social Effects
================================================== */

// Fix Hover on Touch Devices
CHAKRA.utils = function(){
	
	$('.item-thumbs').bind('touchstart', function(){
		$(".active").removeClass("active");
      	$(this).addClass('active');
    });
	
}

/* ==================================================
   Accordion
================================================== */

CHAKRA.accordion = function(){
	var accordion_trigger = $('.accordion-heading.accordionize');
	
	accordion_trigger.delegate('.accordion-toggle','click', function(event){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
		   	$(this).addClass('inactive');
		}
		else{
		  	accordion_trigger.find('.active').addClass('inactive');          
		  	accordion_trigger.find('.active').removeClass('active');   
		  	$(this).removeClass('inactive');
		  	$(this).addClass('active');
	 	}
		event.preventDefault();
	});
}

/* ==================================================
   Toggle
================================================== */

CHAKRA.toggle = function(){
	var accordion_trigger_toggle = $('.accordion-heading.togglize');
	
	accordion_trigger_toggle.delegate('.accordion-toggle','click', function(event){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
		   	$(this).addClass('inactive');
		}
		else{
		  	$(this).removeClass('inactive');
		  	$(this).addClass('active');
	 	}
		event.preventDefault();
	});
}

/* ==================================================
   Tooltip
================================================== */

CHAKRA.toolTip = function(){ 
    $('a[data-toggle=tooltip]').tooltip();
}

/* ==================================================
   Map
================================================== */

CHAKRA.map = function(){
	if($('.map').length > 0)
	{

		$('.map').each(function(i,e){

			$map = $(e);
			$map_id = $map.attr('id');
			$map_lat = $map.attr('data-mapLat');
			$map_lon = $map.attr('data-mapLon');
			$map_zoom = parseInt($map.attr('data-mapZoom'));
			$map_title = $map.attr('data-mapTitle');
			
			
			
			var latlng = new google.maps.LatLng($map_lat, $map_lon);			
			var options = { 
				scrollwheel: false,
				draggable: false, 
				zoomControl: false,
				disableDoubleClickZoom: false,
				disableDefaultUI: true,
				zoom: $map_zoom,
				center: latlng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			};
			
			var styles = [ 
							{
							  stylers: [
								{ hue: "#2F3238" },
								{ saturation: -20 }
							  ]
							}, {
								featureType: "road",
								elementType: "geometry",
								stylers: [
									{ lightness: 100 },
									{ visibility: "simplified" }
							  ]
							}, {
								featureType: "road",
								elementType: "labels",
								stylers: [
									{ visibility: "off" }
							  ]
							}
						];
			
			var styledMap = new google.maps.StyledMapType(styles,{name: "Styled Map"});
			
			var map = new google.maps.Map(document.getElementById($map_id), options);
		
			var image = '/assets/chakra/marker.png';
			var marker = new google.maps.Marker({
				position: latlng,
				map: map,
				title: $map_title,
				icon: image
			});
			
			map.mapTypes.set('map_style', styledMap);
  			map.setMapTypeId('map_style');
			
			var contentString = '<p><strong>Company Name</strong><br>Address here</p>';
       
			var infowindow = new google.maps.InfoWindow({
				content: contentString
			});
			
			google.maps.event.addListener(marker, 'click', function() {
      			infowindow.open(map,marker);
    		});

		});
	}	
}

/* ==================================================
	Init
================================================== */

CHAKRA.slider();

$(document).ready(function(){
	// Call placeholder.js to enable Placeholder Property for IE9
	/*Modernizr.load([
	{
		//test: Modernizr.input.placeholder,
		//nope: '_include/js/placeholder.js', 
		complete : function() {
				if (!Modernizr.input.placeholder) {
						Placeholders.init({
						live: true,
						hideOnFocus: false,
						className: "yourClass",
						textColor: "#999"
						});    
				}
		}
	}
	]);*/
	
	// Preload the page with jPreLoader
	$('body').jpreLoader({
		splashID: "#jSplash",
		showSplash: true,
		showPercentage: true,
		autoClose: true
	});
	
	CHAKRA.nav();
	CHAKRA.mobileNav();
	CHAKRA.listenerMenu();
	CHAKRA.menu();
	CHAKRA.goSection();
	CHAKRA.goUp();
	CHAKRA.filter('projects');
	CHAKRA.filter('eventslist');
	CHAKRA.fancyBox();
	CHAKRA.contactForm();
	CHAKRA.tweetFeed();
	CHAKRA.scrollToTop();
	CHAKRA.utils();
	CHAKRA.accordion();
	CHAKRA.toggle();
	CHAKRA.toolTip();
	CHAKRA.map();
});

$(window).resize(function(){
	CHAKRA.mobileNav();
});

});
