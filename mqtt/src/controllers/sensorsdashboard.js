(function() {
  angular.module('Sensors').controller('DashboardController', [ '$scope', function($rootScope, $scope) {
    var ctrl = this;

    ctrl.isEnabled = false;

    ctrl.ToggleDashboard = function() {
      console.log('111');
      if (!ctrl.isEnabled) {
        console.log('222');
        ctrl.isEnabled = true;
        document.getElementById("sensors").setAttribute("src", "http://localhost:57772/dsw/index.html#/d/Sensors/Sensors.dashboard?ns=MQTT&widget=0&height=384");
      }
      else {
      console.log('333');
        ctrl.isEnabled = false;
        document.getElementById("sensors").setAttribute("src", "");
      }
    }

    $rootScope.$on('ConnectionEvent', function(event, data) {
      console.log('000');
      ctrl.ToggleDashboard();        
    });

    }]);
})();