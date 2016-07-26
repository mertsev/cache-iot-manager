(function() {
	angular.module('Sensors').directive('sensorsTable', function() {
		return {
			restrict: 'E',
			templateUrl: 'src2/templates/sensors-table.html',
			controller: 'SensorController',
			controllerAs: 'sensors',
			bindToController: true
		}
	});
})();