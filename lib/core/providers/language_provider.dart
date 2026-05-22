import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _boxName = 'language_settings';
  static const String _keyLang = 'selected_language';
  static const String _keyCache = 'translation_cache';
  
  Box? _box;
  String _currentLanguage = 'en'; // default
  
  // Cache format: { "tr": { "English Text": "Turkish Text" }, "de": { ... } }
  Map<String, Map<String, String>> _cache = {};
  
  // To prevent duplicate running translation requests for the same text/lang
  final Set<String> _pendingRequests = {};

  String get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _currentLanguage = _box!.get(_keyLang, defaultValue: 'en') as String;
    
    final cachedData = _box!.get(_keyCache);
    if (cachedData != null) {
      try {
        final Map<String, dynamic> rawMap = Map<String, dynamic>.from(cachedData);
        _cache = rawMap.map((lang, translations) {
          final Map<String, dynamic> transMap = Map<String, dynamic>.from(translations);
          final Map<String, String> typedTrans = transMap.map((k, v) => MapEntry(k.toString(), v.toString()));
          return MapEntry(lang, typedTrans);
        });
      } catch (e) {
        debugPrint('Error loading translation cache: $e');
      }
    }
    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    if (_currentLanguage == langCode) return;
    _currentLanguage = langCode;
    if (_box != null) {
      await _box!.put(_keyLang, langCode);
    }
    notifyListeners();
  }

  String translate(String text) {
    if (text.trim().isEmpty) return text;
    if (_currentLanguage == 'en') return text;
    
    final langCache = _cache[_currentLanguage] ??= {};
    final cachedText = langCache[text];
    
    if (cachedText != null) {
      return cachedText;
    }
    
    // Request translation asynchronously
    _fetchTranslation(text, _currentLanguage);
    
    return text; // return original while loading
  }

  Future<void> _fetchTranslation(String text, String targetLang) async {
    final requestKey = '$targetLang::$text';
    if (_pendingRequests.contains(requestKey)) return;
    _pendingRequests.add(requestKey);
    
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded[0] != null) {
          final parts = decoded[0] as List;
          final translated = parts.map((part) => part[0] as String).join();
          
          if (translated.isNotEmpty) {
            _cache[targetLang] ??= {};
            _cache[targetLang]![text] = translated;
            
            // Persist the cache
            if (_box != null) {
              await _box!.put(_keyCache, _cache);
            }
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Translation API error for "$text" to $targetLang: $e');
    } finally {
      _pendingRequests.remove(requestKey);
    }
  }

  Future<void> clearCache() async {
    _cache.clear();
    if (_box != null) {
      await _box!.delete(_keyCache);
    }
    notifyListeners();
  }
}

extension TranslationExtension on String {
  String tr(BuildContext context) {
    try {
      final provider = Provider.of<LanguageProvider>(context);
      return provider.translate(this);
    } catch (_) {
      return this;
    }
  }
}
