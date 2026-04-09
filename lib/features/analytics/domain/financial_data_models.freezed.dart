// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlowDataPoint {

 DateTime get date; double get income; double get expense; String? get label;
/// Create a copy of FlowDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlowDataPointCopyWith<FlowDataPoint> get copyWith => _$FlowDataPointCopyWithImpl<FlowDataPoint>(this as FlowDataPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlowDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense,label);

@override
String toString() {
  return 'FlowDataPoint(date: $date, income: $income, expense: $expense, label: $label)';
}


}

/// @nodoc
abstract mixin class $FlowDataPointCopyWith<$Res>  {
  factory $FlowDataPointCopyWith(FlowDataPoint value, $Res Function(FlowDataPoint) _then) = _$FlowDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double income, double expense, String? label
});




}
/// @nodoc
class _$FlowDataPointCopyWithImpl<$Res>
    implements $FlowDataPointCopyWith<$Res> {
  _$FlowDataPointCopyWithImpl(this._self, this._then);

  final FlowDataPoint _self;
  final $Res Function(FlowDataPoint) _then;

/// Create a copy of FlowDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? income = null,Object? expense = null,Object? label = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlowDataPoint].
extension FlowDataPointPatterns on FlowDataPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlowDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlowDataPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlowDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _FlowDataPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlowDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _FlowDataPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double income,  double expense,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlowDataPoint() when $default != null:
return $default(_that.date,_that.income,_that.expense,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double income,  double expense,  String? label)  $default,) {final _that = this;
switch (_that) {
case _FlowDataPoint():
return $default(_that.date,_that.income,_that.expense,_that.label);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double income,  double expense,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _FlowDataPoint() when $default != null:
return $default(_that.date,_that.income,_that.expense,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _FlowDataPoint extends FlowDataPoint {
  const _FlowDataPoint({required this.date, required this.income, required this.expense, this.label}): super._();
  

@override final  DateTime date;
@override final  double income;
@override final  double expense;
@override final  String? label;

/// Create a copy of FlowDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlowDataPointCopyWith<_FlowDataPoint> get copyWith => __$FlowDataPointCopyWithImpl<_FlowDataPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlowDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense,label);

@override
String toString() {
  return 'FlowDataPoint(date: $date, income: $income, expense: $expense, label: $label)';
}


}

/// @nodoc
abstract mixin class _$FlowDataPointCopyWith<$Res> implements $FlowDataPointCopyWith<$Res> {
  factory _$FlowDataPointCopyWith(_FlowDataPoint value, $Res Function(_FlowDataPoint) _then) = __$FlowDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double income, double expense, String? label
});




}
/// @nodoc
class __$FlowDataPointCopyWithImpl<$Res>
    implements _$FlowDataPointCopyWith<$Res> {
  __$FlowDataPointCopyWithImpl(this._self, this._then);

  final _FlowDataPoint _self;
  final $Res Function(_FlowDataPoint) _then;

/// Create a copy of FlowDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? income = null,Object? expense = null,Object? label = freezed,}) {
  return _then(_FlowDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CategorySpend {

 String get categoryId; String get categoryName; String get categoryIcon; int get categoryColor; double get amount; double get percentage; double? get budget;
/// Create a copy of CategorySpend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySpendCopyWith<CategorySpend> get copyWith => _$CategorySpendCopyWithImpl<CategorySpend>(this as CategorySpend, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySpend&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.categoryColor, categoryColor) || other.categoryColor == categoryColor)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.budget, budget) || other.budget == budget));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,categoryIcon,categoryColor,amount,percentage,budget);

@override
String toString() {
  return 'CategorySpend(categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, amount: $amount, percentage: $percentage, budget: $budget)';
}


}

/// @nodoc
abstract mixin class $CategorySpendCopyWith<$Res>  {
  factory $CategorySpendCopyWith(CategorySpend value, $Res Function(CategorySpend) _then) = _$CategorySpendCopyWithImpl;
@useResult
$Res call({
 String categoryId, String categoryName, String categoryIcon, int categoryColor, double amount, double percentage, double? budget
});




}
/// @nodoc
class _$CategorySpendCopyWithImpl<$Res>
    implements $CategorySpendCopyWith<$Res> {
  _$CategorySpendCopyWithImpl(this._self, this._then);

  final CategorySpend _self;
  final $Res Function(CategorySpend) _then;

/// Create a copy of CategorySpend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? categoryName = null,Object? categoryIcon = null,Object? categoryColor = null,Object? amount = null,Object? percentage = null,Object? budget = freezed,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,categoryIcon: null == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String,categoryColor: null == categoryColor ? _self.categoryColor : categoryColor // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySpend].
extension CategorySpendPatterns on CategorySpend {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySpend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySpend() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySpend value)  $default,){
final _that = this;
switch (_that) {
case _CategorySpend():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySpend value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySpend() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String categoryName,  String categoryIcon,  int categoryColor,  double amount,  double percentage,  double? budget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySpend() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.categoryIcon,_that.categoryColor,_that.amount,_that.percentage,_that.budget);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String categoryName,  String categoryIcon,  int categoryColor,  double amount,  double percentage,  double? budget)  $default,) {final _that = this;
switch (_that) {
case _CategorySpend():
return $default(_that.categoryId,_that.categoryName,_that.categoryIcon,_that.categoryColor,_that.amount,_that.percentage,_that.budget);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String categoryName,  String categoryIcon,  int categoryColor,  double amount,  double percentage,  double? budget)?  $default,) {final _that = this;
switch (_that) {
case _CategorySpend() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.categoryIcon,_that.categoryColor,_that.amount,_that.percentage,_that.budget);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySpend implements CategorySpend {
  const _CategorySpend({required this.categoryId, required this.categoryName, required this.categoryIcon, required this.categoryColor, required this.amount, required this.percentage, this.budget});
  

@override final  String categoryId;
@override final  String categoryName;
@override final  String categoryIcon;
@override final  int categoryColor;
@override final  double amount;
@override final  double percentage;
@override final  double? budget;

/// Create a copy of CategorySpend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySpendCopyWith<_CategorySpend> get copyWith => __$CategorySpendCopyWithImpl<_CategorySpend>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySpend&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.categoryColor, categoryColor) || other.categoryColor == categoryColor)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.budget, budget) || other.budget == budget));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,categoryIcon,categoryColor,amount,percentage,budget);

@override
String toString() {
  return 'CategorySpend(categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, amount: $amount, percentage: $percentage, budget: $budget)';
}


}

/// @nodoc
abstract mixin class _$CategorySpendCopyWith<$Res> implements $CategorySpendCopyWith<$Res> {
  factory _$CategorySpendCopyWith(_CategorySpend value, $Res Function(_CategorySpend) _then) = __$CategorySpendCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String categoryName, String categoryIcon, int categoryColor, double amount, double percentage, double? budget
});




}
/// @nodoc
class __$CategorySpendCopyWithImpl<$Res>
    implements _$CategorySpendCopyWith<$Res> {
  __$CategorySpendCopyWithImpl(this._self, this._then);

  final _CategorySpend _self;
  final $Res Function(_CategorySpend) _then;

/// Create a copy of CategorySpend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? categoryName = null,Object? categoryIcon = null,Object? categoryColor = null,Object? amount = null,Object? percentage = null,Object? budget = freezed,}) {
  return _then(_CategorySpend(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,categoryIcon: null == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String,categoryColor: null == categoryColor ? _self.categoryColor : categoryColor // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,budget: freezed == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$FinancialSummary {

 double get totalIncome; double get totalExpense; double get netSavings; double get savingsRate; List<FlowDataPoint> get flowData; List<CategorySpend> get categoryBreakdown;
/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<FinancialSummary> get copyWith => _$FinancialSummaryCopyWithImpl<FinancialSummary>(this as FinancialSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialSummary&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.netSavings, netSavings) || other.netSavings == netSavings)&&(identical(other.savingsRate, savingsRate) || other.savingsRate == savingsRate)&&const DeepCollectionEquality().equals(other.flowData, flowData)&&const DeepCollectionEquality().equals(other.categoryBreakdown, categoryBreakdown));
}


@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense,netSavings,savingsRate,const DeepCollectionEquality().hash(flowData),const DeepCollectionEquality().hash(categoryBreakdown));

@override
String toString() {
  return 'FinancialSummary(totalIncome: $totalIncome, totalExpense: $totalExpense, netSavings: $netSavings, savingsRate: $savingsRate, flowData: $flowData, categoryBreakdown: $categoryBreakdown)';
}


}

/// @nodoc
abstract mixin class $FinancialSummaryCopyWith<$Res>  {
  factory $FinancialSummaryCopyWith(FinancialSummary value, $Res Function(FinancialSummary) _then) = _$FinancialSummaryCopyWithImpl;
@useResult
$Res call({
 double totalIncome, double totalExpense, double netSavings, double savingsRate, List<FlowDataPoint> flowData, List<CategorySpend> categoryBreakdown
});




}
/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._self, this._then);

  final FinancialSummary _self;
  final $Res Function(FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalIncome = null,Object? totalExpense = null,Object? netSavings = null,Object? savingsRate = null,Object? flowData = null,Object? categoryBreakdown = null,}) {
  return _then(_self.copyWith(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,netSavings: null == netSavings ? _self.netSavings : netSavings // ignore: cast_nullable_to_non_nullable
as double,savingsRate: null == savingsRate ? _self.savingsRate : savingsRate // ignore: cast_nullable_to_non_nullable
as double,flowData: null == flowData ? _self.flowData : flowData // ignore: cast_nullable_to_non_nullable
as List<FlowDataPoint>,categoryBreakdown: null == categoryBreakdown ? _self.categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as List<CategorySpend>,
  ));
}

}


/// Adds pattern-matching-related methods to [FinancialSummary].
extension FinancialSummaryPatterns on FinancialSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalIncome,  double totalExpense,  double netSavings,  double savingsRate,  List<FlowDataPoint> flowData,  List<CategorySpend> categoryBreakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.totalIncome,_that.totalExpense,_that.netSavings,_that.savingsRate,_that.flowData,_that.categoryBreakdown);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalIncome,  double totalExpense,  double netSavings,  double savingsRate,  List<FlowDataPoint> flowData,  List<CategorySpend> categoryBreakdown)  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary():
return $default(_that.totalIncome,_that.totalExpense,_that.netSavings,_that.savingsRate,_that.flowData,_that.categoryBreakdown);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalIncome,  double totalExpense,  double netSavings,  double savingsRate,  List<FlowDataPoint> flowData,  List<CategorySpend> categoryBreakdown)?  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.totalIncome,_that.totalExpense,_that.netSavings,_that.savingsRate,_that.flowData,_that.categoryBreakdown);case _:
  return null;

}
}

}

/// @nodoc


class _FinancialSummary extends FinancialSummary {
  const _FinancialSummary({required this.totalIncome, required this.totalExpense, required this.netSavings, required this.savingsRate, required final  List<FlowDataPoint> flowData, required final  List<CategorySpend> categoryBreakdown}): _flowData = flowData,_categoryBreakdown = categoryBreakdown,super._();
  

@override final  double totalIncome;
@override final  double totalExpense;
@override final  double netSavings;
@override final  double savingsRate;
 final  List<FlowDataPoint> _flowData;
@override List<FlowDataPoint> get flowData {
  if (_flowData is EqualUnmodifiableListView) return _flowData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_flowData);
}

 final  List<CategorySpend> _categoryBreakdown;
@override List<CategorySpend> get categoryBreakdown {
  if (_categoryBreakdown is EqualUnmodifiableListView) return _categoryBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryBreakdown);
}


/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialSummaryCopyWith<_FinancialSummary> get copyWith => __$FinancialSummaryCopyWithImpl<_FinancialSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialSummary&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.netSavings, netSavings) || other.netSavings == netSavings)&&(identical(other.savingsRate, savingsRate) || other.savingsRate == savingsRate)&&const DeepCollectionEquality().equals(other._flowData, _flowData)&&const DeepCollectionEquality().equals(other._categoryBreakdown, _categoryBreakdown));
}


@override
int get hashCode => Object.hash(runtimeType,totalIncome,totalExpense,netSavings,savingsRate,const DeepCollectionEquality().hash(_flowData),const DeepCollectionEquality().hash(_categoryBreakdown));

@override
String toString() {
  return 'FinancialSummary(totalIncome: $totalIncome, totalExpense: $totalExpense, netSavings: $netSavings, savingsRate: $savingsRate, flowData: $flowData, categoryBreakdown: $categoryBreakdown)';
}


}

/// @nodoc
abstract mixin class _$FinancialSummaryCopyWith<$Res> implements $FinancialSummaryCopyWith<$Res> {
  factory _$FinancialSummaryCopyWith(_FinancialSummary value, $Res Function(_FinancialSummary) _then) = __$FinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalIncome, double totalExpense, double netSavings, double savingsRate, List<FlowDataPoint> flowData, List<CategorySpend> categoryBreakdown
});




}
/// @nodoc
class __$FinancialSummaryCopyWithImpl<$Res>
    implements _$FinancialSummaryCopyWith<$Res> {
  __$FinancialSummaryCopyWithImpl(this._self, this._then);

  final _FinancialSummary _self;
  final $Res Function(_FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalIncome = null,Object? totalExpense = null,Object? netSavings = null,Object? savingsRate = null,Object? flowData = null,Object? categoryBreakdown = null,}) {
  return _then(_FinancialSummary(
totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,netSavings: null == netSavings ? _self.netSavings : netSavings // ignore: cast_nullable_to_non_nullable
as double,savingsRate: null == savingsRate ? _self.savingsRate : savingsRate // ignore: cast_nullable_to_non_nullable
as double,flowData: null == flowData ? _self._flowData : flowData // ignore: cast_nullable_to_non_nullable
as List<FlowDataPoint>,categoryBreakdown: null == categoryBreakdown ? _self._categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as List<CategorySpend>,
  ));
}


}

// dart format on
