window.onload = function () {
	var $preloader = $('#page-preloader'),
	$spinner = $preloader.find('.spinner');
	$spinner.fadeOut();
	$preloader.delay(100).fadeOut('slow');
	sessionStorage.setItem('loaded', false);
};

(function() {
  var app = angular.module('Sensors', [ ]);
})();