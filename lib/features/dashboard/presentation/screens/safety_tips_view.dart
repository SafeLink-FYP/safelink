import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/models/safety_guide_model.dart';

class SafetyTipsView extends StatefulWidget {
  const SafetyTipsView({super.key});

  @override
  State<SafetyTipsView> createState() => _SafetyTipsViewState();
}

class _SafetyTipsViewState extends State<SafetyTipsView> {
  String? expandedGuideId;
  String? expandedSectionKey;

  static final _guides = [
    SafetyGuideModel(
      id: 'earthquake',
      title: 'Earthquake Safety',
      icon: Icons.graphic_eq,
      gradientColors: [const Color(0xFFEF4444), const Color(0xFFF97316)],
      summary: 'Learn what to do before, during, and after an earthquake.',
      sections: [
        SafetyTipSection(
          title: 'Before an Earthquake',
          tips: [
            'Secure heavy items like bookshelves and water heaters to walls',
            'Create an emergency supply kit with water, food, and first aid',
            'Identify safe spots in each room - under sturdy tables, away from windows',
            'Practice Drop, Cover, and Hold On with your family',
            'Know how to turn off gas, water, and electricity',
          ],
        ),
        SafetyTipSection(
          title: 'During an Earthquake',
          tips: [
            'DROP to your hands and knees immediately',
            'Take COVER under a sturdy desk or table',
            'HOLD ON until the shaking stops',
            'If outdoors, move to an open area away from buildings',
            'If driving, pull over and stop. Stay inside the vehicle',
          ],
        ),
        SafetyTipSection(
          title: 'After an Earthquake',
          tips: [
            'Check yourself and others for injuries',
            'Be prepared for aftershocks',
            'Inspect your home for damage before entering',
            'Use SafeLink to report damage and request help',
            'Listen to emergency broadcasts for updates',
          ],
        ),
      ],
    ),
    SafetyGuideModel(
      id: 'flood',
      title: 'Flood Safety',
      icon: Icons.water_drop,
      gradientColors: [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
      summary: 'Essential guidance for flood preparedness and survival.',
      sections: [
        SafetyTipSection(
          title: 'Before a Flood',
          tips: [
            'Know your area\'s flood risk using SafeLink heatmap',
            'Store important documents in waterproof containers',
            'Keep emergency supplies on the highest floor',
            'Know your evacuation routes and shelter locations',
            'Install check valves in plumbing to prevent backups',
          ],
        ),
        SafetyTipSection(
          title: 'During a Flood',
          tips: [
            'Move immediately to higher ground - do not wait',
            'Never walk, swim, or drive through flood waters',
            'Just 6 inches of moving water can knock you down',
            'Stay off bridges over fast-moving water',
            'Use SafeLink SOS if you are trapped',
          ],
        ),
        SafetyTipSection(
          title: 'After a Flood',
          tips: [
            'Return home only when authorities say it is safe',
            'Avoid floodwater - it may be contaminated',
            'Clean and disinfect everything that got wet',
            'Watch for hazards like weakened structures',
            'Document damage with photos for insurance',
          ],
        ),
      ],
    ),
    SafetyGuideModel(
      id: 'storm',
      title: 'Storm & Cyclone Safety',
      icon: Icons.air,
      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
      summary: 'Protect yourself and your family during severe storms.',
      sections: [
        SafetyTipSection(
          title: 'Preparation',
          tips: [
            'Board up windows and secure outdoor objects',
            'Stock up on water, food, and batteries',
            'Charge all devices and portable power banks',
            'Know the difference between a watch and warning',
            'Identify the safest room in your home (interior, no windows)',
          ],
        ),
        SafetyTipSection(
          title: 'During the Storm',
          tips: [
            'Stay indoors and away from windows',
            'Go to the lowest floor if there is a tornado warning',
            'Unplug electronic equipment and appliances',
            'Use battery-powered radio for updates',
            'Do not go outside during the eye of the storm',
          ],
        ),
      ],
    ),
    SafetyGuideModel(
      id: 'fire',
      title: 'Fire Safety',
      icon: Icons.local_fire_department,
      gradientColors: [const Color(0xFFDC2626), const Color(0xFFF43F5E)],
      summary: 'Fire prevention and emergency evacuation procedures.',
      sections: [
        SafetyTipSection(
          title: 'Prevention',
          tips: [
            'Install smoke alarms on every level of your home',
            'Test alarms monthly and replace batteries yearly',
            'Keep flammable items away from heat sources',
            'Never leave cooking unattended',
            'Create and practice a fire escape plan',
          ],
        ),
        SafetyTipSection(
          title: 'During a Fire',
          tips: [
            'Get out immediately - do not gather belongings',
            'Crawl low under smoke to breathe cleaner air',
            'Feel doors before opening - hot door means fire',
            'Use stairs, never elevators',
            'Call emergency services once you are safe outside',
          ],
        ),
      ],
    ),
    SafetyGuideModel(
      id: 'landslide',
      title: 'Landslide Safety',
      icon: Icons.warning_amber,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEAB308)],
      summary: 'Stay safe in landslide-prone areas of Pakistan.',
      sections: [
        SafetyTipSection(
          title: 'Warning Signs',
          tips: [
            'Watch for tilting trees, poles, or fences',
            'Listen for unusual sounds like rocks falling',
            'Notice new cracks in your walls or foundation',
            'Watch for changes in water flow patterns',
            'Be alert during prolonged heavy rainfall',
          ],
        ),
        SafetyTipSection(
          title: 'During a Landslide',
          tips: [
            'Move away from the path of the landslide immediately',
            'If escape is not possible, curl into a tight ball',
            'Protect your head with your arms',
            'Stay alert after the initial slide - more may follow',
            'Use SafeLink SOS to alert rescue teams',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GradientHeader(
                gradient: AppTheme.primaryGradient,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: AppTheme.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety Tips',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                          Text(
                            'Disaster preparedness guides',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.white.withValues(alpha: 0.80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  children: _guides
                      .map((guide) => _buildGuideCard(guide, theme))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(SafetyGuideModel guide, ThemeData theme) {
    final isExpanded = expandedGuideId == guide.id;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() {
                expandedGuideId = isExpanded ? null : guide.id;
                expandedSectionKey = null;
              }),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: LinearGradient(colors: guide.gradientColors),
                      ),
                      child: Icon(
                        guide.icon,
                        color: AppTheme.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: theme.textTheme.headlineMedium,
                          ),
                          SizedBox(height: 2.h),
                          Text(guide.summary, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: EdgeInsets.all(15.r),
                child: Column(
                  children: List.generate(guide.sections.length, (sIdx) {
                    final section = guide.sections[sIdx];
                    final sectionKey = '${guide.id}-$sIdx';
                    final isSectionOpen = expandedSectionKey == sectionKey;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() {
                              expandedSectionKey = isSectionOpen
                                  ? null
                                  : sectionKey;
                            }),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24.w,
                                    height: 24.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.r),
                                      gradient: LinearGradient(
                                        colors: guide.gradientColors,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${sIdx + 1}',
                                        style: TextStyle(
                                          color: AppTheme.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      section.title,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ),
                                  Icon(
                                    isSectionOpen
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isSectionOpen)
                            Padding(
                              padding: EdgeInsets.only(left: 34.w),
                              child: Column(
                                children: section.tips.map((tip) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppTheme.primaryColor,
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            tip,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
