import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/subscription_service.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  Future<void> _handleSubscribe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SubscriptionService.subscribe();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully subscribed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                // Free Plan
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPlanCard(
                      context,
                      title: 'Free',
                      subtitle: 'US\$0.0',
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
                      subtitle: 'Flash Sale 50%',
                      price: 'US\$6.67/month',
                      annualPrice: 'US\$79.9/year',
                      isHotPick: true,
                      buttonColor: const Color(0xFFFFB800),
                      buttonTextColor: Colors.black87,
                      features: _getStarterFeatures(),
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
                2, // Changed to 2 plans
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
    String? annualPrice,
    required bool isHotPick,
    required Color buttonColor,
    required Color buttonTextColor,
    required List<PlanFeatureSection> features,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: title == 'Free'
            ? Colors.white
            : const Color(0xFFFFFBEC), // Light yellow background for Starter
        border: Border.all(
          color: title == 'Free'
              ? Colors.grey.shade200
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
                          title == 'Free'
                              ? Icons.wb_sunny_outlined
                              : FontAwesomeIcons.crown,
                          color: title == 'Starter'
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
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (annualPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          annualPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    if (title != 'Free') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubscribe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: buttonTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Subscribe',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
                      'FLASH SALE 50%',
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
      'AI Chat',
      [
        PlanFeature('Basic Models',
            subtitle: 'GPT-4o mini, Claude 3.5 Haiku, DeepSeek V3 & R1'),
        PlanFeature('50 daily accesses'),
        PlanFeature('Limited trial for image/video generation'),
        PlanFeature(
            'Basic model-driven smart writing, translation, and summary'),
        PlanFeature('Limited trial for ChatPDF'),
      ],
    ),
    PlanFeatureSection(
      'Application Integration',
      [
        PlanFeature('Gmail'),
        PlanFeature('Teams'),
        PlanFeature('Facebook'),
        PlanFeature('X (Twitter)'),
        PlanFeature('LinkedIn'),
      ],
    ),
    PlanFeatureSection(
      'Cross-platform AI assistant',
      [
        PlanFeature('Chrome'),
        PlanFeature('Windows'),
        PlanFeature('Mac'),
        PlanFeature('Android'),
        PlanFeature('VS Code'),
      ],
    ),
  ];
}

List<PlanFeatureSection> _getStarterFeatures() {
  return [
    PlanFeatureSection(
      'AI Chat',
      [
        PlanFeature('Basic Models',
            subtitle: 'GPT-4o mini, Claude 3.5 Haiku, DeepSeek V3 & R1'),
        PlanFeature('Unlimited accesses'),
        PlanFeature('Advanced Models',
            subtitle:
                'o1 & GPT-4o, Claude 3.7 Sonnet, Gemini 2.0 Pro, Llama 3.1 405B'),
        PlanFeature('Unlimited accesses'),
        PlanFeature('Web Search & Advanced Skills'),
        PlanFeature('Multi-Model Answer Comparison'),
      ],
    ),
    PlanFeatureSection(
      'AI Art',
      [
        PlanFeature('Image Generation',
            subtitle: 'DALL·E 3, Stable Diffusion, Flux'),
        PlanFeature('Video Generation', subtitle: 'Kling-powered'),
        PlanFeature('Asset Creation'),
        PlanFeature('Realtime Gen'),
        PlanFeature('Realtime Canvas'),
        PlanFeature('Intelligent Image Tools'),
      ],
    ),
    PlanFeatureSection(
      'AI-Powered Reading',
      [
        PlanFeature('ChatPDF'),
        PlanFeature('Summarize Webpages'),
        PlanFeature('Summarize Files'),
      ],
    ),
    PlanFeatureSection(
      'AI-Powered Writing',
      [
        PlanFeature('Intelligent Writing'),
        PlanFeature('Intelligent Reply'),
        PlanFeature('Grammar Check'),
        PlanFeature('Mindmap Generator'),
      ],
    ),
    PlanFeatureSection(
      'AI Translation',
      [
        PlanFeature('Text Translation'),
        PlanFeature('Webpage Translation'),
        PlanFeature('PDF Translation'),
      ],
    ),
    PlanFeatureSection(
      'Special Features',
      [
        PlanFeature('Smart Toolbar'),
        PlanFeature('PowerUP'),
        PlanFeature('Multi-Platform Extensions'),
        PlanFeature('1500 Advanced Credits'),
      ],
    ),
    PlanFeatureSection(
      'Support & Benefits',
      [
        PlanFeature('Priority Email Support'),
        PlanFeature('No Request Limit During High Traffic'),
        PlanFeature('2x Response Speed'),
        PlanFeature('5 Login Devices'),
        PlanFeature('Save 33% with annual billing'),
      ],
    ),
  ];
}
