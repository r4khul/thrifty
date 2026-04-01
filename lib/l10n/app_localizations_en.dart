// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thrifty';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String habitCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString habits',
      one: '1 habit',
      zero: 'No habits',
    );
    return '$_temp0';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String transactionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: 'No transactions',
    );
    return '$_temp0';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get categories => 'Categories';

  @override
  String get syncData => 'Sync Data';

  @override
  String get analytics => 'Analytics';

  @override
  String get signOut => 'Sign Out';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToManage => 'Sign in to manage your wealth.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get securityPIN => 'Security PIN';

  @override
  String get pinHint => 'Enter your 4-digit PIN';

  @override
  String get pinRequired => 'PIN is required';

  @override
  String get pinLengthError => 'PIN must be exactly 4 digits';

  @override
  String get rememberMe => 'Remember me on this device';

  @override
  String get signIn => 'Sign In';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String get save => 'Save';

  @override
  String get customizeExperience => 'Customize your experience';

  @override
  String get displayName => 'Display Name';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get yearlySavingsGoal => 'Yearly Savings Goal';

  @override
  String get savingsGoalDescription =>
      'Set a target for your annual savings. We\'ll help you track your progress in the menu.';

  @override
  String get viewFinancialOverview => 'View Financial Overview';

  @override
  String get addCategory => 'Add Category';

  @override
  String get newCategory => 'New Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get deleteCategoryConfirmTitle => 'Delete Category?';

  @override
  String get deleteCategoryConfirmMessage =>
      'This will permanently remove the category.';

  @override
  String get categoryInUse => 'Category in Use';

  @override
  String get hasTransactionsSuffix => 'has existing transactions.';

  @override
  String get optionMoveTransactions => 'Option 1: Move Transactions';

  @override
  String get moveTransactionsDescription =>
      'Reassign all transactions to another category before deleting this one.';

  @override
  String get selectNewCategory => 'Select New Category';

  @override
  String get moveAndDelete => 'Move & Delete';

  @override
  String get optionDeleteEverything => 'Option 2: Delete Everything';

  @override
  String get deleteEverythingDescription =>
      'This will permanently delete this category AND all transactions associated with it. This action cannot be undone.';

  @override
  String get deleteCategoryAndTransactions => 'Delete Category & Transactions';

  @override
  String get areYouSure => 'Are you absolutely sure?';

  @override
  String get allRecordsWillBeLost =>
      'All records associated with this category will be lost forever.';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get categoryName => 'Category Name';

  @override
  String get icon => 'Icon';

  @override
  String get color => 'Color';

  @override
  String get createCategory => 'Create Category';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get required => 'Required';

  @override
  String get noTransactionsAnalyze => 'No transactions to analyze';

  @override
  String get financialOverview => 'Financial Overview';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get allTime => 'All Time';

  @override
  String get customRange => 'Custom Range';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edited => 'EDITED';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get version => 'Version';

  @override
  String get backendUrl => 'Backend URL';

  @override
  String get configureBackendUrl => 'Configure Backend URL';

  @override
  String get dailyReminder => 'Daily Reminder (8 PM)';

  @override
  String get notifyTransactionsLogged => 'Notify if no transactions logged';

  @override
  String get general => 'General';

  @override
  String get network => 'Network';

  @override
  String get about => 'About';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get descriptionHint => 'Add a description...';

  @override
  String get attachments => 'Attachments';

  @override
  String get add => 'Add';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get errorLoadingCategories => 'Error loading categories';

  @override
  String get couldNotOpenFile => 'Could not open file';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirmTitle => 'Delete Transaction?';

  @override
  String get deleteTransactionConfirmMessage =>
      'This action cannot be undone. Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get failedLoadCategories => 'Failed to load categories';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get savingsTarget => 'Savings Target';

  @override
  String get surplus => 'Surplus';

  @override
  String get goal => 'Goal';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get user => 'User';

  @override
  String get noTransactionsYet => 'No Transactions Yet';

  @override
  String get startTrackingDescription =>
      'Start tracking your expenses and see where your money goes.';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get moneyFlow => 'Money Flow';

  @override
  String get scrollable => 'Scrollable';

  @override
  String get whereYourMoneyGoes => 'Where Your Money Goes';

  @override
  String get analyzingFinances => 'Analyzing your finances...';

  @override
  String get couldNotLoadAnalytics => 'Could not load analytics';

  @override
  String get netSavings => 'Net Savings';

  @override
  String get netDeficit => 'Net Deficit';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get net => 'Net';

  @override
  String savingsRateMsg(Object rate) {
    return 'You\'re saving $rate% of income';
  }

  @override
  String get spendingExceedsIncome => 'Spending exceeds income';

  @override
  String get details => 'Details';

  @override
  String get status => 'Status';

  @override
  String get completed => 'Completed';

  @override
  String get time => 'Time';

  @override
  String get note => 'Note';

  @override
  String get transactionNotFound => 'Transaction Not Found';

  @override
  String get movedOrDeleted => 'It may have been deleted or moved.';

  @override
  String get goBack => 'Go Back';

  @override
  String get notificationTitle => 'Daily Check-in 📝';

  @override
  String get notificationBody =>
      'Don\'t forget to track your income or expenses today!';

  @override
  String get noCategoriesFound => 'No categories found';
}
