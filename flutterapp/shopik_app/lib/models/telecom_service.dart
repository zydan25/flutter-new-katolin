import 'dart:convert';

/// Supported Telecom Operators
enum OperatorKind {
  yemenMobile,
  sabafon,
  you,
  why,
  fourG,
  yemenNet,
}

/// Operator Theme and Display Configuration
/// Colors match web (src/App.tsx OPERATORS) exactly.
class OperatorConfig {
  final OperatorKind kind;
  final String nameAr;
  final String code;
  final int primaryColorValue;
  final int secondaryColorValue;
  final String prefixHint;
  final String defaultIcon;

  /// Web-matching header bar background color (managed per operator).
  final int headerColorValue;

  /// Web-matching active tab highlight color.
  final int activeTabColorValue;

  /// Short display name used in badges (web: shortName).
  final String shortName;

  /// Short badge text shown in operator circles (web: shortName.slice(0,3)).
  final String badge;

  /// Badge text shown next to the phone input (web: shortName.slice(0,4)).
  final String badgeInput;

  /// Whether the balance tab shows a تسديد + استعلام pair (web hasInquiryInBalance).
  final bool hasInquiryInBalance;

  /// Whether recharge is expressed in units instead of amount (web sabafon hasUnits).
  final bool hasUnits;

  const OperatorConfig({
    required this.kind,
    required this.nameAr,
    required this.code,
    required this.primaryColorValue,
    required this.secondaryColorValue,
    required this.prefixHint,
    required this.defaultIcon,
    required this.headerColorValue,
    required this.activeTabColorValue,
    required this.shortName,
    required this.badge,
    required this.badgeInput,
    this.hasInquiryInBalance = false,
    this.hasUnits = false,
  });

  static const OperatorConfig yemenMobile = OperatorConfig(
    kind: OperatorKind.yemenMobile,
    nameAr: 'يمن موبايل',
    code: 'yemen_mobile',
    primaryColorValue: 0xFF8B1D3B, // Crimson/Burgundy (web headerColor)
    secondaryColorValue: 0xFFFFEBEE,
    headerColorValue: 0xFF8B1D3B,
    activeTabColorValue: 0xFF8B1D3B,
    shortName: 'يمن موبايل',
    badge: 'يمن',
    badgeInput: 'يمن',
    prefixHint: 'البادئة 77 أو 78',
    defaultIcon: 'YM',
    hasInquiryInBalance: true,
  );

  static const OperatorConfig sabafon = OperatorConfig(
    kind: OperatorKind.sabafon,
    nameAr: 'سبأفون',
    code: 'sabafon',
    primaryColorValue: 0xFF1E88E5, // Sky Blue (web headerColor)
    secondaryColorValue: 0xFFE1F5FE,
    headerColorValue: 0xFF1E88E5,
    activeTabColorValue: 0xFF1E88E5,
    shortName: 'سبأفون',
    badge: 'سبأ',
    badgeInput: 'سبأف',
    prefixHint: 'البادئة 71',
    defaultIcon: 'SABA',
    hasUnits: true,
  );

  static const OperatorConfig you = OperatorConfig(
    kind: OperatorKind.you,
    nameAr: 'يو (YOU)',
    code: 'you',
    primaryColorValue: 0xFFF59E0B, // Gold (web headerColor)
    secondaryColorValue: 0xFFFEF3C7,
    headerColorValue: 0xFFF59E0B,
    activeTabColorValue: 0xFFD97706, // Darker amber (web activeTabColor)
    shortName: 'YOU',
    badge: 'YOU',
    badgeInput: 'YOU',
    prefixHint: 'البادئة 73',
    defaultIcon: 'YOU',
  );

  static const OperatorConfig why = OperatorConfig(
    kind: OperatorKind.why,
    nameAr: 'واي (Y)',
    code: 'why',
    primaryColorValue: 0xFF8B5CF6, // Purple (web headerColor)
    secondaryColorValue: 0xFFEDE9FE,
    headerColorValue: 0xFF8B5CF6,
    activeTabColorValue: 0xFF7C3AED,
    shortName: 'واي',
    badge: 'واي',
    badgeInput: 'واي',
    prefixHint: 'البادئة 70',
    defaultIcon: 'WHY',
    hasInquiryInBalance: true,
  );

  static const OperatorConfig fourG = OperatorConfig(
    kind: OperatorKind.fourG,
    nameAr: 'يمن فورجي',
    code: 'yemen_4g',
    primaryColorValue: 0xFF0284C7, // Ocean Blue (web headerColor)
    secondaryColorValue: 0xFFCCFBF1,
    headerColorValue: 0xFF0284C7,
    activeTabColorValue: 0xFF0284C7,
    shortName: 'يمن فورجي',
    badge: '4G',
    badgeInput: '4G',
    prefixHint: 'البادئة 10',
    defaultIcon: '4G',
    hasInquiryInBalance: true,
  );

  static const OperatorConfig yemenNet = OperatorConfig(
    kind: OperatorKind.yemenNet,
    nameAr: 'الهاتف و ADSL',
    code: 'yemen_net',
    primaryColorValue: 0xFF283593, // Deep Indigo (web headerColor)
    secondaryColorValue: 0xFFFFEDD5,
    headerColorValue: 0xFF283593,
    activeTabColorValue: 0xFF283593,
    shortName: 'يمن نت',
    badge: 'يمن',
    badgeInput: 'يمن ن',
    prefixHint: 'يبدأ بـ 01..07',
    defaultIcon: 'NET',
    hasInquiryInBalance: true,
  );

  static const OperatorConfig adenNet = OperatorConfig(
    kind: OperatorKind.yemenNet,
    nameAr: 'عدن نت',
    code: 'aden_net',
    primaryColorValue: 0xFF0284C7,
    secondaryColorValue: 0xFFE0F2FE,
    headerColorValue: 0xFF0284C7,
    activeTabColorValue: 0xFF0284C7,
    shortName: 'عدن نت',
    badge: 'عدن',
    badgeInput: 'عدن ن',
    prefixHint: 'البادئة 08',
    defaultIcon: 'NET',
    hasInquiryInBalance: true,
  );

  /// All operators in the same order as the web operators row.
  static const List<OperatorConfig> all = [
    yemenMobile,
    you,
    sabafon,
    why,
    fourG,
    yemenNet,
    adenNet,
  ];

  static OperatorConfig fromPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = clean.startsWith('967')
        ? clean.substring(3)
        : clean.startsWith('00967')
            ? clean.substring(5)
            : clean;

    if (normalized.startsWith('77') || normalized.startsWith('78')) {
      return yemenMobile;
    } else if (normalized.startsWith('71')) {
      return sabafon;
    } else if (normalized.startsWith('73')) {
      return you;
    } else if (normalized.startsWith('70')) {
      return why;
    } else if (normalized.startsWith('10')) {
      return fourG;
    } else if (normalized.startsWith('08')) {
      return adenNet;
    } else if (normalized.startsWith('0')) {
      return yemenNet;
    }
    return yemenMobile;
  }
}

/// A Plan Type Category (e.g. 'دفع مسبق - شريحة + برمجة', 'مزايا', etc.)
class PlanType {
  final int id;
  final String name;
  final List<int> planIds;

  PlanType({
    required this.id,
    required this.name,
    required this.planIds,
  });

  factory PlanType.fromJson(Map<String, dynamic> json) {
    return PlanType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      planIds: (json['plan_ids'] as List<dynamic>?)
              ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plan_ids': planIds,
      };
}

/// A Package or Denomination Item
class PackageItem {
  final int id;
  final String name;
  final double price;
  final String type;
  final String externalCode;
  final Map<String, dynamic> metadata;

  PackageItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.externalCode,
    required this.metadata,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      type: json['type']?.toString() ?? '',
      externalCode: json['external_code']?.toString() ?? '',
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'type': type,
        'external_code': externalCode,
        'metadata': metadata,
      };

  String? get validityDays =>
      metadata['days']?.toString() ??
      metadata['duration']?.toString() ??
      metadata['validity']?.toString();

  String? get dataAmount =>
      metadata['data']?.toString() ??
      metadata['megabytes']?.toString() ??
      metadata['volume']?.toString() ??
      metadata['quota']?.toString();

  String? get minutes =>
      metadata['minutes']?.toString() ?? metadata['min']?.toString();

  String? get sms =>
      metadata['sms']?.toString() ?? metadata['messages']?.toString();
}

/// Active Package offer returned from Yemen Mobile inquiry
class ActiveOffer {
  final String offerId;
  final String offerName;
  final String? startDate;
  final String? endDate;

  ActiveOffer({
    required this.offerId,
    required this.offerName,
    this.startDate,
    this.endDate,
  });

  factory ActiveOffer.fromJson(Map<String, dynamic> json) {
    return ActiveOffer(
      offerId: json['offerId']?.toString() ?? '',
      offerName: json['offerName']?.toString() ?? '',
      startDate: json['offerStartDate']?.toString(),
      endDate: json['offerEndDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'offerId': offerId,
        'offerName': offerName,
        'offerStartDate': startDate,
        'offerEndDate': endDate,
      };
}

/// Result of an inquiry (Balance, Salfa, Offers, Line Type)
class InquiryResultData {
  final String type; // 'balance', 'offers', 'salfa', 'line_type', '4g', 'net'
  final bool success;
  final String? balance;
  final String? availableCredit;
  final String? mobileType;
  final String? loanAmount;
  final String? message;
  final List<ActiveOffer> offers;
  final Map<String, dynamic> rawResult;

  InquiryResultData({
    required this.type,
    required this.success,
    this.balance,
    this.availableCredit,
    this.mobileType,
    this.loanAmount,
    this.message,
    this.offers = const [],
    this.rawResult = const {},
  });

  factory InquiryResultData.fromTransaction(String type, Map<String, dynamic> tx) {
    final status = tx['status']?.toString();
    final isSuccess = status == 'success' || (tx['result'] is Map && (tx['result'] as Map).isNotEmpty);
    final result = tx['result'] is Map<String, dynamic> ? (tx['result'] as Map<String, dynamic>) : <String, dynamic>{};

    List<ActiveOffer> parsedOffers = [];
    if (result['offers'] is List) {
      parsedOffers = (result['offers'] as List)
          .map((e) => ActiveOffer.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return InquiryResultData(
      type: type,
      success: isSuccess,
      balance: result['balance']?.toString() ?? result['availableCredit']?.toString() ?? result['remainAmount']?.toString(),
      availableCredit: result['availableCredit']?.toString(),
      mobileType: result['mobileType']?.toString() == '1'
          ? 'دفع مسبق (Prepaid)'
          : result['mobileType']?.toString() == '2'
              ? 'فوترة (Postpaid)'
              : result['mobileType']?.toString(),
      loanAmount: result['loan']?.toString() ?? result['loanAmount']?.toString() ?? result['sulfa']?.toString(),
      message: result['resultDesc']?.toString() ?? tx['error_message']?.toString(),
      offers: parsedOffers,
      rawResult: result,
    );
  }
}
