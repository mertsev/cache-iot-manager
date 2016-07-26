(function() {
	angular.module('Sensors').controller('ConnectionController', [ '$rootScope', 'connectionREST', function($rootScope, connectionREST) {
		var ctrl = this;
		ctrl.clientID = null;
		ctrl.topicPrefix = null;
		ctrl.connectionID = '';
		ctrl.connected = false;

		// if we get data in other layout
		$rootScope.$on('SubscriptionEvent', function(event, data) {
			ctrl.topicPrefix = data.topic;
			startSubscribe();
		});
		// subscription event
		$rootScope.$on('ConnectionEvent', function(event, data) {
			ctrl.connected = data.connected;
			ctrl.connectionID = data.connectionID;
		});	
		// This is local, not visible from the controller
		var startSubscribe = function() {
			connectionREST.subscribe(
				ctrl.connectionID,
				[{topicFilter: ctrl.topicPrefix + '#', qos: 2}],
				function(result) {
					if (typeof result === 'object') {
						if (!result.success) {
							console.log('Server error while subscribing for MQTT Client:\n' + result.error);
						}
						else {
							ctrl.connected = true;
							$rootScope.$emit('ConnectionEvent', { connected: ctrl.connected, connectionID: ctrl.connnectionID });
						}
					}
					else {
						console.log('Unexpected return value in startSubscribe(): \'' + result + '\'')
					}
				},
				function(error) {
					console.log('Error while subscribing for MQTT Client:\n' + error);
				}
			);
		}

		ctrl.start = function() {
			if (!ctrl.connected && ctrl.connectionID === '') {
				connectionREST.connect(
					ctrl.clientID,
					function(result) {
						if (typeof result === 'object') {
							if (result.success) {
								ctrl.connectionID = result.clientObject;
								var $winArea = $('#window-area');
      							$winArea.delay(100).fadeOut('slow');
								startSubscribe();
							}
							else {
								console.log('Server error while connecting to MQTT Client:\n' + result.error);
							}
						}
						else {
							console.log('Unexpected return value in start(): \'' + result + '\'')
						}
					},
					function(error) {
						console.log('Error while starting MQTT Client:\n' + error);
					}
				);
			}
		}
	}]);
})();