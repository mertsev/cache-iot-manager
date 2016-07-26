(function() {
  angular.module('Sensors').controller('SendMessageController', [ '$rootScope', '$scope', function($rootScope, $scope) {
    var ctrl = this;

    ctrl.connected = false;
    ctrl.connectionID = '';

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
    	
      alert('message');
    }
    
  }]);
})();