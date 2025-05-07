import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  final String url;
  final String customUserAgent;
  final bool isHome;

  WebViewContainer({
    required this.url,
    required this.customUserAgent,
    this.isHome = false,
  });

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setUserAgent(widget.customUserAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            bool canNavigateBack = await _controller.canGoBack();
            setState(() {
              canGoBack = canNavigateBack;
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else if (!widget.isHome) {
      Navigator.pop(context);
      return false;
    }
    return true; // Allow app to exit
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: canGoBack
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  },
                )
              : null,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
        floatingActionButton: widget.isHome
            ? FloatingActionButton(
                child: Icon(Icons.open_in_new),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebViewContainer(
                        url: 'https://minoodelivery.com/home',
                        customUserAgent: widget.customUserAgent,
                        isHome: false,
                      ),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
