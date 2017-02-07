
(function() {
	angular.module('Sensors').controller('ConnectionController', [ '$rootScope', '$scope', 'connectionREST', function($rootScope, $scope, connectionREST) {
		var ctrl = this;
		ctrl.clientID = null;
		ctrl.topicPrefix = null;
		ctrl.connectionID = '';
		ctrl.connected = false;
		$scope.ConnErrMsg = "";

		var loaded = sessionStorage.getItem('loaded');
		if(loaded) {
        	$rootScope.$emit('Reload');
        }


		// if we get data in other layout
		$rootScope.$on('SubscriptionEvent', function(event, data, type) {
			ctrl.topicPrefix = data.topic;
			if (type == 1)
				var result = startSubscribe();
			else
				var result = stopSubscribe();
			if (result === 1) {
				if (type == 1)
    				$rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 1, Header: "Subscription", Text: "You subscribe to " + $scope.link});
    			else
    				$rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 1, Header: "Subscription", Text: "You unsubscribe to " + $scope.link});
    		}
    		else {
    			$rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Subscription", Text: "Failed: " + result});
    		}
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
				[{topicFilter: ctrl.topicPrefix, qos: 2}],
				function(result) {
					if (typeof result === 'object') {
						if (!result.success) {
							// error
							$scope.ConnErrMsg = "Server error while subscribing for MQTT Client: " + result.error;
							console.log('Server error while subscribing for MQTT Client:\n' + result.error);
						}
						else {
							// success
							ctrl.connected = true;
							var $winArea = $('#window-area');
      						$winArea.delay(100).fadeOut('slow');
							$rootScope.$emit('ConnectionEvent', { connected: ctrl.connected, connectionID: ctrl.connectionID });
							$scope.ConnErrMsg = '';
						}
					}
					else {
						// error
						$scope.ConnErrMsg = "Unexpected return value in startSubscribe(): \"" + result + "\"";
						console.log('Unexpected return value in startSubscribe(): \'' + result + '\'');
					}
				},
				function(error) {
					// error
					$scope.ConnErrMsg = "Error while subscribing for MQTT Client: " + error;
					console.log('Error while subscribing for MQTT Client:\n' + error);
				}
			);
			if ($scope.ConnErrMsg == '') {
				return 1;
			}
			else {
				return $scope.ConnErrMsg;
			}
		}
		var stopSubscribe = function() {
			connectionREST.subscribe(
				ctrl.connectionID,
				[{topicFilter: ctrl.topicPrefix, qos: 2}],
				function(result) {
					if (typeof result === 'object') {
						if (!result.success) {
							// error
							$rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Unsubscription", Text: "Server error while unsubscribing for MQTT Client: " + result.error});
							console.log('Server error while unsubscribing for MQTT Client:\n' + result.error);
						}
						else {
							// success
							$scope.ConnErrMsg = '';
						}
					}
					else {
						// error
						$rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Unsubscription", Text: "Unexpected return value in stopSubscribe(): \"" + result + "\""});
						console.log('Unexpected return value in stopSubscribe(): \'' + result + '\'');
					}
				},
				function(error) {
					// error
					$rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Unsubscription", Text: "Error while unsubscribing for MQTT Client: " + error});
					console.log('Error while unsubscribing for MQTT Client:\n' + error);
				}
			);
			if ($scope.ConnErrMsg == '') {
				return 1;
			}
			else {
				return $scope.ConnErrMsg;
			}
		}
		// start getting data
		ctrl.start = function() {
			if (!ctrl.connected && ctrl.connectionID === '') {
				connectionREST.connect(
					ctrl.clientID,
					function(result) {
						if (typeof result === 'object') {
							if (result.success) {
								// success
								sessionStorage.setItem('loaded', true);
								ctrl.connectionID = result.clientObject;
								startSubscribe();
							}
							else {
								// error
								$scope.ConnErrMsg = "Server error while connecting to MQTT Client: " + result.error;
								console.log('Server error while connecting to MQTT Client:\n' + result.error);
							}
						}
						else {
							// error
							$scope.ConnErrMsg = "Unexpected return value in start(): \"" + result + "\"";
							console.log('Unexpected return value in start(): \'' + result + '\'')
						}
					},
					function(error) {
						// error
						$scope.ConnErrMsg = "Error while starting MQTT Client:\n" + error;
						console.log('Error while starting MQTT Client:\n' + error);
					}
				);
			}
		}
	}]);
})();