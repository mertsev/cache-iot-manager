(function() {
  angular.module('Sensors').controller('SubscriptionController', [ '$rootScope', '$scope', function($rootScope, $scope) {
    var ctrl = this;

    // it's a second modal
    $rootScope.$on('ShowModal', function(event, data) {
      if (data.numberOfModal === 2) {
      $('#SubscribeModal').modal('show');
    }
    });
    


    }]);
})();