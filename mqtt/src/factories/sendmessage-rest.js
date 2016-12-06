// Factory REST for sending messages
(function() {
	angular.module('Sensors').factory('sendmessageREST', [ '$http', function($http) {
		var factory = {};
		
		factory.url = '/rest/json/';
		
		// SendMessage POST request
		factory.send = function(clientObjectId, message, successHandler, errorHandler) {
			$http({
				method: 'POST',
				url: factory.url + 'publish/' + clientObjectId,
				data: message
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
						errorHandler.call(this, 'Error while connecting MQTT Client (HTTP Status:' + result.status + '):\n' + result.data);
					}
				}
			);
		}
		
		return factory;
	}]); 
})();


