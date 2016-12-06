(function() {
  angular.module('Sensors').controller('SendMessageController', [ '$rootScope', '$scope', 'sendmessageREST', function($rootScope, $scope, sendmessageREST) {
    var ctrl = this;

    ctrl.connected = false;
    ctrl.connectionID = '';
    ctrl.topicPrefix = null;

    // it's a second modal
    $rootScope.$on('ShowModal', function(event, data) {
      if (data.numberOfModal === 3) {
      $('#SendMessageModal').modal('show');
    }
    });

    $rootScope.$on('ConnectionEvent', function(event, data) {
      ctrl.connected = data.connected;
      ctrl.connectionID = data.connectionID;
    }); 

    ctrl.sendMessage = function() {
    	      sendmessageREST.send(
              ctrl.connectionID,
              {topicName: $scope.meslink, qos: 2, retain: 1, content: $scope.messagetext},
              function(result) {
                if (typeof result === 'object') {
                  if (!result.success) {
                    // error
                    $scope.ConnErrMsg = "Server error while subscribing for MQTT Client: " + result.error;
                    console.log('Server error while subscribing for MQTT Client:\n' + result.error);
                  }
                  else {
                    // success
                    $rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 1, Text: "Message sending is successful"})
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
              });
    }
    
  }]);
})();