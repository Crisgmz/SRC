import 'package:cloud_firestore/cloud_firestore.dart';

class _CacheEntry<T> {
  final T data;
  final DateTime expiry;
  _CacheEntry(this.data, this.expiry);
  bool get isValid => DateTime.now().isBefore(expiry);
}

class CacheService {
  static final Map<String, _CacheEntry<dynamic>> _cache = {};

  static T? _get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && entry.isValid) {
      return entry.data as T;
    }
    _cache.remove(key);
    return null;
  }

  static void _set<T>(String key, T data, Duration duration) {
    _cache[key] = _CacheEntry<T>(data, DateTime.now().add(duration));
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String docId, {
    Duration duration = const Duration(minutes: 10),
  }) async {
    final key = 'doc:$collection/$docId';
    final cached = _get<DocumentSnapshot<Map<String, dynamic>>>(key);
    if (cached != null) return cached;

    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .get();
    _set(key, doc, duration);
    return doc;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection, {
    Duration duration = const Duration(minutes: 10),
  }) async {
    final key = 'col:$collection';
    final cached = _get<QuerySnapshot<Map<String, dynamic>>>(key);
    if (cached != null) return cached;

    final snapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    _set(key, snapshot, duration);
    return snapshot;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> queryCollection(
    String collection,
    String field,
    dynamic value, {
    Duration duration = const Duration(minutes: 10),
  }) async {
    final key = 'qry:$collection:$field:$value';
    final cached = _get<QuerySnapshot<Map<String, dynamic>>>(key);
    if (cached != null) return cached;

    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();
    _set(key, snapshot, duration);
    return snapshot;
  }

  static void invalidate(String key) => _cache.remove(key);
  static void clear() => _cache.clear();
}
