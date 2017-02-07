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
                    $rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Send message", Text: "Message sending is failed"});
                  }
                  else {
                    // success
                    $rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 1, Header: "Send message", Text: "Message sending is successful"});
                  }
                }
                else {
                  // error
                  $rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Send message", Text: "Message sending is failed: \"" + result + "\""});
                }
              },
              function(error) {
                // error
                $rootScope.$emit('ShowModal', { numberOfModal: 1, Type: 3, Header: "Send message", Text: "Message sending is failed: " + error});
              });
    }
    
  }]);
})();