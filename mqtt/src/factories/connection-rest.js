// Factory REST for connection, disconnetion and subscription
(function() {
	angular.module('Sensors').factory('connectionREST', [ '$http', function($http) {
		var factory = {};
		
		factory.url = '/rest/json/';
		// Connection GET request
		factory.connect = function(clientid, successHandler, errorHandler) {
			$http({
				method: 'GET',
				url: factory.url + 'connect/' + clientid
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
		// Disconnectoin GET request
		factory.disconnect = function(clientObjectId, successHandler, errorHandler) {
			$http({
				method: 'GET',
				url: factory.url + 'disconnect/' + clientObjectId
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
		// Subscription POST request
		factory.subscribe = function(clientObjectId, topics, successHandler, errorHandler) {
			$http({
				method: 'POST',
				url: factory.url + 'subscribe/' + clientObjectId,
				data: topics
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
		factory.unsubscribe = function(clientObjectId, topics, successHandler, errorHandler) {
			$http({
				method: 'POST',
				url: factory.url + 'unsubscribe/' + clientObjectId,
				data: topics
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