import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomToast {
  static void show(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 24.h,
        right: 24.w,
        child: Material(
          color: Colors.transparent,
          child: _ToastWidget(
            message: message,
            isError: isError,
            onClose: () => entry.remove(),
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onClose;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.onClose,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.reverse(from: 1.0);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onClose();
      }
    });

    _timer = Timer(const Duration(seconds: 5), () {
      // Safety timer in case animation status doesn't fire as expected
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: widget.isError ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.isError ? const Color(0xFFF87171) : const Color(0xFF34D399),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            widget.isError ? Icons.error_outline : Icons.check_circle_outline,
            color: widget.isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
            size: 24.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(
                color: widget.isError ? const Color(0xFF991B1B) : const Color(0xFF065F46),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    width: 32.r,
                    height: 32.r,
                    child: CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 2,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16.r),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 32.r,
                  minHeight: 32.r,
                ),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
