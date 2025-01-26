import 'dart:convert';
import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

extension MapX<K, V> on Map<K, V> {
  bool updateKey({required K currentKey, required K newKey}) {
    if (containsKey(currentKey) && !containsKey(newKey)) {
      final value = this[currentKey] as V;
      final index = keys.toList().indexWhere((k) => k == currentKey);

      final mapEntriesList = entries.toList();
      mapEntriesList.removeAt(index);
      mapEntriesList.insert(index, MapEntry<K, V>(newKey, value));

      clear();

      addEntries(mapEntriesList);

      return true;
    } else {
      return false;
    }
  }
}

class TextFieldsForStringsMap extends StatelessWidget {
  final Map<String, String> values;
  final Function(Map<String, String> values) onChanged;
  final String? label;

  const TextFieldsForStringsMap(
    this.values,
    this.onChanged, {
    Key? key,
    this.label,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label == null ? const SizedBox.shrink() : Text(label!),
            Column(
              children: values
                  .map<String, Widget>((key, value) => MapEntry(
                      key,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: ObjectKey("${key}key"),
                                initialValue: key,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: "key",
                                ),
                                onChanged: (newValue) {
                                  Map<String, String> newValues = values;
                                  newValues.updateKey(
                                      currentKey: key, newKey: newValue);
                                  onChanged(newValues);
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Expanded(
                              child: TextFormField(
                                key: ObjectKey("${key}value"),
                                initialValue: value,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: "value",
                                ),
                                onChanged: (newValue) {
                                  Map<String, String> newValues = values;
                                  newValues[key] = newValue;
                                  onChanged(newValues);
                                },
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Map<String, String> newValues = values;
                                  newValues.remove(key);
                                  onChanged(newValues);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                      )))
                  .values
                  .toList()
                ..insert(
                    values.length,
                    values.containsKey("")
                        ? const SizedBox.shrink()
                        : MyTextButton(() {
                            Map<String, String> newValues = values;
                            newValues[""] = "";
                            onChanged(newValues);
                          }, "+")),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const MyTextButton(
    this.onPressed,
    this.text, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return (Colors.orangeAccent.withBlue(200));
            }
            if (states.contains(WidgetState.disabled)) {
              return (Colors.white38);
            }
            return (Colors.orangeAccent);
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return (Colors.black);
            }
            if (states.contains(WidgetState.disabled)) {
              return (Colors.grey);
            }
            return (Colors.black);
          },
        ),
      ),
      child: Text(text),
    ));
  }
}

extension Where on Map {
  Map where(
      bool Function(
        dynamic key,
        dynamic value,
      ) criteria) {
    Map<dynamic, dynamic> ret = {};
    forEach((key, value) {
      if (criteria(
        key,
        value,
      )) {
        ret[key] = value;
      }
    });
    return (ret);
  }
}

class MyPointer<T> {
  T value;
  MyPointer(this.value);
}

class MyField {
  bool init;
  bool advanced;
  String aPIName;
  dynamic valueHolder;
  dynamic defaultValue;
  String? info;
  Widget Function(
    MyField field,
  )? widgetBuilder;
  dynamic Function(
    dynamic holder,
  )? _getValue;
  Function(
    dynamic holder,
    dynamic value,
  )? _setValue;
  TextInputType? keyboardType;
  bool sendToMatomo;

  dynamic getValue(
    dynamic holder,
  ) {
    if (_getValue != null) {
      return (_getValue!(holder));
    }
    if (valueHolder is MyPointer || valueHolder is MyPointer<bool>) {
      if (defaultValue is bool) {
        return (valueHolder.value == null
            ? null
            : valueHolder.value
                ? "1"
                : "0");
      }
      if (defaultValue is DateTime) {
        return (valueHolder.value == null
            ? null
            : ((valueHolder.value as DateTime).millisecondsSinceEpoch / 1000)
                .round()
                .toString());
      }
    }
    if (valueHolder is TextEditingController) {
      return ((valueHolder as TextEditingController).text);
    }
    return ("unknown type for $aPIName in getValue");
  }

  setValue(
    dynamic holder,
    dynamic value,
  ) {
    if (_setValue != null) {
      _setValue!(
        holder,
        value,
      );
    }
    if (valueHolder is MyPointer) {
      if (defaultValue is bool) {
        valueHolder.value = value == null
            ? null
            : value == "1"
                ? true
                : false;
      }
      if (defaultValue is DateTime) {
        valueHolder.value = value == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                1000 * (int.tryParse(value) ?? 0));
      }
    }
    if (valueHolder is TextEditingController) {
      (valueHolder as TextEditingController).text = value ?? "";
    }
  }

  save(SharedPreferences sharedPreferences) {
    sharedPreferences.setString(aPIName, getValue(valueHolder) ?? "");
  }

  load(SharedPreferences sharedPreferences) {
    String? v = sharedPreferences.getString(aPIName);
    setValue(valueHolder, (v ?? "").isEmpty ? null : v);
  }

  MyField(
    this.init,
    this.advanced,
    this.aPIName,
    this.valueHolder, {
    this.defaultValue,
    this.info,
    this.widgetBuilder,
    dynamic Function(
      dynamic holder,
    )? getValue,
    Function(
      dynamic holder,
      dynamic value,
    )? setValue,
    this.keyboardType,
    this.sendToMatomo = true,
  }) {
    _getValue = getValue;
    _setValue = setValue;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? preferences;

  bool get dataStored {
    if (!(preferences?.containsKey("dataStored") ?? false)) {
      return (false);
    }
    return (preferences?.getBool("dataStored") ?? false);
  }

  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  bool advanced = false;

  Map<String, MyField> fields = {
    'site_url': MyField(
      true,
      false,
      'site_url',
      TextEditingController(),
      defaultValue: "https://matomo.example.com/matomo.php",
      info: 'The Matomo or piwik URL such as '
          'https://matomo.example.com/matomo.php . Not sent to Matomo.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.url,
      sendToMatomo: false,
    ),
    'idsite': MyField(
      true,
      false,
      'idsite',
      TextEditingController(),
      defaultValue: "1",
      info: 'The ID of the website we\'re tracking a visit/action for.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    '_id': MyField(
      true,
      false,
      '_id',
      TextEditingController(),
      defaultValue: "123456790123456",
      info:
          'The unique visitor ID, must be a 16 characters hexadecimal string. '
          'Every unique visitor must be assigned a different ID and this ID'
          ' must not change after it is assigned. If this value is not set '
          'Matomo (formerly Piwik) will still track visits, but the unique '
          'visitors metric might be less accurate.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'apiv': MyField(
      true,
      true,
      'apiv',
      TextEditingController(),
      defaultValue: "2",
      info: 'The parameter &apiv=1 defines the api version to use (currently '
          'always set to 1)',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'rec': MyField(
      true,
      true,
      'rec',
      MyPointer<bool?>(null),
      defaultValue: true,
      info: 'Required for tracking, must be set to one, eg, &rec=1.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'post_method': MyField(
      true,
      true,
      'post_method',
      MyPointer<bool?>(null),
      defaultValue: true,
      info:
          'Method can be either post or get except for bulk sending which must '
          'be sent through post method. Not sent to Matomo.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
      sendToMatomo: false,
    ),
    'bulk_size': MyField(
      true,
      true,
      'bulk_size',
      TextEditingController(),
      defaultValue: "5",
      info: '0 for direct send. Not sent to Matomo.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
      sendToMatomo: false,
    ),
    'token_auth': MyField(
      true,
      true,
      'token_auth',
      TextEditingController(),
      defaultValue: "12345678901234567890123456789012",
      info:
          '32 character authorization key used to authenticate the API request.'
          ' We recommend to create a user specifically for accessing the '
          'Tracking API, and give the user only write permission on the '
          'website(s).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'queuedtracking': MyField(
      true,
      true,
      'queuedtracking',
      MyPointer<bool?>(null),
      defaultValue: true,
      info:
          'When set to 0 (zero), the queued tracking handler won\'t be used and'
          ' instead the tracking request will be executed directly. This '
          'can be useful when you need to debug a tracking problem or want '
          'to test that the tracking works in general.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'send_image': MyField(
      true,
      true,
      'send_image',
      MyPointer<bool?>(null),
      defaultValue: true,
      info: 'If set to 0 (send_image=0) Matomo will respond with a HTTP 204 '
          'response code instead of a GIF image. This improves performance '
          'and can fix errors if images are not allowed to be obtained '
          'directly (eg Chrome Apps). Available since Matomo 2.10.0',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ping': MyField(
      true,
      true,
      'ping',
      MyPointer<bool?>(null),
      defaultValue: false,
      info:
          'If set to 1 (ping=1), the request will be a Heartbeat request which '
          'will not track any new activity (such as a new visit, new action'
          ' or new goal). The heartbeat request will only update the '
          'visit\'s total time to provide accurate "Visit duration" metric '
          'when this parameter is set. It won\'t record any other data. '
          'This means by sending an additional tracking request when the '
          'user leaves your site or app with &ping=1, you fix the issue '
          'where the time spent of the last page visited is reported as 0 '
          'seconds.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'bots': MyField(
      true,
      true,
      'bots',
      MyPointer<bool?>(null),
      defaultValue: false,
      info:
          'By default Matomo does not track bots. If you use the Tracking HTTP '
          'API directly, you may be interested in tracking bot requests. To'
          ' enable Bot Tracking in Matomo, set the parameter &bots=1 in '
          'your requests to matomo.php.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'debug': MyField(
      true,
      true,
      'debug',
      MyPointer<bool?>(null),
      defaultValue: false,
      info:
          'If Matomo server is configured with debug_on_demand = 1, debug can '
          'be set to 1',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'action_name': MyField(
      false,
      false,
      'action_name',
      TextEditingController(),
      defaultValue: "Help / Feedback",
      info:
          'The title of the action being tracked. It is possible to use slashes'
          ' / to set one or several categories for this action. For example'
          ', Help / Feedback will create the Action Feedback in the '
          'category Help.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'url': MyField(
      false,
      true,
      'url',
      TextEditingController(),
      defaultValue: "https://example.com/landing.html",
      info: 'The full URL for the current action.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.url,
    ),
    'rand': MyField(
      false,
      true,
      'rand',
      TextEditingController(),
      defaultValue: "12345678",
      info:
          'Meant to hold a random value that is generated before each request. '
          'Using it helps avoid the tracking request being cached by the '
          'browser or a proxy.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'urlref': MyField(
      false,
      true,
      'urlref',
      TextEditingController(),
      defaultValue: "https://example.com/greatArticle.html",
      info: 'The full HTTP Referrer URL. This value is used to determine how '
          'someone got to your website (ie, through a website, search '
          'engine or campaign).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.url,
    ),
    '_cvar': MyField(
      false,
      true,
      '_cvar',
      TextEditingController(),
      defaultValue:
          '{"1":["OS","iphone 5.0"],"2":["Matomo Mobile Version","1.6.2"],'
          '"3":["Locale","en::en"],"4":["Num Accounts","2"]}',
      info:
          'Visit or page scope custom variables. This is a JSON encoded string '
          'of the custom variable array (see '
          'https://developer.matomo.org/api-reference/tracking-api ).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    '_idvc': MyField(
      false,
      true,
      '_idvc',
      TextEditingController(),
      defaultValue: "15",
      info: 'The current count of visits for this visitor. To set this value '
          'correctly, it would be required to store the value for each '
          'visitor in your application (using sessions or persisting in a '
          'database). Then you would manually increment the counts by one '
          'on each new visit or "session", depending on how you choose to '
          'define a visit. This value is used to populate the report '
          'Visitors > Engagement > Visits by visit number.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    '_viewts': MyField(
      false,
      true,
      '_viewts',
      MyPointer<DateTime?>(null),
      defaultValue: DateTime.now(),
      info:
          'The UNIX timestamp of this visitor\'s previous visit. This parameter'
          ' is used to populate the report Visitors > Engagement > Visits '
          'by days since last visit.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    '_idts': MyField(
      false,
      true,
      '_idts',
      MyPointer<DateTime?>(null),
      defaultValue: DateTime.now(),
      info:
          'The UNIX timestamp of this visitor\'s first visit. This could be set'
          ' to the date where the user first started using your '
          'software/app, or when he/she created an account. This parameter '
          'is used to populate the Goals > Days to Conversion report.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    '_rcn': MyField(
      false,
      true,
      '_rcn',
      TextEditingController(),
      defaultValue: "The Best Noodles For Your Necklaces",
      info: 'The Campaign name (see Tracking Campaigns). Used to populate the '
          'Referrers > Campaigns report. Note: this parameter will only be '
          'used for the first pageview of a visit.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    '_rck': MyField(
      false,
      true,
      '_rck',
      TextEditingController(),
      defaultValue: "noodle,food,necklace",
      info:
          'The Campaign Keyword (see Tracking Campaigns). Used to populate the '
          'Referrers > Campaigns report (clicking on a campaign loads all '
          'keywords for this campaign). Note: this parameter will only be '
          'used for the first pageview of a visit.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'res': MyField(
      false,
      true,
      'res',
      TextEditingController(),
      defaultValue: "1280x1024",
      info: 'The resolution of the device the visitor is using, eg 1280x1024.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'h': MyField(
      false,
      true,
      'h',
      TextEditingController(),
      defaultValue: "18",
      info: 'The current hour (local time).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'm': MyField(
      false,
      true,
      'm',
      TextEditingController(),
      defaultValue: "30",
      info: 'The current minute (local time).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    's': MyField(
      false,
      true,
      's',
      TextEditingController(),
      defaultValue: "50",
      info: 'The current second (local time).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'fla': MyField(
      false,
      true,
      'fla',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Flash plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'java': MyField(
      false,
      true,
      'java',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Java plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'dir': MyField(
      false,
      true,
      'dir',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Director plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'qt': MyField(
      false,
      true,
      'qt',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Quicktime plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'realp': MyField(
      false,
      true,
      'realp',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Real Player plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'pdf': MyField(
      false,
      true,
      'pdf',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'PDF plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'wma': MyField(
      false,
      true,
      'wma',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Windows Media plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'gears': MyField(
      false,
      true,
      'gears',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Gears plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ag': MyField(
      false,
      true,
      'ag',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Silverlight plugin',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'cookie': MyField(
      false,
      true,
      'cookie',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'when set to 1, the visitor\'s client is known to support cookies.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ua': MyField(
      false,
      true,
      'ua',
      TextEditingController(),
      defaultValue: "HTC Mozilla/5.0 (Linux; Android 7.0; HTC 10 Build/NRD90M) "
          "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.83 "
          "Mobile Safari/537.36.",
      info: 'An override value for the User-Agent HTTP header field. The user '
          'agent is used to detect the operating system and browser used.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'lang': MyField(
      false,
      true,
      'lang',
      TextEditingController(),
      defaultValue: "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5",
      info: 'An override value for the Accept-Language HTTP header field. This '
          'value is used to detect the visitor\'s country if GeoIP is not '
          'enabled.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'uid': MyField(
      false,
      true,
      'uid',
      TextEditingController(),
      defaultValue: "bob@example.com",
      info: 'defines the User ID for this request. User ID is any non-empty '
          'unique string identifying the user (such as an email address or '
          'an username). To access this value, users must be logged-in in '
          'your system so you can fetch this user ID from your system, and '
          'pass it to Matomo. The User ID appears in the visits log, the '
          'Visitor profile, and you can Segment reports for one or several '
          'User ID (userId segment). When specified, the User ID will be '
          '"enforced". This means that if there is no recent visit with '
          'this User ID, a new one will be created. If a visit is found in '
          'the last 30 minutes with your specified User ID, then the new '
          'action will be recorded to this existing visit.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'cid': MyField(
      false,
      true,
      'cid',
      TextEditingController(),
      defaultValue: "1234567890123456",
      info:
          'defines the visitor ID for this request. You must set this value to '
          'exactly a 16 character hexadecimal string (containing only '
          'characters 01234567890abcdefABCDEF). We recommended setting the '
          'User ID via uid rather than use this cid.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'new_visit': MyField(
      false,
      true,
      'new_visit',
      MyPointer<bool?>(null),
      defaultValue: false,
      info:
          'If set to 1, will force a new visit to be created for this action. '
          'This feature is also available in JavaScript.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'dimension0': MyField(
      false,
      true,
      'dimension0',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension1': MyField(
      false,
      true,
      'dimension1',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension2': MyField(
      false,
      true,
      'dimension2',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension3': MyField(
      false,
      true,
      'dimension3',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension4': MyField(
      false,
      true,
      'dimension4',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension5': MyField(
      false,
      true,
      'dimension5',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension6': MyField(
      false,
      true,
      'dimension6',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension7': MyField(
      false,
      true,
      'dimension7',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension8': MyField(
      false,
      true,
      'dimension8',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension9': MyField(
      false,
      true,
      'dimension9',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'dimension10': MyField(
      false,
      true,
      'dimension10',
      TextEditingController(),
      defaultValue: "",
      info:
          '[0-999] A Custom Dimension value for a specific Custom Dimension ID '
          '(requires Matomo 2.15.1 + Custom Dimensions plugin see the '
          'Custom Dimensions guide). If Custom Dimension ID is 2 use '
          'dimension2=dimensionValue to send a value for this dimension. '
          'The configured Custom Dimension has to be in scope "Visit" for '
          'user or "Action".',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'link': MyField(
      false,
      true,
      'link',
      TextEditingController(),
      defaultValue: "https://example.com/out.html",
      info: 'An external URL the user has opened. Used for tracking outlink '
          'clicks. We recommend to also set the url parameter to this same '
          'value.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'download': MyField(
      false,
      true,
      'download',
      TextEditingController(),
      defaultValue: "https://example.com/file.zip",
      info:
          'URL of a file the user has downloaded. Used for tracking downloads. '
          'We recommend to also set the url parameter to this same value.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'search': MyField(
      false,
      true,
      'search',
      TextEditingController(),
      defaultValue: "nice noodles",
      info: 'The Site Search keyword. When specified, the request will not be '
          'tracked as a normal pageview but will instead be tracked as a '
          'Site Search request.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'search_cat': MyField(
      false,
      true,
      'search_cat',
      TextEditingController(),
      defaultValue: "food",
      info: 'when search is specified, you can optionally specify a search '
          'category with this parameter.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'search_count': MyField(
      false,
      true,
      'search_count',
      TextEditingController(),
      defaultValue: "3",
      info:
          'when search is specified, we also recommend setting the search_count'
          ' to the number of search results displayed on the results page. '
          'When keywords are tracked with &search_count=0 they will appear '
          'in the "No Result Search Keyword" report.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'pv_id': MyField(
      false,
      true,
      'pv_id',
      TextEditingController(),
      defaultValue: "123456",
      info:
          'Accepts a six character unique ID that identifies which actions were'
          ' performed on a specific page view. When a page was viewed, all '
          'following tracking requests (such as events) during that page '
          'view should use the same pageview ID. Once another page was '
          'viewed a new unique ID should be generated. Use [0-9a-Z] as '
          'possible characters for the unique ID.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'idgoal': MyField(
      false,
      true,
      'idgoal',
      TextEditingController(),
      defaultValue: "0",
      info:
          'If specified, the tracking request will trigger a conversion for the'
          ' goal of the website being tracked with this ID.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'revenue': MyField(
      false,
      true,
      'revenue',
      TextEditingController(),
      defaultValue: "15",
      info: 'A monetary value that was generated as revenue by this goal '
          'conversion. Only used if idgoal is specified in the request. Can'
          ' also be the grand total for the ecommerce order (required when '
          'tracking an ecommerce order).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'gt_ms': MyField(
      false,
      true,
      'gt_ms',
      TextEditingController(),
      defaultValue: "123",
      info: 'The amount of time it took the server to generate this action, in '
          'milliseconds. This value is used to process the Page speed '
          'report Avg. generation time column in the Page URL and Page '
          'Title reports, as well as a site wide running average of the '
          'speed of your server. Note: when using the JavaScript tracker '
          'this value is set to the time for server to generate response + '
          'the time for client to download response.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'cs': MyField(
      false,
      true,
      'cs',
      TextEditingController(),
      defaultValue: "utf-8",
      info: 'The charset of the page being tracked. Specify the charset if the '
          'data you send to Matomo is encoded in a different character set '
          'than the default utf-8.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ca': MyField(
      false,
      true,
      'ca',
      MyPointer<bool?>(null),
      defaultValue: false,
      info: 'Stands for custom action. &ca=1 can be optionally sent along any '
          'tracking request that isn\'t a page view. For example it can be '
          'sent together with an event tracking request '
          'e_a=Action&e_c=Category&ca=1. The advantage being that should '
          'you ever disable the event plugin, then the event tracking '
          'requests will be ignored vs if the parameter is not set, a page '
          'view would be tracked even though it isn\'t a page view. For '
          'more background information check out #16570. Do not use this '
          'parameter together with a ping=1 tracking request.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'pf_net': MyField(
      false,
      true,
      'pf_net',
      TextEditingController(),
      defaultValue: "50",
      info:
          '[milliseconds] Network time. How long it took to connect to server.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'pf_srv': MyField(
      false,
      true,
      'pf_srv',
      TextEditingController(),
      defaultValue: "70",
      info:
          '[milliseconds] Server time. How long it took the server to generate '
          'page.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'pf_tfr': MyField(
      false,
      true,
      'pf_tfr',
      TextEditingController(),
      defaultValue: "15",
      info: '[milliseconds] Transfer time. How long it takes the browser to '
          'download the response from the server',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'pf_dm1': MyField(
      false,
      true,
      'pf_dm1',
      TextEditingController(),
      defaultValue: "10",
      info: '[milliseconds] Dom processing time. How long the browser spends '
          'loading the webpage after the response was fully received until '
          'the user can starting interacting with it.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'pf_dm2': MyField(
      false,
      true,
      'pf_dm2',
      TextEditingController(),
      defaultValue: "15",
      info: '[milliseconds] Dom completion time. How long it takes for the '
          'browser to load media and execute any Javascript code listening '
          'for the DOMContentLoaded event.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'pf_onl': MyField(
      false,
      true,
      'pf_onl',
      TextEditingController(),
      defaultValue: "5",
      info:
          '[milliseconds] Onload time. How long it takes the browser to execute'
          ' Javascript code waiting for the window.load event.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'e_c': MyField(
      false,
      true,
      'e_c',
      TextEditingController(),
      defaultValue: "Books",
      info: 'The event category. Must not be empty. (eg. Videos, Music, '
          'Games...)',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'e_a': MyField(
      false,
      true,
      'e_a',
      TextEditingController(),
      defaultValue: "Read",
      info:
          'The event action. Must not be empty. (eg. Play, Pause, Duration, Add'
          ' Playlist, Downloaded, Clicked...)',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'e_n': MyField(
      false,
      true,
      'e_n',
      TextEditingController(),
      defaultValue: "noodles from around the world",
      info: 'The event name. (eg. a Movie name, or Song name, or File name...)',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'e_v': MyField(
      false,
      true,
      'e_v',
      TextEditingController(),
      defaultValue: "10",
      info:
          'The event value. Must be a float or integer value (numeric), not a '
          'string.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
    ),
    'c_n': MyField(
      false,
      true,
      'c_n',
      TextEditingController(),
      defaultValue: "no crispy noodles",
      info:
          'The name of the content. For instance \'Ad Foo Bar\'. Required for '
          'content tracking.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'c_p': MyField(
      false,
      true,
      'c_p',
      TextEditingController(),
      defaultValue: "/noodles.epub",
      info:
          'The actual content piece. For instance the path to an image, video, '
          'audio, any text',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'c_t': MyField(
      false,
      true,
      'c_t',
      TextEditingController(),
      defaultValue: "https://example.com/landing.html",
      info: 'The target of the content. For instance the URL of a landing page',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.url,
    ),
    'c_i': MyField(
      false,
      true,
      'c_i',
      TextEditingController(),
      defaultValue: "click",
      info: 'The name of the interaction with the content. For instance a '
          '\'click\'',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ec_id': MyField(
      false,
      true,
      'ec_id',
      TextEditingController(),
      defaultValue: "123456",
      info:
          'The unique string identifier for the ecommerce order (required when '
          'tracking an ecommerce order). Must set idgoal=0.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ec_items': MyField(
      false,
      true,
      'ec_items',
      TextEditingController(),
      defaultValue:
          '[["item1 SKU","item1 name","item1 category",11.1111,2],["item2 SKU",'
          '"item2 name","",0,1]]',
      info:
          'Items in the Ecommerce order. This is a JSON encoded array of items.'
          ' Each item is an array with the following info in this order:\n'
          'item sku (required),\n'
          'item name (or if not applicable, set it to an empty string),\n'
          'item category (or if not applicable, set it to an empty string),\n'
          'item price (or if not applicable, set it to 0),\n'
          'item quantity (or if not applicable, set it to 1).\n'
          'An example value of ec_items would be: '
          '%5B%5B%22item1%20SKU%22%2C%22item1%20name%22%2C%22item1%20'
          'category%22%2C11.1111%2C2%5D%2C%5B%22item2%20SKU%22%2C%22'
          'item2%20name%22%2C%22%22%2C0%2C1%5D%5D (URL decoded version is: '
          '[["item1 SKU","item1 name","item1 category",11.1111,2],["item2 '
          'SKU","item2 name","",0,1]]).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ec_st': MyField(
      false,
      true,
      'ec_st',
      TextEditingController(),
      defaultValue: "10",
      info: 'The sub total of the order; excludes shipping.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ec_tx': MyField(
      false,
      true,
      'ec_tx',
      TextEditingController(),
      defaultValue: "2",
      info: 'Tax Amount of the order',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ec_sh': MyField(
      false,
      true,
      'ec_sh',
      TextEditingController(),
      defaultValue: "3",
      info: 'Shipping cost of the Order',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ec_dt': MyField(
      false,
      true,
      'ec_dt',
      TextEditingController(),
      defaultValue: "1",
      info: 'Discount offered',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    '_ects': MyField(
      false,
      true,
      '_ects',
      MyPointer<DateTime?>(null),
      defaultValue: DateTime.now(),
      info: 'The UNIX timestamp of this customer\'s last ecommerce order. This '
          'value is used to process the "Days since last order" report.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'cip': MyField(
      false,
      true,
      'cip',
      TextEditingController(),
      defaultValue: "123.123.123.123",
      info: 'Override value for the visitor IP (both IPv4 and IPv6 notations '
          'supported).',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'cdt': MyField(
      false,
      true,
      'cdt',
      MyPointer<DateTime?>(null),
      defaultValue: DateTime.now(),
      info:
          'Override for the datetime of the request (normally the current time '
          'is used). This can be used to record visits and page views in '
          'the past. The expected format is either a datetime such as: '
          '2011-04-05 00:11:42 (remember to URL encode the value!), or a '
          'valid UNIX timestamp such as 1301919102. The datetime must be '
          'sent in UTC timezone. Note: if you record data in the past, you '
          'will need to force Matomo to re-process reports for the past '
          'dates. If you set cdt to a datetime older than 24 hours then '
          'token_auth must be set. If you set cdt with a datetime in the '
          'last 24 hours then you don\'t need to pass token_auth.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'country': MyField(
      false,
      true,
      'country',
      TextEditingController(),
      defaultValue: "us",
      info:
          'An override value for the country. Should be set to the two letter '
          'country code of the visitor (lowercase), eg fr, de, us.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'region': MyField(
      false,
      true,
      'region',
      TextEditingController(),
      defaultValue: "US",
      info: 'An override value for the region. Should be set to a ISO 3166-2 '
          'region code, which are used by MaxMind\'s and DB-IP\'s GeoIP2 '
          'databases. See here for a list of them for every country.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'city': MyField(
      false,
      true,
      'city',
      TextEditingController(),
      defaultValue: "Seattle",
      info:
          'An override value for the city. The name of the city the visitor is '
          'located in, eg, Tokyo.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'lat': MyField(
      false,
      true,
      'lat',
      TextEditingController(),
      defaultValue: "47.6062",
      info: 'An override value for the visitor\'s latitude, eg 22.456.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'long': MyField(
      false,
      true,
      'long',
      TextEditingController(),
      defaultValue: "122.3321",
      info: 'An override value for the visitor\'s longitude, eg 22.456.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ma_id': MyField(
      false,
      true,
      'ma_id',
      TextEditingController(),
      defaultValue: "123456",
      info: '(required) A unique id that is always the same while playing a '
          'media. As soon as the played media changes (new video or audio '
          'started), this ID has to change.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ma_re': MyField(
      false,
      true,
      'ma_re',
      TextEditingController(),
      defaultValue: "https://example.com/noodle.avi",
      info: '(required) The URL of the media resource.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.url,
    ),
    'ma_mt': MyField(
      false,
      true,
      'ma_mt',
      TextEditingController(),
      defaultValue: "video",
      info: '(required) video or audio depending on the type of the media.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ma_ti': MyField(
      false,
      true,
      'ma_ti',
      TextEditingController(),
      defaultValue: "Noodles Of The World",
      info: 'The name / title of the media.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ma_pn': MyField(
      false,
      true,
      'ma_pn',
      TextEditingController(),
      defaultValue: "video_player 2.2.7",
      info: 'The name of the media player, for example html5.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
    'ma_st': MyField(
      false,
      true,
      'ma_st',
      TextEditingController(),
      defaultValue: "5",
      info:
          'The time in seconds for how long a user has been playing this media.'
          ' This number should typically increase when you send a media '
          'tracking request. It should be 0 if the media was only visible/'
          'impressed but not played. Do not increase this number when a '
          'media is paused.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'ma_le': MyField(
      false,
      true,
      'ma_le',
      TextEditingController(),
      defaultValue: "65",
      info:
          'The duration (the length) of the media in seconds. For example if a '
          'video is 90 seconds long, the value should be 90.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'ma_ps': MyField(
      false,
      true,
      'ma_ps',
      TextEditingController(),
      defaultValue: "10",
      info:
          'The progress / current position within the media. Defines basically '
          'at which position within the total length the user is currently '
          'playing.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'ma_ttp': MyField(
      false,
      true,
      'ma_ttp',
      TextEditingController(),
      defaultValue: "5",
      info: 'Defines after how many seconds the user has started playing this '
          'media. For example a user might have seen the poster of the '
          'video for 30 seconds before a user actually pressed the play '
          'button.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'ma_w': MyField(
      false,
      true,
      'ma_w',
      TextEditingController(),
      defaultValue: "500",
      info:
          'The resolution width of the media in pixels. Only recommended being '
          'set for videos.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'ma_h': MyField(
      false,
      true,
      'ma_h',
      TextEditingController(),
      defaultValue: "500",
      info:
          'The resolution height of the media in pixels. Only recommended being'
          ' set for videos.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
    ),
    'ma_fs': MyField(
      false,
      true,
      'ma_fs',
      MyPointer<bool?>(null),
      defaultValue: false,
      info:
          'Should be 0 or 1 and defines whether the media is currently viewed '
          'in full screen. Only recommended being set for videos.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: null,
    ),
    'ma_se': MyField(
      false,
      true,
      'ma_se',
      TextEditingController(),
      defaultValue: "5,7,9,12",
      info:
          'An optional comma separated list of which positions within a media a'
          ' user has played. For example if the user has viewed position '
          '5s, 10s, 15s and 35s, then you would need to send 5,10,15,35. We'
          ' recommend to round to the next 5 seconds and not send a value '
          'for each second. Internally, Matomo may round to the next 15 or '
          '30 seconds. For performance optimisation we recommend not '
          'sending the same position twice. Meaning if you have sent '
          'ma_se=10 there is no need to send later ma_se=10,20 but instead '
          'only ma_se=20.',
      widgetBuilder: null,
      getValue: null,
      setValue: null,
      keyboardType: TextInputType.text,
    ),
  };

  Map<String, String>? headers;
  Map<String, String>? persistentParameters;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      home: Scaffold(
        floatingActionButton: MatomoForever.isInitialized
            ? MyTextButton(trackAction, "track action")
            : const SizedBox.shrink(),
        appBar: AppBar(
          titleSpacing: 3.0,
          title: const Text('matomo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                saveAll();
                _snackMessage("saved");
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.restore_page),
              onPressed: dataStored
                  ? () {
                      loadAll();
                      _snackMessage("loaded");
                      setState(() {});
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _snackConfirm(
                    message: "Clear all data?",
                    onPostivePressed: () {
                      clearAll();
                      _snackMessage("cleared");
                      setState(() {});
                    },
                    positiveBtnText: 'Yes',
                    negativeBtnText: 'No');
              },
            ),
            const Center(
              child: Text(
                "advanced",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                  onChanged: (value) {
                    setState(() {
                      advanced = value;
                    });
                  },
                  value: advanced),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  color: Colors.orangeAccent.withAlpha(50),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text("Init data"),
                        Column(
                          children: fields
                              .where((key, value) =>
                                  (value as MyField).init &&
                                  (!value.advanced || advanced))
                              .map<String, Widget>((key, value) {
                                return (MapEntry(
                                  key,
                                  buildWidgetFromField(value as MyField),
                                ));
                              })
                              .values
                              .toList(),
                        ),
                        !advanced
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  TextFieldsForStringsMap(
                                    persistentParameters ?? {},
                                    (Map<String, String>
                                        newPersistentParameters) {
                                      setState(() {
                                        persistentParameters =
                                            newPersistentParameters;
                                      });
                                    },
                                    label: "persistent parameters",
                                  ),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  headers?.containsKey("User-Agent") ??
                                          false ||
                                              kIsWeb ||
                                              !(Platform.isAndroid ||
                                                  Platform.isIOS)
                                      ? const SizedBox.shrink()
                                      : MyTextButton(
                                          () {
                                            headers ??= {};
                                            userAgent().then((value) {
                                              setState(() {
                                                headers?["User-Agent"] = value;
                                              });
                                            });
                                          },
                                          "Add HTTP user agent",
                                        ),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  TextFieldsForStringsMap(
                                    headers ?? {},
                                    (Map<String, String> newHeaders) {
                                      setState(() {
                                        headers = newHeaders;
                                      });
                                    },
                                    label: "HTTP headers",
                                  ),
                                ],
                              ),
                        MyTextButton(
                          initialize,
                          MatomoForever.isInitialized
                              ? "Re-initialize"
                              : "Initialize",
                        )
                      ],
                    ),
                  ),
                ),
                !MatomoForever.isInitialized
                    ? const Text("Please initialize")
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Card(
                              color: Colors.orangeAccent.withAlpha(50),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const Text("Action data"),
                                    Column(
                                      children: fields
                                          .where((key, value) =>
                                              !(value as MyField).init &&
                                              (!value.advanced || advanced))
                                          .map<String, Widget>((key, value) {
                                            return (MapEntry(
                                              key,
                                              buildWidgetFromField(
                                                  value as MyField),
                                            ));
                                          })
                                          .values
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void storeData() {}

  Widget myInfoButton(String? info) {
    return ((info ?? "").isEmpty
        ? const SizedBox.shrink()
        : IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _snackInfo(info!);
            },
          ));
  }

  Widget myTextField(
    TextEditingController controller,
    TextInputType? keyboardType,
    String label,
    String hint,
    String? info,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
            ),
          ),
        ),
        myInfoButton(info),
      ],
    );
  }

  Widget myDateTimePicker(
    MyPointer<DateTime?> dt,
    String? info,
    String label,
  ) {
    return Row(
      children: [
        Expanded(
          child: (DateTimeField(
            decoration: InputDecoration(
              labelText: label,
            ),
            onChanged: (value) {
              dt.value = value;
            },
            initialValue: dt.value,
            format: DateFormat("yyyy-MM-dd HH:mm"),
            onShowPicker: (context, currentValue) async {
              return await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100))
                  .then((value) async {
                final date = value;
                if (date != null) {
                  TimeOfDay? time;
                  if(context.mounted) {
                    time = await showTimePicker(
                      context: context,
                      initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                    );
                  }
                  return DateTimeField.combine(date, time);
                } else {
                  return currentValue;
                }
              });
            },
          )),
        ),
        myInfoButton(info),
      ],
    );
  }

  Widget mySwitch(
    bool defaultValue,
    String label,
    MyPointer<bool?> currentValue,
    String? info,
  ) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Switch(
              value: currentValue.value ?? defaultValue,
              activeColor: defaultValue && currentValue.value == null
                  ? Colors.grey
                  : null,
              trackColor: defaultValue
                  ? null
                  : WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        return (currentValue.value == null
                            ? Colors.grey
                            : Colors.black45);
                      },
                    ),
              onChanged: (value) {
                setState(() {
                  currentValue.value = value;
                });
              },
            ),
            myInfoButton(info),
          ],
        ),
      ],
    ));
  }

  Widget buildWidgetFromField(MyField field) {
    if (field.widgetBuilder != null) {
      return (field.widgetBuilder!(field));
    }
    if (field.valueHolder is MyPointer) {
      if (field.defaultValue is DateTime) {
        return myDateTimePicker(
          field.valueHolder,
          field.info,
          field.aPIName,
        );
      }
      if (field.defaultValue is bool) {
        return mySwitch(
          field.defaultValue,
          field.aPIName,
          field.valueHolder,
          field.info,
        );
      }
    }
    if (field.valueHolder is TextEditingController) {
      return myTextField(
        field.valueHolder,
        field.keyboardType,
        field.aPIName,
        field.defaultValue,
        field.info,
      );
    }
    return (Text("Unknown type for ${field.aPIName}"));
  }

  void _snackMessage(String message) {
    _messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _snackInfo(String message) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueAccent.withAlpha(230),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(
              Icons.info,
              color: Colors.white,
            ),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ]),
        ),
        duration: const Duration(milliseconds: 5000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _snackConfirm({
    String? message,
    void Function()? onPostivePressed,
    void Function()? onNegativePressed,
    String? positiveBtnText,
    String? negativeBtnText,
  }) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.yellowAccent.withAlpha(230),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(
              Icons.question_answer,
              color: Colors.black,
            ),
            Text(
              message ?? "",
              style: const TextStyle(color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                positiveBtnText == null
                    ? const SizedBox.shrink()
                    : MyTextButton(() {
                        if (onPostivePressed != null) {
                          onPostivePressed();
                        }
                        _messengerKey.currentState?.hideCurrentSnackBar();
                      }, positiveBtnText),
                negativeBtnText == null
                    ? const SizedBox.shrink()
                    : MyTextButton(() {
                        if (onNegativePressed != null) {
                          onNegativePressed();
                        }
                        _messengerKey.currentState?.hideCurrentSnackBar();
                      }, negativeBtnText),
              ],
            )
          ]),
        ),
        duration: const Duration(milliseconds: 5000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _snackAlert(String message) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.pinkAccent.withAlpha(230),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(
              Icons.ac_unit,
              color: Colors.orangeAccent,
            ),
            Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ]),
        ),
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showResult(bool success, String topic) {
    if (success) {
      _snackMessage("Completed $topic");
    } else {
      _snackAlert("Failed $topic");
    }
  }

  void initialize() {
    try {
      String? id = fields["_id"]!.getValue(fields["_id"]!.valueHolder);
      id = id?.isNotEmpty ?? false ? id : null;
      String? apiV = fields["apiv"]!.getValue(fields["apiv"]!.valueHolder);
      apiV = apiV?.isNotEmpty ?? false ? apiV : null;
      String? tokenAuth =
          fields["token_auth"]!.getValue(fields["token_auth"]!.valueHolder);
      tokenAuth = tokenAuth?.isNotEmpty ?? false ? tokenAuth : null;
      MatomoForever.init(
        fields["site_url"]!.getValue(fields["site_url"]!.valueHolder),
        int.tryParse(
                fields["idsite"]!.getValue(fields["idsite"]!.valueHolder)) ??
            0,
        id: id,
        apiV: apiV,
        rec: fields["rec"]!.getValue(fields["rec"]!.valueHolder) != "0",
        method: fields["post_method"]!.valueHolder.value ?? true
            ? MatomoForeverMethod.post
            : MatomoForeverMethod.get,
        bulkSize: int.tryParse(fields["bulk_size"]!
                .getValue(fields["bulk_size"]!.valueHolder)) ??
            0,
        tokenAuth: tokenAuth,
        headers: headers,
        persistentParameters: persistentParameters,
      );
      setState(() {});
    } on AssertionError catch (e) {
      _snackAlert(e.message.toString());
    } catch (e) {
      _snackAlert(e.toString());
    }
  }

  void trackAction() {
    MatomoForever.sendDataOrBulk(fields.where((key, value) {
      MyField field = value as MyField;
      return ((field.getValue(field.valueHolder) ?? "") as String).isNotEmpty &&
          field.sendToMatomo;
    }).map<String, String>((dynamic name, value) {
      MyField field = value as MyField;
      return (MapEntry<String, String>(
        name,
        field.getValue(field.valueHolder),
      ));
    })).then((success) {
      showResult(success, "track action");
    });
  }

  void saveAll() {
    fields.forEach((key, value) {
      value.save(preferences!);
    });
    preferences!.setString("headers", jsonEncode(headers));
    preferences!.setString("persistent", jsonEncode(persistentParameters));
    preferences!.setBool("dataStored", true);
  }

  void clearAll() {
    preferences!.clear();
    loadAll();
  }

  void loadAll() {
    fields.forEach((key, value) {
      value.load(preferences!);
    });
    headers = Map.castFrom(
        jsonDecode(preferences!.getString("headers") ?? "{}") ?? {});
    persistentParameters = Map.castFrom(
        jsonDecode(preferences!.getString("persistent") ?? "{}") ?? {});
  }
}
