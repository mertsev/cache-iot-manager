(function() {
	angular.module('Sensors').directive('connectionForm', function() {
		return {
			restrict: 'E',
			templateUrl: 'src/templates/connection-form.html',
			controller: 'ConnectionController',
			controllerAs: 'connection',
			bindToController: true
		}
	});
})();