

class Window {
  ///Title of the window.
  final String title;

  ///If the window is the active window or not.
  final bool isActive;

  ///Window ID.
  final int hWnd;

  const Window({
    required this.title,
    required this.isActive,
    required this.hWnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isActive': isActive,
      'hWnd': hWnd,
    };
  }

  factory Window.fromMap(Map<String, dynamic> map) {
    return Window(
      title: map['title'] as String,
      isActive: map['isActive'] as bool,
      hWnd: map['hWnd'] as int,
    );
  }

  @override
  String toString() {
    return 'Window ==> title: $title, isActive: $isActive, hWnd: $hWnd';
  }
}
