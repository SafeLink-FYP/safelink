import 'package:safelink/features/dashboard/models/emergency_contact_model.dart';

final List<EmergencyContactModel> predefinedEmergencyContacts = [
  EmergencyContactModel(
    id: 'ndma',
    userId: 'system',
    name: 'NDMA Helpline',
    phone: '051-9030377',
    relationship: 'National Disaster Management',
    isPrimary: false,
    createdAt: null,
  ),
  EmergencyContactModel(
    id: 'rescue_1122',
    userId: 'system',
    name: 'Rescue 1122',
    phone: '1122',
    relationship: 'Emergency Rescue Service',
    isPrimary: true,
    createdAt: null,
  ),
  EmergencyContactModel(
    id: 'edhi',
    userId: 'system',
    name: 'Edhi Ambulance',
    phone: '115',
    relationship: 'Ambulance Service',
    isPrimary: false,
    createdAt: null,
  ),
  EmergencyContactModel(
    id: 'police',
    userId: 'system',
    name: 'Police Helpline',
    phone: '15',
    relationship: 'Police Emergency',
    isPrimary: false,
    createdAt: null,
  ),
  EmergencyContactModel(
    id: 'fire',
    userId: 'system',
    name: 'Fire Brigade',
    phone: '16',
    relationship: 'Fire Emergency',
    isPrimary: false,
    createdAt: null,
  ),
];
