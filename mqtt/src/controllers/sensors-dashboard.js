(function() {
  angular.module('Sensors').controller('DashboardController', [ '$scope', function($rootScope, $scope) {
    var ctrl = this;

    ctrl.connected = false;
    ctrl.connectionID = '';

    $rootScope.$on('ConnectionEvent', function(event, data) {
      ctrl.connected = data.connected;
      ctrl.connectionID = data.connectionID;
      if (ctrl.connected == false)
      	document.getElementById("sensors").setAttribute("src", "");
      else
      	document.getElementById("sensors").setAttribute("src", "http://localhost:57772/dsw/index.html#/d/Sensors/Sensors.dashboard?ns=MQTT&widget=0&height=384");
    });

    }]);
})();