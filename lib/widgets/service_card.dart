import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import '../main.dart';
import '../models/filter_model.dart';
import '../models/service_model.dart';
import '../screens/filter_screen.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final ValueChanged<bool> onToggleChanged;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onToggleChanged,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isExpanded = false;

  final ValueNotifier<ServiceFilterState> _filterStateNotifier =
      ValueNotifier(const ServiceFilterState(isAcceptOn: true, isRejectOn: true));

  @override
  void dispose() {
    _filterStateNotifier.dispose();
    super.dispose();
  }

  void _navigateToFilterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          serviceName: widget.service.name,
          filterStateNotifier: _filterStateNotifier,
        ),
      ),
    );
  }

  void _openExternalApp() async {
    await LaunchApp.openApp(
      androidPackageName: widget.service.androidPackageName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openExternalApp,
                  child: Image.asset(
                    widget.service.imagePath,
                    width: 36,
                    height: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.service.name} - ${widget.service.isEnabled ? "Online" : "Offline"}',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('Not receiving offers', style: textTheme.titleSmall),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: widget.service.isEnabled,
                  onChanged: widget.onToggleChanged,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 16),
                  Text('Filters', style: textTheme.titleMedium),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ValueListenableBuilder<ServiceFilterState>(
                valueListenable: _filterStateNotifier,
                builder: (context, filterState, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: filterState.isAcceptOn
                              ? null
                              : ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).cardColor,
                                  side: const BorderSide(
                                      color: AppColors.secondaryText)),
                          onPressed: _navigateToFilterScreen,
                          child: const Text('Auto-accept'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: filterState.isRejectOn
                              ? null
                              : ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).cardColor,
                                  side: const BorderSide(
                                      color: AppColors.secondaryText)),
                          onPressed: _navigateToFilterScreen,
                          child: const Text('Auto-reject'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
