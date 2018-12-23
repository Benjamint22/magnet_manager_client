import 'package:flutter/material.dart';

class Loading {
  Loading(BuildContext context) : _context = context;

  BuildContext _context;
  OverlayEntry _overlay;

  void show(String message) {
    assert(_overlay == null);
    Overlay.of(_context).insert(
      _overlay = OverlayEntry(
        builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Opacity(
                opacity: 0.3,
                child: const ModalBarrier(dismissible: false, color: Colors.grey),
              ),
              AlertDialog(
                title: Text(message),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              ),
            ],
          );
        }
      )
    );
  }

  void hide() {
    assert(_overlay != null);
    _overlay.remove();
    _overlay = null;
  }

  bool get isOpened {
    return _overlay != null;
  }
}