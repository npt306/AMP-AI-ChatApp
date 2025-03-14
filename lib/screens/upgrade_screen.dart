import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upgrade',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Basic Plan
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPlanCard(
                      context,
                      title: 'Basic',
                      subtitle: 'Free',
                      isHotPick: false,
                      buttonColor: Colors.grey.shade200,
                      buttonTextColor: Colors.black87,
                      features: _getBasicFeatures(),
                    ),
                  ),
                ),

                // Starter Plan
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPlanCard(
                      context,
                      title: 'Starter',
                      subtitle: '1-month Free Trial',
                      price: '\$9.99/month',
                      isHotPick: false,
                      buttonColor: const Color(0xFF0078D4),
                      buttonTextColor: Colors.white,
                      features: _getStarterFeatures(),
                    ),
                  ),
                ),

                // Pro Plan
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPlanCard(
                      context,
                      title: 'Pro Annually',
                      subtitle: '1-month Free Trial',
                      price: '\$79.99/year',
                      isHotPick: true,
                      buttonColor: const Color(0xFFFFB800),
                      buttonTextColor: Colors.black87,
                      features: _getProFeatures(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Page indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF0078D4)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? price,
    required bool isHotPick,
    required Color buttonColor,
    required Color buttonTextColor,
    required List<PlanFeatureSection> features,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: title == 'Basic' 
            ? Colors.white
            : title == 'Starter'
                ? const Color(0xFFEDF6FF) // Light blue background
                : const Color(0xFFFFFBEC), // Light yellow background
        border: Border.all(
          color: title == 'Basic'
              ? Colors.grey.shade200
              : title == 'Starter'
                  ? const Color(0xFF0078D4).withOpacity(0.3)
                  : const Color(0xFFFFB800).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          title == 'Basic'
                              ? Icons.wb_sunny_outlined
                              : title == 'Starter'
                                  ? Icons.all_inclusive
                                  : FontAwesomeIcons.crown,
                          color: title == 'Pro Annually'
                              ? const Color(0xFFFFB800)
                              : const Color(0xFF0078D4),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (price != null) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Then',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (title == 'Pro Annually') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0078D4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.card_giftcard_outlined,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'SAVE 33% ON ANNUAL PLAN!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: buttonTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign up to subscribe',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Features sections
              ...features.map((section) => _buildFeatureSection(section)),
            ],
          ),
          if (isHotPick)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'HOT PICK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(PlanFeatureSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...section.features.map((feature) => _buildFeatureItem(feature)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeatureItem(PlanFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                if (feature.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    feature.subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanFeature {
  final String title;
  final String? subtitle;

  PlanFeature(this.title, {this.subtitle});
}

class PlanFeatureSection {
  final String title;
  final List<PlanFeature> features;

  PlanFeatureSection(this.title, this.features);
}

// Feature lists for each plan
List<PlanFeatureSection> _getBasicFeatures() {
  return [
    PlanFeatureSection(
      'Basic features',
      [
        PlanFeature('AI Chat Model', subtitle: 'GPT-3.5'),
        PlanFeature('AI Action Injection'),
        PlanFeature('Select Text for AI Action'),
      ],
    ),
    PlanFeatureSection(
      'Limited queries per day',
      [
        PlanFeature('50 free queries per day'),
      ],
    ),
    PlanFeatureSection(
      'Advanced features',
      [
        PlanFeature('AI Reading Assistant'),
        PlanFeature('Real-time Web Access'),
        PlanFeature('AI Writing Assistant'),
        PlanFeature('AI Pro Search'),
      ],
    ),
    PlanFeatureSection(
      'Other benefits',
      [
        PlanFeature('Lower response speed during high traffic'),
      ],
    ),
  ];
}

List<PlanFeatureSection> _getStarterFeatures() {
  return [
    PlanFeatureSection(
      'Basic features',
      [
        PlanFeature('AI Chat Models',
            subtitle: 'GPT-3.5 & GPT-4.0/Turbo & Gemini Pro & Gemini Ultra'),
        PlanFeature('AI Action Injection'),
        PlanFeature('Select Text for AI Action'),
      ],
    ),
    PlanFeatureSection(
      'More queries per month',
      [
        PlanFeature('Unlimited queries per month'),
      ],
    ),
    PlanFeatureSection(
      'Advanced features',
      [
        PlanFeature('AI Reading Assistant'),
        PlanFeature('Real-time Web Access'),
        PlanFeature('AI Writing Assistant'),
        PlanFeature('AI Pro Search'),
        PlanFeature('Jira Copilot Assistant'),
        PlanFeature('Github Copilot Assistant'),
        PlanFeature('Maximize productivity with unlimited* queries.'),
      ],
    ),
    PlanFeatureSection(
      'Other benefits',
      [
        PlanFeature('No request limits during high traffic'),
        PlanFeature('2X faster response speed'),
        PlanFeature('Priority email support'),
      ],
    ),
  ];
}

List<PlanFeatureSection> _getProFeatures() {
  return [
    PlanFeatureSection(
      'Basic features',
      [
        PlanFeature('AI Chat Models',
            subtitle: 'GPT-3.5 & GPT-4.0/Turbo & Gemini Pro & Gemini Ultra'),
        PlanFeature('AI Action Injection'),
        PlanFeature('Select Text for AI Action'),
      ],
    ),
    PlanFeatureSection(
      'More queries per year',
      [
        PlanFeature('Unlimited queries per year'),
      ],
    ),
    PlanFeatureSection(
      'Advanced features',
      [
        PlanFeature('AI Reading Assistant'),
        PlanFeature('Real-time Web Access'),
        PlanFeature('AI Writing Assistant'),
        PlanFeature('AI Pro Search'),
        PlanFeature('Jira Copilot Assistant'),
        PlanFeature('Github Copilot Assistant'),
        PlanFeature('Maximize productivity with unlimited* queries.'),
      ],
    ),
    PlanFeatureSection(
      'Other benefits',
      [
        PlanFeature('No request limits during high traffic'),
        PlanFeature('2X faster response speed'),
        PlanFeature('Priority email support'),
      ],
    ),
  ];
}
