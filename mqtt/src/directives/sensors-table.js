(function() {
	angular.module('Sensors').directive('sensorsTable', function() {
		return {
			restrict: 'E',
			templateUrl: 'src/templates/sensors-table.html',
			controller: 'SensorController',
			controllerAs: 'sensors',
			bindToController: true
		}
	});
})();