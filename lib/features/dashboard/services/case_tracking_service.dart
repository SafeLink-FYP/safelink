import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/dashboard/models/case_model.dart';

class CaseTrackingService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<List<CaseModel>> getMyCases() async {
    final userId = _supabase.userId;
    if (userId == null) return [];

    final cases = <CaseModel>[];

    try {
      final sosData = await _supabase.sosRequests
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      for (final sos in sosData) {
        cases.add(_sosToCase(sos));
      }
    } catch (e) {
      Get.log('Error fetching SOS cases: $e');
    }

    try {
      final aidData = await _supabase.aidRequests
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      for (final aid in aidData) {
        cases.add(_aidToCase(aid));
      }
    } catch (e) {
      Get.log('Error fetching Aid cases: $e');
    }

    try {
      final reportData = await _supabase.disasterReports
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      for (final report in reportData) {
        cases.add(_reportToCase(report));
      }
    } catch (e) {
      Get.log('Error fetching Disaster report cases: $e');
    }

    cases.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return cases;
  }

  Future<List<Map<String, dynamic>>> getAidRequestTimeline(
    String requestId,
  ) async {
    final data = await _supabase.aidRequestTimeline
        .select()
        .eq('request_id', requestId)
        .order('created_at', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  CaseModel _sosToCase(Map<String, dynamic> sos) {
    final status = sos['status'] as String? ?? 'pending';
    return CaseModel(
      id: sos['id'] as String,
      type: _capitalize(sos['disaster_type'] as String? ?? 'Emergency'),
      source: 'sos',
      description:
          sos['description'] as String? ??
          'Emergency SOS request at ${sos['address'] ?? 'unknown location'}',
      status: status,
      priority: sos['urgency'] as String? ?? 'critical',
      location: sos['address'] as String?,
      assignedTo: sos['assigned_team_id'] != null
          ? 'Rescue Team'
          : 'Unassigned',
      createdAt: sos['created_at'] as String?,
      timeline: [
        CaseTimelineEntry(
          time: _formatDate(sos['created_at'] as String?),
          title: 'SOS Triggered',
          description: 'Emergency SOS signal sent.',
          status: 'completed',
        ),
        if (sos['responded_at'] != null)
          CaseTimelineEntry(
            time: _formatDate(sos['responded_at'] as String?),
            title: 'Response Initiated',
            description: 'Rescue team has been notified.',
            status: status == 'resolved' ? 'completed' : 'active',
          ),
        if (sos['resolved_at'] != null)
          CaseTimelineEntry(
            time: _formatDate(sos['resolved_at'] as String?),
            title: 'Resolved',
            description: 'Emergency has been resolved.',
            status: 'completed',
          ),
        if (status == 'pending')
          const CaseTimelineEntry(
            time: 'Pending',
            title: 'Awaiting Response',
            description: 'Your request is being processed.',
            status: 'active',
          ),
      ],
    );
  }

  CaseModel _aidToCase(Map<String, dynamic> aid) {
    final status = aid['status'] as String? ?? 'pending';
    return CaseModel(
      id: aid['id'] as String,
      type: _capitalize(aid['aid_type'] as String? ?? 'Aid Request'),
      source: 'aid_request',
      description:
          aid['description'] as String? ??
          '${_capitalize(aid['aid_type'] as String? ?? 'Aid')} request',
      status: status,
      priority: aid['urgency'] as String? ?? 'high',
      location: aid['address'] as String?,
      assignedTo: aid['fulfilled_by'] != null ? 'Relief Team' : 'Unassigned',
      createdAt: aid['created_at'] as String?,
      timeline: [
        CaseTimelineEntry(
          time: _formatDate(aid['created_at'] as String?),
          title: 'Request Submitted',
          description: 'Aid request has been submitted.',
          status: 'completed',
        ),
        if (status == 'in_progress' || status == 'fulfilled')
          CaseTimelineEntry(
            time: _formatDate(aid['updated_at'] as String?),
            title: 'Aid Being Prepared',
            description: 'Supplies are being assembled.',
            status: status == 'fulfilled' ? 'completed' : 'active',
          ),
        if (status == 'fulfilled')
          CaseTimelineEntry(
            time: _formatDate(aid['fulfilled_at'] as String?),
            title: 'Aid Delivered',
            description: 'Aid has been successfully delivered.',
            status: 'completed',
          ),
        if (status == 'rejected')
          CaseTimelineEntry(
            time: _formatDate(aid['updated_at'] as String?),
            title: 'Request Rejected',
            description:
                aid['rejection_reason'] as String? ??
                'This request was not approved.',
            status: 'completed',
          ),
        if (status == 'pending')
          const CaseTimelineEntry(
            time: 'Pending',
            title: 'Under Review',
            description: 'Your request is being processed.',
            status: 'active',
          ),
      ],
    );
  }

  CaseModel _reportToCase(Map<String, dynamic> report) {
    final status = report['status'] as String? ?? 'pending';
    return CaseModel(
      id: report['id'] as String,
      type:
          '${_capitalize(report['disaster_type'] as String? ?? 'Incident')} Report',
      source: 'disaster_report',
      description:
          report['description'] as String? ?? 'Disaster incident reported',
      status: status,
      priority: report['severity'] as String? ?? 'high',
      location: report['address'] as String?,
      assignedTo: 'Authorities',
      createdAt: report['created_at'] as String?,
      timeline: [
        CaseTimelineEntry(
          time: _formatDate(report['created_at'] as String?),
          title: 'Report Submitted',
          description: 'Incident report has been filed.',
          status: 'completed',
        ),
        if (status == 'verified')
          CaseTimelineEntry(
            time: _formatDate(report['verified_at'] as String?),
            title: 'Report Verified',
            description: 'Authorities have verified this incident.',
            status: 'completed',
          ),
        if (status == 'dismissed')
          CaseTimelineEntry(
            time: _formatDate(report['verified_at'] as String?),
            title: 'Report Dismissed',
            description: 'This report was reviewed and did not require action.',
            status: 'completed',
          ),
        if (status == 'pending')
          const CaseTimelineEntry(
            time: 'Pending',
            title: 'Under Review',
            description: 'Your report is being reviewed.',
            status: 'active',
          ),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Recently';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'Recently';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$min $amPm';
  }
}
