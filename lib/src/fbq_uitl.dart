import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui;

import 'lock_completer.dart';

class FbqUtil {
  static const _metaPixel_id = "id_flutter_meta_pixel";

  static bool _isInitSuccess = false;

  static final LockCompleter lockCompleter = LockCompleter();

  // fbq('init', '{your-pixel-id-goes-here}');
  static Future<void> init(String? pixelId) async {
    lockCompleter.lock(action: () async {
      try {
        if (pixelId?.isNotEmpty == true) {
          await _loadMetaPixelJs();
          js.context.callMethod('fbq', [
            'init',
            pixelId,
          ]);
          _isInitSuccess = true;
        }
      } catch (e) {
        print(e);
        assert(false, "meta pixel init failed");
      }
    });
  }

  // fbq('track', 'PageView');
  static Future<void> pageView() async {
    lockCompleter.awaitLock(action: () {
      try {
        if (_isInitSuccess) {
          // fbq('track', 'PageView');
          js.context.callMethod('fbq', [
            'track',
            'PageView',
          ]);
        }
      } catch (e) {
        print(e);
        assert(false, "meta pixel PageView failed");
      }
    });
  }

  static Future<void> purchase(String currency, double? price) async {
    lockCompleter.awaitLock(action: () {
      try {
        if (_isInitSuccess) {
          // fbq('track', 'Purchase', {currency: "USD", value: 30.00});
          js.context.callMethod('fbq', [
            'track',
            'Purchase',
            js.JsObject.jsify({
              'currency': currency,
              'value': price,
            }),
          ]);
        }
      } catch (e) {
        print(e);
        assert(false, "meta pixel purchase failed");
      }
    });
  }

  static Future<void> addToCart(String currency, double? price) async {
    lockCompleter.awaitLock(action: () {
      try {
        if (_isInitSuccess) {
          js.context.callMethod('fbq', [
            'track',
            'AddToCart',
            js.JsObject.jsify({
              'currency': currency,
              'value': price,
            }),
          ]);
        }
      } catch (e) {
        print(e);
        assert(false, "meta pixel addToCart failed");
      }
    });
  }

  static Future<void> startTrial() async {
    lockCompleter.awaitLock(action: () {
      try {
        if (_isInitSuccess) {
          js.context.callMethod('fbq', [
            'track',
            'StartTrial',
          ]);
        }
      } catch (e) {
        print(e);
        assert(false, "meta pixel startTrial failed");
      }
    });
  }

  static Future<void> _loadMetaPixelJs() async {
    if (html.querySelector("#$_metaPixel_id") != null) {
      return;
    }
    final List<Future<void>> loading = <Future<void>>[];

    // ignore: undefined_prefixed_name
    final jsUrl = ui.assetManager.getAssetUrl(
      'packages/flutter_meta_pixel/assets/js/meta_pixel.js',
    );
    final html.ScriptElement script = html.ScriptElement()
      ..id = _metaPixel_id
      ..async = true
      // ..defer = true
      ..src = jsUrl;
    loading.add(script.onLoad.first);
    html.querySelector('head')!.children.add(script);

    await Future.wait(loading);
  }
}
