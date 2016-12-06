(function() {
	angular.module('Sensors').directive('sensorsDashboard', function() {
		return {
			restrict: 'E',
			templateUrl: 'src/templates/sensors-dashboard.html',
			controller: 'DashboardController',
			controllerAs: 'sensors-dashboard.js',
			bindToController: true
		}
	});
})();