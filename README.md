# matomo_forever

A perennial Dart plugin to send data to a Matomo server with a Flutter example app.

This plugin is based on the [Matomo HTTP tracking API documentation](https://developer.matomo.org/api-reference/tracking-api).

# Why `matomo_forever`?

[Matomo](https://matomo.org) is a free, open source, complete, reliable, stable and flexible solution to collect and analyze app and web usages.
This can be achieved through a Matomo cloud solution (paid) or through a server on premises.

At the time those lines are written, 2 plugins are proposed on pub.dev for Matomo. They both suffered the following:
- Only work on iOS and Android.
- Lead me to malfunctions even on iOS and/or Android.
- Not flexible enough.

matomo_forever has a simpler implementation that provides higher flexibility and sustainability.
For example, it supports:
- All the fields described in the [Matomo API](https://developer.matomo.org/api-reference/tracking-api).
- Setting custom HTTP headers.
- Sending in bulks.

## Platforms

This plugin has been successfully tested on *Android*, *iOS*, *Linux* and *Chrome*. It is expected to work fine on *MacOS* and *Windows*.

## Examples

An example project app is included in the main project under the `example` folder.
This example app is a good way to interact with a Matomo server as a client.

![matomo_forever example app screenshot](https://github.com/lcuis/matomo_forever/raw/master/doc/web_screenshot.png)

### Demonstration

The following builds of the example app are available from CI/CD:
- [Android](https://lcuis.github.io/matomo_forever/matomo_forever_example_android.apk)
- [Linux desktop](https://lcuis.github.io/matomo_forever/matomo_forever_example_linux.zip)
- [Web](https://lcuis.github.io/matomo_forever/matomo_forever_example_web.zip)
- [Windows](https://lcuis.github.io/matomo_forever/matomo_forever_example_windows.zip)
- [MacOS](https://lcuis.github.io/matomo_forever/matomo_forever_example_macos.zip)

Also, the example app is available from a browser directly [here](https://lcuis.github.io/matomo_forever/). To see it work, you may have to disable your ad-blocker.

### Code

#### Plugin usage

Add to your `pubspec.yaml` in the `dependencies` section:
```
  matomo_forever:
```

Get packages with command:
```
flutter packages get
```

Import:
```dart
import 'package:matomo_forever/matomo_forever.dart';
```

##### Init

Call the `init` static method to initialize the plugin:

```dart
MatomoForever.init(
        siteUrl,
        idSite,
        id: id,
        apiV: apiV,
        rec: rec,
        method: MatomoForeverMethod.post,
        bulkSize: bulkSize,
        tokenAuth: tokenAuth,
        headers: headers,
        persistentParameters: persistentParameters,
      );
```

Where:
  * siteUrl (Mandatory) The Matomo or piwik URL such as https://matomo.example.com/matomo.php
  * idSite (Madatory) The ID of the website we're tracking a visit/action for.
  * id The unique visitor ID, must be a 16 characters hexadecimal string. Every unique visitor must be assigned a different ID and this ID must not change after it is assigned. If this value is not set Matomo (formerly Piwik) will still track visits, but the unique visitors metric might be less accurate. Corresponds to _id in https://developer.matomo.org/api-reference/tracking-api
  * apiV The parameter &apiv=1 defines the api version to use (currently always set to 1)
  * rec Required for tracking, must be set to true.
  * method Can be either post or get except for bulk sending which must be sent through post method.
  * bulkSize Max size the local queue can reach before sending the bulk of requests. If <= 0, no bulk mechanism. requests are sent straight away. Bulk sending requires tokenAuth to be set.
  * tokenAuth 32 character authorization key used to authenticate the API request. We recommend to create a user specifically for accessing the Tracking API, and give the user only write permission on the website(s).
  * queuedTracking When set to false (0), the queued tracking handler won't be used and instead the tracking request will be executed directly. This can be useful when you need to debug a tracking problem or want to test that the tracking works in general.
  * sendImage If set to false (send_image=0) Matomo will respond with HTTP 204 response code instead of a GIF image. This improves performance and can fix errors if images are not allowed to be obtained directly (eg Chrome Apps). Available since Matomo 2.10.0
  * ping If set to true (ping=1), the request will be a Heartbeat request which will not track any new activity (such as a new visit, new action or new goal). The heartbeat request will only update the visit's total time to provide accurate "Visit duration" metric when this parameter is set. It won't record any other data. This means by sending an additional tracking request when the user leaves your site or app with ping set to true (&ping=1), you fix the issue where the time spent of the last page visited is reported as 0 seconds.
  * bots By default Matomo does not track bots. If you use the Tracking HTTP API directly, you may be interested in tracking bot requests. To enable Bot Tracking in Matomo, set the parameter bots to true (&bots=1) in your requests to matomo.php.
  * debug If Matomo server is configured with debug_on_demand = 1, debug can be set to true (1)
  * headers The headers to be sent along with request.
  * persistentParameters Custom parameters sent at each call. Refer to: https://developer.matomo.org/api-reference/tracking-api
  * sendThroughGetMethod Function used to send the data to the server. There is a fallback in case it is not initialized through the init call. Returns true for success. Receives the following parameters: urlWithoutParameters The matomo.php URL without the parameters. urlParameters The parameters String formatted for a GET request. headers The headers to be sent along with request.
  * sendThroughPostMethod Function used to send the data to the server. There is a fallback in case it is not initialized through the init call. Returns true for success. Receives the following parameters: urlWithoutParameters The matomo.php URL without the parameters. data The parameters to be sent by post. headers The headers to be sent along with request.

##### Track

Track calling the `track` static method:

```dart
bool result = await MatomoForever.track(
    actionName,
    url: url,
    rand: rand,
    urlRef: urlRef,
    cvar: cvar,
    idVc: idVc,
    viewTs: viewTs,
    idTs: idTs,
    rcn: rcn,
    rck: rck,
    res: res,
    h: h,
    m: m,
    s: s,
    fla: fla,
    java: java,
    dir: dir,
    qt: qt,
    realp: realp,
    pdf: pdf,
    wma: wma,
    gears: gears,
    ag: ag,
    cookie: cookie,
    ua: ua,
    lang: lang,
    uid: uid,
    cid: cid,
    newVisit: newVisit,
    dimension0: dimension0,
    dimension1: dimension1,
    dimension2: dimension2,
    dimension3: dimension3,
    dimension4: dimension4,
    dimension5: dimension5,
    dimension6: dimension6,
    dimension7: dimension7,
    dimension8: dimension8,
    dimension9: dimension9,
    dimension10: dimension10,
    link: link,
    download: download,
    search: search,
    searchCat: searchCat,
    searchCount: searchCount,
    pvId: pvId,
    idGoal: idGoal,
    revenue: revenue,
    gtMs: gtMs,
    cs: cs,
    ca: ca,
    pfNet: pfNet,
    pfSrv: pfSrv,
    pfTfr: pfTfr,
    pfDm1: pfDm1,
    pfDm2: pfDm2,
    pfOnl: pfOnl,
    eC: eC,
    eA: eA,
    eN: eN,
    eV: eV,
    cN: cN,
    cP: cP,
    cT: cT,
    cId: cId,
    ecId: ecId,
    ecItems: ecItems,
    ecSt: ecSt,
    ecTx: ecTx,
    ecSh: ecSh,
    ecDt: ecDt,
    ects: ects,
    cip: cip,
    cdt: cdt,
    country: country,
    region: region,
    city: city,
    lat: lat,
    long: long,
    maId: maId,
    maRe: maRe,
    maMt: maMt,
    maTi: maTi,
    maPn: maPn,
    maSt: maSt,
    maLe: maLe,
    maPs: maPs,
    maTtp: maTtp,
    maW: maW,
    maH: maH,
    maFs: maFs,
    maSe: maSe,
    customData: customData,
);
```

Where:
  * actionName The title of the action being tracked. It is possible to use slashes / to set one or several categories for this action. For example, Help / Feedback will create the Action Feedback in the category Help.
  * url The full URL for the current action.
  * rand Meant to hold a random value that is generated before each request. Using it helps avoid the tracking request being cached by the browser or a proxy.
  * urlRef The full HTTP Referrer URL. This value is used to determine how someone got to your website (ie, through a website, search engine or campaign).
  * cvar Visit or page scope custom variables. This is a JSON encoded string of the custom variable array (see https://developer.matomo.org/api-reference/tracking-api ).
  * idVc The current count of visits for this visitor. To set this value correctly, it would be required to store the value for each visitor in your application (using sessions or persisting in a database). Then you would manually increment the counts by one on each new visit or "session", depending on how you choose to define a visit. This value is used to populate the report Visitors > Engagement > Visits by visit number.
  * viewTs The UNIX timestamp of this visitor's previous visit. This parameter is used to populate the report Visitors > Engagement > Visits by days since last visit.
  * idTs The UNIX timestamp of this visitor's first visit. This could be set to the date where the user first started using your software/app, or when he/she created an account. This parameter is used to populate the Goals > Days to Conversion report.
  * rcn The Campaign name (see Tracking Campaigns). Used to populate the Referrers > Campaigns report. Note: this parameter will only be used for the first pageview of a visit.
  * rck The Campaign Keyword (see Tracking Campaigns). Used to populate the Referrers > Campaigns report (clicking on a campaign loads all keywords for this campaign). Note: this parameter will only be used for the first pageview of a visit.
  * res The resolution of the device the visitor is using, eg 1280x1024.
  * h The current hour (local time).
  * m The current minute (local time).
  * s The current second (local time).
  * fla Flash plugin
  * java Java plugin
  * dir Director plugin
  * qt Quicktime plugin
  * realp Real Player plugin
  * pdf PDF plugin
  * wma Windows Media plugin
  * gears Gears plugin
  * ag Silverlight plugin
  * cookie when set to 1, the visitor's client is known to support cookies.
  * ua An override value for the User-Agent HTTP header field. The user agent is used to detect the operating system and browser used.
  * lang An override value for the Accept-Language HTTP header field. This value is used to detect the visitor's country if GeoIP is not enabled.
  * uid defines the User ID for this request. User ID is any non-empty unique string identifying the user (such as an email address or an username). To access this value, users must be logged-in in your system so you can fetch this user ID from your system, and pass it to Matomo. The User ID appears in the visits log, the Visitor profile, and you can Segment reports for one or several User ID (userId segment). When specified, the User ID will be "enforced". This means that if there is no recent visit with this User ID, a new one will be created. If a visit is found in the last 30 minutes with your specified User ID, then the new action will be recorded to this existing visit.
  * cid defines the visitor ID for this request. You must set this value to exactly a 16 character hexadecimal string (containing only characters 01234567890abcdefABCDEF). We recommended setting the User ID via uid rather than use this cid.
  * newVisit If set to 1, will force a new visit to be created for this action. This feature is also available in JavaScript.
  * dimension0 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension1 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension2 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension3 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension4 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension5 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension6 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension7 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension8 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension9 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * dimension10 0-999 A Custom Dimension value for a specific Custom Dimension ID (requires Matomo 2.15.1 + Custom Dimensions plugin see the Custom Dimensions guide). If Custom Dimension ID is 2 use dimension2=dimensionValue to send a value for this dimension. The configured Custom Dimension has to be in scope "Visit" for user or "Action".
  * link An external URL the user has opened. Used for tracking outlink clicks. We recommend to also set the url parameter to this same value.
  * download URL of a file the user has downloaded. Used for tracking downloads. We recommend to also set the url parameter to this same value.
  * search The Site Search keyword. When specified, the request will not be tracked as a normal pageview but will instead be tracked as a Site Search request.
  * searchCat when search is specified, you can optionally specify a search category with this parameter.
  * searchCount when search is specified, we also recommend setting the search_count to the number of search results displayed on the results page. When keywords are tracked with &search_count=0 they will appear in the "No Result Search Keyword" report.
  * pvId Accepts a six character unique ID that identifies which actions were performed on a specific page view. When a page was viewed, all following tracking requests (such as events) during that page view should use the same pageview ID. Once another page was viewed a new unique ID should be generated. Use 0-9a-Z as possible characters for the unique ID.
  * idGoal If specified, the tracking request will trigger a conversion for the goal of the website being tracked with this ID.
  * revenue A monetary value that was generated as revenue by this goal conversion. Only used if idgoal is specified in the request. Can also be the grand total for the ecommerce order (required when tracking an ecommerce order).
  * gtMs The amount of time it took the server to generate this action, in milliseconds. This value is used to process the Page speed report Avg. generation time column in the Page URL and Page Title reports, as well as a site wide running average of the speed of your server. Note: when using the JavaScript tracker this value is set to the time for server to generate response + the time for client to download response.
  * cs The charset of the page being tracked. Specify the charset if the data you send to Matomo is encoded in a different character set than the default utf-8.
  * ca Stands for custom action. &ca=1 can be optionally sent along any tracking request that isn't a page view. For example it can be sent together with an event tracking request e_a=Action&e_c=Category&ca=1. The advantage being that should you ever disable the event plugin, then the event tracking requests will be ignored vs if the parameter is not set, a page view would be tracked even though it isn't a page view. For more background information check out #16570. Do not use this parameter together with a ping=1 tracking request.
  * pfNet milliseconds Network time. How long it took to connect to server.
  * pfSrv milliseconds Server time. How long it took the server to generate page.
  * pfTfr milliseconds Transfer time. How long it takes the browser to download the response from the server
  * pfDm1 milliseconds Dom processing time. How long the browser spends loading the webpage after the response was fully received until the user can starting interacting with it.
  * pfDm2 milliseconds Dom completion time. How long it takes for the browser to load media and execute any Javascript code listening for the DOMContentLoaded event.
  * pfOnl milliseconds Onload time. How long it takes the browser to execute Javascript code waiting for the window.load event.
  * eC The event category. Must not be empty. (eg. Videos, Music, Games...)
  * eA The event action. Must not be empty. (eg. Play, Pause, Duration, Add Playlist, Downloaded, Clicked...)
  * eN The event name. (eg. a Movie name, or Song name, or File name...)
  * eV The event value. Must be a float or integer value (numeric), not a string.
  * cN The name of the content. For instance 'Ad Foo Bar'. Required for content tracking.
  * cP The actual content piece. For instance the path to an image, video, audio, any text
  * cT The target of the content. For instance the URL of a landing page
  * cId The name of the interaction with the content. For instance a 'click'
  * ecId The unique string identifier for the ecommerce order (required when tracking an ecommerce order). Must set idgoal=0.
  * ecItems Items in the Ecommerce order. This is a JSON encoded array of items. Each item is an array with the following info in this order: item sku (required), item name (or if not applicable, set it to an empty string), item category (or if not applicable, set it to an empty string), item price (or if not applicable, set it to 0), item quantity (or if not applicable, set it to 1). An example value of ec_items would be: %5B%5B%22item1%20SKU%22%2C%22item1%20name%22%2C%22item1%20category%22%2C11.1111%2C2%5D%2C%5B%22item2%20SKU%22%2C%22item2%20name%22%2C%22%22%2C0%2C1%5D%5D see url decoded version on the [Matomo API documentation](https://developer.matomo.org/api-reference/tracking-api)
  * ecSt The sub total of the order; excludes shipping.
  * ecTx Tax Amount of the order
  * ecSh Shipping cost of the Order
  * ecDt Discount offered
  * ects The UNIX timestamp of this customer's last ecommerce order. This value is used to process the "Days since last order" report.
  * cip Override value for the visitor IP (both IPv4 and IPv6 notations supported).
  * cdt Override for the datetime of the request (normally the current time is used). This can be used to record visits and page views in the past. The expected format is either a datetime such as: 2011-04-05 00:11:42 (remember to URL encode the value!), or a valid UNIX timestamp such as 1301919102. The datetime must be sent in UTC timezone. Note: if you record data in the past, you will need to force Matomo to re-process reports for the past dates. If you set cdt to a datetime older than 24 hours then token_auth must be set. If you set cdt with a datetime in the last 24 hours then you don't need to pass token_auth.
  * country An override value for the country. Should be set to the two letter country code of the visitor (lowercase), eg fr, de, us.
  * region An override value for the region. Should be set to a ISO 3166-2 region code, which are used by MaxMind's and DB-IP's GeoIP2 databases. See here for a list of them for every country.
  * city An override value for the city. The name of the city the visitor is located in, eg, Tokyo.
  * lat An override value for the visitor's latitude, eg 22.456.
  * long An override value for the visitor's longitude, eg 22.456.
  * maId (required) A unique id that is always the same while playing a media. As soon as the played media changes (new video or audio started), this ID has to change.
  * maRe (required) The URL of the media resource.
  * maMt (required) video or audio depending on the type of the media.
  * maTi The name / title of the media.
  * maPn The name of the media player, for example html5.
  * maSt The time in seconds for how long a user has been playing this media. This number should typically increase when you send a media tracking request. It should be 0 if the media was only visible/impressed but not played. Do not increase this number when a media is paused.
  * maLe The duration (the length) of the media in seconds. For example if a video is 90 seconds long, the value should be 90.
  * maPs The progress / current position within the media. Defines basically at which position within the total length the user is currently playing.
  * maTtp Defines after how many seconds the user has started playing this media. For example a user might have seen the poster of the video for 30 seconds before a user actually pressed the play button.
  * maW The resolution width of the media in pixels. Only recommended being set for videos.
  * maH The resolution height of the media in pixels. Only recommended being set for videos.
  * maFs Should be 0 or 1 and defines whether the media is currently viewed in full screen. Only recommended being set for videos.
  * maSe An optional comma separated list of which positions within a media a user has played. For example if the user has viewed position 5s, 10s, 15s and 35s, then you would need to send 5,10,15,35. We recommend to round to the next 5 seconds and not send a value for each second. Internally, Matomo may round to the next 15 or 30 seconds. For performance optimisation we recommend not sending the same position twice. Meaning if you have sent ma_se=10 there is no need to send later ma_se=10,20 but instead only ma_se=20.
  * customData Additional data to send to the Matomo server.

##### Send data

Alternatively to calling the `track` method, one can call the `sendDataOrBulk` method which takes a simpler `Map` as a parameter.

```dart
bool result = await MatomoForever.sendDataOrBulk(
    addedData,
);
```

Where:
* addedData Data to be added to the init data

##### Send the bulk

When sending in bulks (bulkSize > 0), the bulk data can be pushed by calling the `sendQueue` method:

```dart
bool result = await MatomoForever.sendQueue();
```

## Feature requests/comments/questions/bugs

Feel free to log your feature requests/comments/questions/bugs here:
https://github.com/lcuis/matomo_forever/issues

## Contributions

I would be happy to merge pull request proposals provided that:
* they don't break the compilation
* they pass the automated testing
* they provide the relevant adaptations to documentation and automated testing
* they bring value
* they don't completely transform the code and the way to use it
* they are readable (though, I enjoy https://www.ioccc.org/ as a contest full of curiosities)

Contributions and forks are very welcome!

In your pull request, feel free to add your line in the contributors section below:

### Contributors
* https://github.com/lcuis

## CI/CD

Continuous integration/deployment status: ![CI-CD](https://github.com/lcuis/matomo_forever/workflows/CI-CD/badge.svg)