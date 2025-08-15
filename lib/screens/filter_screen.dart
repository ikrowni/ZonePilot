import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/filter_model.dart';

// A simple model for the options in our modal
class FilterOption {
  final String name;
  bool isSelected;

  FilterOption({required this.name, this.isSelected = false});
}

class FilterScreen extends StatefulWidget {
  final String serviceName;
  final ValueNotifier<ServiceFilterState> filterStateNotifier;

  const FilterScreen({
    super.key,
    required this.serviceName,
    required this.filterStateNotifier,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  
  // This helper function updates the notifier with a new state
  void _updateState({
    bool? isAcceptOn,
    bool? isRejectOn,
    List<FilterRule>? acceptRules,
    List<FilterRule>? rejectRules,
  }) {
    final currentState = widget.filterStateNotifier.value;
    widget.filterStateNotifier.value = ServiceFilterState(
      isAcceptOn: isAcceptOn ?? currentState.isAcceptOn,
      isRejectOn: isRejectOn ?? currentState.isRejectOn,
      acceptRules: acceptRules ?? currentState.acceptRules,
      rejectRules: rejectRules ?? currentState.rejectRules,
    );
  }

  void _deleteFilterRule(FilterRule ruleToDelete) {
    final newAcceptRules = List<FilterRule>.from(widget.filterStateNotifier.value.acceptRules)
      ..removeWhere((rule) => rule.filterName == ruleToDelete.filterName);
    final newRejectRules = List<FilterRule>.from(widget.filterStateNotifier.value.rejectRules)
      ..removeWhere((rule) => rule.filterName == ruleToDelete.filterName);
    _updateState(acceptRules: newAcceptRules, rejectRules: newRejectRules);
  }

  void _editFilterRuleValue(FilterRule ruleToEdit, bool isAcceptRule) async {
    final TextEditingController controller = TextEditingController(text: ruleToEdit.value);
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);

    final String? newValue = await showDialog<String>(
      context: context,
      builder: (context) { /* ... Your existing showDialog code ... */ 
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Edit ${ruleToEdit.filterName}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: InputDecoration(suffixText: ruleToEdit.unit),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
          ],
        );
      },
    );

    if (newValue != null && newValue.isNotEmpty) {
      final rules = isAcceptRule
          ? List<FilterRule>.from(widget.filterStateNotifier.value.acceptRules)
          : List<FilterRule>.from(widget.filterStateNotifier.value.rejectRules);
      
      final index = rules.indexWhere((r) => r.filterName == ruleToEdit.filterName);
      if (index != -1) {
        rules[index] = FilterRule(
          logicalOperator: rules[index].logicalOperator,
          filterName: rules[index].filterName,
          condition: rules[index].condition,
          value: newValue,
          unit: rules[index].unit,
        );
        if (isAcceptRule) {
          _updateState(acceptRules: rules);
        } else {
          _updateState(rejectRules: rules);
        }
      }
    }
  }

  void _showAddFilterModal({required bool forAcceptRules}) async {
    final rulesList = forAcceptRules
        ? widget.filterStateNotifier.value.acceptRules
        : widget.filterStateNotifier.value.rejectRules;

    final List<String>? desiredFilterNames = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        return _AddFilterModal(existingRules: rulesList);
      },
    );

    if (desiredFilterNames != null) {
      final currentRules = List<FilterRule>.from(rulesList);
      final currentFilterNames = currentRules.map((r) => r.filterName).toSet();
      
      currentRules.removeWhere((rule) => !desiredFilterNames.contains(rule.filterName));

      for (var name in desiredFilterNames) {
        if (!currentFilterNames.contains(name)) {
          String getUnitForFilter(String filterName) {
            if (filterName.contains('Distance')) return 'mi';
            if (filterName.contains('Mile')) return '/ mi';
            return '';
          }
          final newRule = FilterRule(
            logicalOperator: LogicalOperator.and,
            filterName: name,
            condition: Condition.isMoreThan,
            value: '0.00',
            unit: getUnitForFilter(name),
          );
          currentRules.add(newRule);
        }
      }
      if (forAcceptRules) {
        _updateState(acceptRules: currentRules);
      } else {
        _updateState(rejectRules: currentRules);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceName} Filters'),
        centerTitle: false,
      ),
      // Use a ValueListenableBuilder to automatically rebuild when the state changes
      body: ValueListenableBuilder<ServiceFilterState>(
        valueListenable: widget.filterStateNotifier,
        builder: (context, filterState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _FilterSection(
                  title: 'Auto-accept',
                  description: 'Auto accept offers if',
                  rules: filterState.acceptRules, // Read from notifier
                  isEnabled: filterState.isAcceptOn, // Read from notifier
                  onAddFilter: () => _showAddFilterModal(forAcceptRules: true),
                  onToggleChanged: (newValue) => _updateState(isAcceptOn: newValue),
                  onEditRule: (rule) => _editFilterRuleValue(rule, true),
                  onDeleteRule: _deleteFilterRule,
                ),
                const SizedBox(height: 32),
                _FilterSection(
                  title: 'Auto-reject',
                  description: 'Auto reject offers if',
                  rules: filterState.rejectRules, // Read from notifier
                  isEnabled: filterState.isRejectOn, // Read from notifier
                  onAddFilter: () => _showAddFilterModal(forAcceptRules: false),
                  onToggleChanged: (newValue) => _updateState(isRejectOn: newValue),
                  onEditRule: (rule) => _editFilterRuleValue(rule, false),
                  onDeleteRule: _deleteFilterRule,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ... _FilterSection and _FilterRuleRow widgets remain largely the same ...
class _FilterSection extends StatelessWidget {
  final String title;
  final String description;
  final List<FilterRule> rules;
  final bool isEnabled;
  final VoidCallback onAddFilter;
  final ValueChanged<bool> onToggleChanged;
  final ValueChanged<FilterRule> onEditRule;
  final ValueChanged<FilterRule> onDeleteRule;

  const _FilterSection({
    required this.title,
    required this.description,
    required this.rules,
    required this.isEnabled,
    required this.onAddFilter,
    required this.onToggleChanged,
    required this.onEditRule,
    required this.onDeleteRule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            Switch(value: isEnabled, onChanged: onToggleChanged),
          ],
        ),
        Text(description, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 16),
        Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rules.isEmpty)
                  const Text('No filters added.',
                      style: TextStyle(color: AppColors.secondaryText))
                else
                  ListView.builder(
                    itemCount: rules.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _FilterRuleRow(
                        rule: rules[index],
                        isFirst: index == 0,
                        onTap: () => onEditRule(rules[index]),
                        onDelete: () => onDeleteRule(rules[index]),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onAddFilter,
                  child: const Text('+ add filters',
                      style: TextStyle(color: AppColors.primaryOrange)),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _FilterRuleRow extends StatelessWidget {
  final FilterRule rule;
  final bool isFirst;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FilterRuleRow(
      {required this.rule,
      required this.isFirst,
      required this.onTap,
      required this.onDelete});

  String _getConditionText(Condition condition) {
    return condition == Condition.isMoreThan ? 'is more than' : 'is less than';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              Text(isFirst ? '' : '${rule.logicalOperator.name} ',
                  style: const TextStyle(color: AppColors.secondaryText)),
              Text(rule.filterName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(_getConditionText(rule.condition),
                  style: const TextStyle(color: AppColors.secondaryText)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('${rule.value} ${rule.unit}'),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.secondaryText),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The _AddFilterModal widget remains unchanged from the previous step
class _AddFilterModal extends StatefulWidget {
  final List<FilterRule> existingRules;
  const _AddFilterModal({required this.existingRules});

  @override
  State<_AddFilterModal> createState() => __AddFilterModalState();
}

class __AddFilterModalState extends State<_AddFilterModal> {
  final Map<String, List<FilterOption>> _filterCategories = {
    'EARNINGS': [
      FilterOption(name: 'Fare'),
      FilterOption(name: 'Total Pay'),
      FilterOption(name: '\$/Mile'),
    ],
    'LOCATION': [
      FilterOption(name: 'Pickup Distance'),
      FilterOption(name: 'Max Trip Time'),
    ],
    'TRIP': [
      FilterOption(name: 'Multiple Stops'),
    ]
  };

  @override
  void initState() {
    super.initState();
    final existingFilterNames =
        widget.existingRules.map((rule) => rule.filterName).toSet();
    _filterCategories.forEach((category, options) {
      for (var option in options) {
        if (existingFilterNames.contains(option.name)) {
          option.isSelected = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text('Add filters',
                    style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _filterCategories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(entry.key,
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    ...entry.value.map((option) {
                      return CheckboxListTile(
                        title: Text(option.name),
                        value: option.isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            option.isSelected = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryOrange,
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final List<String> allSelectedNames = [];
                  _filterCategories.forEach((_, options) {
                    allSelectedNames.addAll(
                        options.where((o) => o.isSelected).map((o) => o.name));
                  });
                  Navigator.pop(context, allSelectedNames);
                },
                child: const Text('Done'),
              ),
            ),
          )
        ],
      ),
    );
  }
}