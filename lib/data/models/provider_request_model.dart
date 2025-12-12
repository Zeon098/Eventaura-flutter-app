class ProviderRequest {
  final String userId;
  final String businessName;
  final String description;
  final String cnicFrontUrl;
  final String cnicBackUrl;
  final String status;

  ProviderRequest({
    required this.userId,
    required this.businessName,
    required this.description,
    required this.cnicFrontUrl,
    required this.cnicBackUrl,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessName': businessName,
      'description': description,
      'cnicFrontUrl': cnicFrontUrl,
      'cnicBackUrl': cnicBackUrl,
      'status': status,
    };
  }

  factory ProviderRequest.fromMap(Map<String, dynamic> map) {
    return ProviderRequest(
      userId: map['userId'],
      businessName: map['businessName'],
      description: map['description'],
      cnicFrontUrl: map['cnicFrontUrl'],
      cnicBackUrl: map['cnicBackUrl'],
      status: map['status'] ?? 'pending',
    );
  }
}
