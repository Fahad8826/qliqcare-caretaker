class DeleteAccountRequest {
  String confirmation;

  DeleteAccountRequest({required this.confirmation});

  Map<String, dynamic> toJson() => {"confirmation": confirmation};
}
