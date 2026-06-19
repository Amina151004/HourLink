class Meeting {
  final String title;
  final String time;
  final String? platform;
  final bool showBadge;

  const Meeting({
    required this.title,
    required this.time,
    this.platform,
    this.showBadge = false,
  });
}
