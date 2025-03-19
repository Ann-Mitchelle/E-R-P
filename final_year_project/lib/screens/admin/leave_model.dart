class Leave {
  final int leaveId;
  final String empNo;
  final String startDate;
  final String endDate;
  final int duration;
  final String leaveType;
  final String status;

  Leave({
    required this.leaveId,
    required this.empNo,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.leaveType,
    required this.status,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      leaveId: json['leave_id'],
      empNo: json['emp_no'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      duration: json['duration'],
      leaveType: json['leave_type'],
      status: json['status'],
    );
  }
}
