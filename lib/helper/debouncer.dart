import 'package:rxdart/rxdart.dart';

class Debouncer {
  Debouncer._singleton();
  static final Debouncer _instance = Debouncer._singleton();
  static Debouncer get instance => _instance;
  final BehaviorSubject<String> _subject = BehaviorSubject<String>();
  Stream<String> get obj =>
      _subject.debounceTime(const Duration(milliseconds: 1500));
  update(String text) {
    _subject.add(text);
  }

  // listen() {
  //   // _subject.debounceTime(duration)
  // }
}
