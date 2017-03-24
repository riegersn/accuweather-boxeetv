/**
 * control.js
 * accuweather/control.js
 */

var DataType = {
  JSON: 2,
  XML: 1,
  PLAIN: 0
}

var weatherDataUri = "http://boxee.accu-weather.com/widget/boxee/weather-data.asp?location="
var videoDataUri = "http://api.brightcove.com/services/library?command=find_playlist_by_reference_id&output=json&token=skcadD-XB0y4Tq94r8v0U4QHU9rX20oKIf_7mBDHeBE.&reference_id="

function print(item1, item2) {
  if (item2 === undefined)
    boxeeAPI.logInfo('@accuweather[' + arguments.callee.caller.name + '] ' + item1);
  else
    boxeeAPI.logInfo('@accuweather[' + item1 + '] ' + item2);
}

function handleResponse(type, responseText) {
  if (type === DataType.XML) {
    responseText = boxeeAPI.xmlToJson(responseText)
    responseText = eval('(' + responseText + ')');
  }
  else if (type === DataType.JSON)
    responseText = eval('(' + responseText + ')');

  return responseText;
}

function get(url, type, onComplete, onComplete2) {
  print('url=' + url);

  var request = new XMLHttpRequest();
  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      var response = handleResponse(type, request.responseText);
      onComplete(request.status, response, onComplete2)
    }
  }

  request.open("GET", url, true);
  request.send();
}

function currentForcast(postal, metric, callback) {
  var url = weatherDataUri + postal + "&metric=" + (metric ? "1" : "0");
  get(url, DataType.XML, handle_currentForcast, callback);
}

function handle_currentForcast(status, response, callback) {
  var result = {
    'isOk': false,
    message: 'ok',
    data: {}
  };

  try {
    if (status !== 200 || response === undefined || response.adc_database === undefined || !response || response.adc_database.failure !== undefined) {
      print('request failed');
      print('status: ' + status);
      print('response: ' + JSON.stringify(response));
      result.message = "Ooops... we had an error loading the weather forecast.\n" + response.adc_database.failure;
      callback(result);
      return;
    }

    result.isOk = true;
    var data = result.data;

    var weather = response.adc_database;
    data.locationLabel = weather.local.city + ', ' + weather.local.adminArea._code + ' ' + weather.local.postalCode.__text;
    data.current = weather.currentconditions;
    data.fiveDay = weather.forecast.day;

    //add sunrise & sunset data to the current conditions item
    data.current.sunrise = data.fiveDay[0].sunrise;
    data.current.sunset = data.fiveDay[0].sunset;

    //advisories
    data.advisory = parseInt(weather.watchwarnareas._isactive);
    data.advisoryType = weather.watchwarnareas.warningtype;
  }
  catch (e) {
    result.isOk = false;
    print('request failed');
    print('status: ' + status);
    print('error: ' + e.message);
    print('response: ' + JSON.stringify(response));
    result.message = "Ooops... we had an error loading the weather forecast.\nPlease try again later.";
  }

  callback(result);
}
