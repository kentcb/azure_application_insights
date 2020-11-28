extension MapExtensions<K, V> on Map<K, V> {
  void setOrRemove(K key, V value) => value == null ? remove(key) : this[key] = value;
}
