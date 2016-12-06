// Factory REST for get data
(function() {
	angular.module('Sensors').factory('sensorsREST', [ '$http', function($http) {
		var factory = {};
		
		factory.url = '/rest/json/';
		// GET request for receiving data
		factory.getData = function(connectionid, successHandler, errorHandler) {
			$http({
				method: 'GET',
				url: factory.url + 'messages'
			}).then(
				// success
				function(result) {
					if (typeof successHandler === 'function') {
						successHandler.call(this, result.data);	
					}
				},
				// error
				function(result) {
					if (typeof errorHandler === 'function') {
						errorHandler.call(this, 'Error while retrieveng sensor data (HTTP Status:' + result.status + '):\n' + result.data);
					}
				}
			);
		}
		
		return factory;
	}]); 
})();