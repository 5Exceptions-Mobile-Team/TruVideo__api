import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/json_viewer_controller.dart';

class EnhancedJsonViewerWidget extends StatefulWidget {
  final Map<String, dynamic>? jsonData;
  final String? jsonString;
  final String title;

  const EnhancedJsonViewerWidget({
    super.key,
    this.jsonData,
    this.jsonString,
    this.title = 'API Response',
  }) : assert(
         jsonData != null || jsonString != null,
         'Either jsonData or jsonString must be provided',
       );

  @override
  State<EnhancedJsonViewerWidget> createState() =>
      _EnhancedJsonViewerWidgetState();
}

class _EnhancedJsonViewerWidgetState extends State<EnhancedJsonViewerWidget> {
  late final JsonViewerController _controller;
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      JsonViewerController(),
      tag:
          'json_viewer_${DateTime.now().millisecondsSinceEpoch}_${widget.jsonData?.hashCode ?? 0}_${widget.jsonString?.hashCode ?? 0}',
    );
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic data;
    try {
      if (widget.jsonData != null) {
        data = widget.jsonData;
      } else if (widget.jsonString != null) {
        data = jsonDecode(widget.jsonString!);
      } else {
        data = {'error': 'No data available'};
      }
    } catch (e) {
      data = {'error': 'Invalid JSON: ${e.toString()}'};
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Pallet.secondaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Pallet.secondaryDarkColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pallet.secondaryDarkColor,
                    ),
                  ),
                ),
                Semantics(
                  identifier: 'copy_json',
                  label: 'copy_json',
                  child: IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 22,
                      color: Pallet.secondaryColor,
                    ),
                    onPressed: () {
                      try {
                        jsonEncode(data);
                        Clipboard.setData(
                          ClipboardData(text: jsonEncode(data)),
                        );
                      } catch (e) {
                        Utils.showToast('Failed to copy JSON');
                      }
                    },
                    tooltip: 'Copy JSON',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              interactive: true,
              thickness: 12,
              radius: const Radius.circular(4),
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 0),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildJsonWidget(data, 0, 'root'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonWidget(dynamic data, int depth, String path) {
    if (data == null) {
      return _buildValueWidget('null', Colors.grey, depth);
    } else if (data is Map<String, dynamic>) {
      return _buildObjectWidget(data, depth, path);
    } else if (data is Map) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final converted = Map<String, dynamic>.from(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
      return _buildObjectWidget(converted, depth, path);
    } else if (data is List) {
      return _buildArrayWidget(data, depth, path);
    } else {
      return _buildValueWidget(_formatValue(data), _getValueColor(data), depth);
    }
  }

  Widget _buildObjectWidget(Map<String, dynamic> map, int depth, String path) {
    if (map.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 16.0),
        child: Text(
          '{}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final itemKey = '${path}_object';
    final isExpanded = depth < 2; // Auto-expand first 2 levels

    // Set initial expanded state if not already set
    if (!_controller.expandedItems.containsKey(itemKey)) {
      _controller.setExpanded(itemKey, isExpanded);
    }

    return _ExpandableJsonItem(
      controller: _controller,
      itemKey: itemKey,
      title: '{',
      depth: depth,
      children: [
        ...map.entries.map((entry) {
          final entryPath = '${path}.${entry.key}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: (depth + 1) * 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 0,
                      fit: FlexFit.loose,
                      child: Text(
                        '"${entry.key}": ',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      fit: FlexFit.loose,
                      child: _buildJsonWidget(
                        entry.value,
                        depth + 1,
                        entryPath,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry != map.entries.last)
                Padding(
                  padding: EdgeInsets.only(left: (depth + 1) * 16.0),
                  child: Text(
                    ',',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          );
        }),
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: Text(
            '}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrayWidget(List list, int depth, String path) {
    if (list.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 16.0),
        child: Text(
          '[]',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final itemKey = '${path}_array';
    final isExpanded = depth < 2; // Auto-expand first 2 levels

    // Set initial expanded state if not already set
    if (!_controller.expandedItems.containsKey(itemKey)) {
      _controller.setExpanded(itemKey, isExpanded);
    }

    return _ExpandableJsonItem(
      controller: _controller,
      itemKey: itemKey,
      title: '[',
      depth: depth,
      children: [
        ...List.generate(list.length, (index) {
          final itemPath = '$path[$index]';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: (depth + 1) * 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 0,
                      fit: FlexFit.loose,
                      child: Text(
                        '$index: ',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      fit: FlexFit.loose,
                      child: _buildJsonWidget(list[index], depth + 1, itemPath),
                    ),
                  ],
                ),
              ),
              if (index < list.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: (depth + 1) * 16.0),
                  child: Text(
                    ',',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          );
        }),
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: Text(
            ']',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueWidget(String value, Color color, int depth) {
    // Check if value is a URL string (starts with "http:// or "https://)
    final isUrlString = value.startsWith('"https://');
    if (isUrlString) {
      // Extract URL from quotes
      final urlString = value.replaceAll('"', '');

      return GestureDetector(
        onTap: () async {
          try {
            final uri = Uri.parse(urlString);
            // Try to launch URL directly - canLaunchUrl can return false
            // even for valid URLs if no specific app handler is found
            final launched = await launchUrl(
              uri,
              // mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              Utils.showToast('Could not open URL');
            }
          } catch (e) {
            Utils.showToast('Could not open URL: ${e.toString()}');
          }
        },
        child: Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.blue[700],
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue[700],
          ),
        ),
      );
    }

    // Check if value contains a URL pattern (for URLs within longer strings)
    final urlPattern = RegExp(r'https?://[^\s"<>]+');
    final urlMatch = urlPattern.firstMatch(value);

    if (urlMatch != null) {
      // Found URL in the string, split and highlight
      final urlStart = urlMatch.start;
      final urlEnd = urlMatch.end;
      final urlText = value.substring(urlStart, urlEnd);
      final beforeUrl = value.substring(0, urlStart);
      final afterUrl = value.substring(urlEnd);

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beforeUrl.isNotEmpty)
            Text(
              beforeUrl,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: color,
              ),
            ),
          GestureDetector(
            onTap: () async {
              try {
                final uri = Uri.parse(urlText);
                // Try to launch URL directly - canLaunchUrl can return false
                // even for valid URLs if no specific app handler is found
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!launched) {
                  Utils.showToast('Could not open URL');
                }
              } catch (e) {
                Utils.showToast('Could not open URL: ${e.toString()}');
              }
            },
            child: Text(
              urlText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          if (afterUrl.isNotEmpty)
            Text(
              afterUrl,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: color,
              ),
            ),
        ],
      );
    }

    return Text(
      value,
      style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: color),
    );
  }

  String _formatValue(dynamic value) {
    if (value is String) return '"$value"';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  Color _getValueColor(dynamic value) {
    if (value is String) return Colors.green[700]!;
    if (value is num) return Colors.orange[700]!;
    if (value is bool) return Colors.purple[700]!;
    if (value == null) return Colors.grey;
    return Colors.black87;
  }
}

class _ExpandableJsonItem extends StatelessWidget {
  final JsonViewerController controller;
  final String itemKey;
  final String title;
  final int depth;
  final List<Widget> children;

  const _ExpandableJsonItem({
    required this.controller,
    required this.itemKey,
    required this.title,
    required this.depth,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isExpanded(itemKey);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.toggleExpanded(itemKey);
            },
            child: Padding(
              padding: EdgeInsets.only(left: depth * 16.0),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isExpanded && children.isNotEmpty)
                    Text(
                      ' ... ${children.length - 1} items',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...children,
        ],
      );
    });
  }
}
