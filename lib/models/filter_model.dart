enum LogicalOperator { and, or }
enum Condition { isMoreThan, isLessThan }

class FilterRule {
  final LogicalOperator logicalOperator;
  final String filterName;
  final Condition condition;
  final String value;
  final String unit;

  FilterRule({
    required this.logicalOperator,
    required this.filterName,
    required this.condition,
    required this.value,
    required this.unit,
  });
}

// A cleaner, more robust version of the state class
class ServiceFilterState {
  final bool isAcceptOn;
  final bool isRejectOn;
  final List<FilterRule> acceptRules;
  final List<FilterRule> rejectRules;

  const ServiceFilterState({
    this.isAcceptOn = false,
    this.isRejectOn = false,
    this.acceptRules = const [], // Provides a constant empty list as a default
    this.rejectRules = const [], // Provides a constant empty list as a default
  });
}