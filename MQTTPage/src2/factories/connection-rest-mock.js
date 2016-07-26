(function() {
	angular.module('Sensors').factory('connectionREST', [ '$http', function($http) {
		var factory = {};
		
		factory.connect = function(clientid, successHandler, errorHandler) {
			var ret = { success: true, error: '', clientObject: 1 };
			if (typeof successHandler === 'function') {
				successHandler.call(this, ret);
			}
			// TODO: error handling
		}
		
		factory.disconnect = function(clientObjectId, successHandler, errorHandler) {
			var ret = { success: true, error: '' };
			if (typeof successHandler === 'function') {
				successHandler.call(this, ret);
			}
			// TODO: error handling
		}
		
		factory.subscribe = function(clientObjectId, topics, successHandler, errorHandler) {
			// Example: topics = [{topicName: '/isctest/client/#', qos: 2}]
			var ret = { 
				success: true, 
				error: '', 
				topics: [
					{topicName: '/isctest/client/#', qos: 2}
				]
			};
			if (typeof successHandler === 'function') {
				successHandler.call(this, ret);
			}
			// TODO: error handling
		}
		
		return factory;
	}]); 
})();