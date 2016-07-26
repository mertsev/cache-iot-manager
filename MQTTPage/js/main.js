 window.onload = function () {
    var $preloader = $('#page-preloader'),
        $spinner   = $preloader.find('.spinner');
    $spinner.fadeOut();
    $preloader.delay(100).fadeOut('slow');
};


(function() {
  var app = angular.module('Sensors', [ ]);
})();


/*
// getting data source
var app = angular.module('MQTTApp', []);

 app.factory('sensorsREST', [ '$http', function($http) {
  var factory = {};

  factory.baseUrl = '/rest/json/';

  factory.connect = function(clientid) {
   return { success: true, error: '', clientObject: 1 };
  }

  factory.disconnect = function(clientObjectId) {
   return { success: true, error: '' };
  }

  factory.subscribe = function(clientObjectId, topics) {
   // Example: topics = [{topicName: '/isctest/client/#', qos: 2}]
   return { success: true, error: '', topics: [
      {topicFilter: '/isctest/client/#', qos: 2}
     ]};
  }

  return factory;
 }]);

app.service('Services', [ 'sensorsREST', function(sensorsREST) {
  this.connect = function(userId) {
    var data = sensorsREST.connect(userId);
    if (data.success)
    {
      this.ShowNotice("Connection", "Connection complete.");
      var $winArea = $('#window-area');
      $winArea.delay(100).fadeOut('slow');
      return data.clientObj;
    }
    $('#ConnErrMsg').html('Connection failed: ' + data.error);
    return false;
  };

  this.disconnect = function(userId) {
    data = sensorsREST.disconnect(userId);
    if (data.success)
    {
      var $winArea = $('#window-area');
      $winArea.delay(100).fadeIn('slow');
      return true;
    }
    this.ShowNotice("Disconnection", "Disconnection failed: " + data.error);
    return false;
  };

  this.subscribe = function() {};

  this.ShowNotice = function(nHead, nText, nType) {
    if (nHead == undefined) {
      nHead = "Title";
    }
    if (nText == undefined) {
      nText = "Text";
    }
    if (nType == undefined) {
      nType = 1;
    }
    if (nType == 3) {
      $('#modalType').attr('class', 'modal-header modal-error');
    } else if (nType == 2) {
      $('#modalType').attr('class', 'modal-header modal-warning');
    } else {
      $('#modalType').attr('class', 'modal-header modal-info');
    }
    $('#noticeHeader').html(nHead);
    $('#noticeText').html(nText);
    $('#NoticeModal').modal('show');
  };
}]);
app.controller('ConnectionController', [ '$scope', 'Services', function($scope, Services) {
  $scope.ClientId;
  $scope.TopicName;

  $scope.getClientId = function() { return this.ClientId};
  $scope.setClientId = function(newClientId) { this.ClientId = newClientId};

  $scope.getTopicName = function() { return this.TopicName};
  $scope.setTopicName = function(newTopicName) { this.TopicName = newTopicName};

  $scope.data = "";
  $scope.start = function() {
    console.log($scope.ClientId);
    var data = Services.connect($scope.ClientId);
    if (data)
    {
      $scope.setClientId(data)     
    }
  }
  $scope.stop = function() {
    var data = Services.disconnect($scope.getClientId());
    if (data)
    {
      //
    }
  }

  
  
  
  $scope.OpenSubscribeMolad = function() {
    $('#SubscribeModal').modal('show');
  }
  $scope.OpenSendMessageModal = function() {
    $('#SendMessageModal').modal('show');
  }
  // Subscribe
  $scope.subscribe = function() {}
    var topics = $scope.Topics.split(", ");
    var dataObjs = new Array();
    for (var i=0; i<topics.length; i++) {
      dataObjs.push({"topicFilter": topics[i], "qos": "2"})
    }
    var data = Services.connect($scope.getClientId(), dataObjs);
    if (data.success)
    {
      $scope.setTopicName(data.topics);
      var bufstr = data.topics[0].topicFilter;
      for (var i=1; i<data.topics.length; i++) {
        bufstr += ", " + data.topics[i].topicFilter;
      }
      $scope.ShowNotice('Subscribe', 'Subscribe successfully complete! \nYou are subscribed to: ' + bufstr + ".");
    


  
    // Getting array of topics
    var topics = topics.split(", ");
    var dataObjs = new Array();
    for (var i=0; i<topics.length; i++) {
      dataObjs.push({"topicFilter": topics[i], "qos": "2"})
    }
    $http({
      method: 'POST',
      headers: "",//{ 'Content-Type': 'application/json' },
      url: "../../rest/json/subscribe/" + $scope.ClientId,
      data: dataObjs
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ShowNotice('Subscribe error', data.error, 3);
        return false;
      }
      var bufstr = data.topics[0].topicFilter;
      for (var i=1; i<data.topics.length; i++) {
        bufstr += ", " + data.topics[i].topicFilter;
      }
      $scope.ShowNotice('Subscribe', 'Subscribe successfully complete! \nYou are subscribed to: ' + bufstr + ".");
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Subscribe error', data.error, 3);
    });
  }
  

  // Unubscribe
  $scope.unsubscribe = function() {
    // Getting array of topics
    var topics = $scope.link.split(", ");
    var dataObjs = new Array();
    for (var i=0; i<topics.length; i++) {
      dataObjs.push({"topicFilter": topics[i], "qos": "2"})
    }
    $http({
      method: 'POST',
      headers: "",//{ 'Content-Type': 'application/json' },
      url: "../../rest/json/unsubscribe/" + $scope.ClientObj.clientObject,
      data: dataObjs
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ShowNotice('Unsubscribe error', data.error, 3);
        return false;
      }
      $scope.ShowNotice('Subscribe', 'Unubscribe successfully complete! \nYou are unsubscribed to: ' + $scope.link + ".");
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Unsubscribe error', data.error, 3);
    });
    
  }
  

  $scope.PublishMessage = function() {
    // Getting array of topics
    $http({
      method: 'POST',
      headers: "",//{ 'Content-Type': 'application/json' },
      url: "../../rest/json/subscribe/" + $scope.ClientId,
      data: $scope.sendMessageForm.meslink.value
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ShowNotice('Subscribe error', data.error, 3);
        return false;
      }
      var bufstr = data.topics[0].topicFilter;
      for (var i=1; i<data.topics.length; i++) {
        bufstr += ", " + data.topics[i].topicFilter;
      }
      $scope.ShowNotice('Subscribe', 'Subscribe successfully complete! \nYou are subscribed to: ' + bufstr + ".");
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Subscribe error', data.error, 3);
    });
    
  }

  $scope.GetMessages = function() {
    $http({
      method: 'GET',
      url: "mes2.html"
    }).success(function(data, status, header, config) {
      $scope.myData = data;
      $scope.ShowNotice('Data', 'The data was successfully loaded.');
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Data', 'Error loading data.', 3);
  });
  
  }
  

}]);
 */