(function() {
	angular.module('Sensors').directive('navbarNav', function() {
		return {
			restrict: 'E',
			templateUrl: 'src2/templates/navbar-nav.html',
			controller: 'NavbarController',
			controllerAs: 'navbar',
			bindToController: true
		}
	});
})();