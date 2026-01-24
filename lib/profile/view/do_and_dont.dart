import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qlickcare/profile/controller/profilecontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';

/// Point-wise Do's & Don'ts Section with Add/Remove functionality
class DosDontsListSection extends StatefulWidget {
  const DosDontsListSection({super.key});

  @override
  State<DosDontsListSection> createState() => _DosDontsListSectionState();
}

class _DosDontsListSectionState extends State<DosDontsListSection> {
  final controller = Get.find<P_Controller>();
  
  List<String> dosList = [];
  List<String> dontsList = [];
  
  final TextEditingController dosInputController = TextEditingController();
  final TextEditingController dontsInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final profile = controller.profile.value;
    
    if (profile.dos != null && profile.dos!.isNotEmpty) {
      dosList = profile.dos!
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    
    if (profile.donts != null && profile.donts!.isNotEmpty) {
      dontsList = profile.donts!
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncToProfile();
    });
  }

  void _syncToProfile() {
    final dosString = dosList.join('\n');
    final dontsString = dontsList.join('\n');
    
    if (controller.profile.value.dos != dosString || 
        controller.profile.value.donts != dontsString) {
      controller.profile.update((p) {
        p!.dos = dosString;
        p.donts = dontsString;
      });
    }
  }

  @override
  void dispose() {
    dosInputController.dispose();
    dontsInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Do's & Don'ts",
          style: AppTextStyles.heading2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),

        _buildSection(
          title: "Do's",
          icon: Icons.check_circle_outline,
          items: dosList,
          inputController: dosInputController,
          hintText: "E.g., Maintain hygiene, be polite",
          primaryColor: AppColors.primary,
          onAdd: () {
            if (dosInputController.text.trim().isNotEmpty) {
              setState(() {
                dosList.add(dosInputController.text.trim());
                dosInputController.clear();
                _syncToProfile();
              });
            }
          },
          onRemove: (index) {
            setState(() {
              dosList.removeAt(index);
              _syncToProfile();
            });
          },
        ),

        const SizedBox(height: 16),

        _buildSection(
          title: "Don'ts",
          icon: Icons.cancel_outlined,
          items: dontsList,
          inputController: dontsInputController,
          hintText: "E.g., Use phone during duty, smoke",
          primaryColor: Colors.red.shade400,
          onAdd: () {
            if (dontsInputController.text.trim().isNotEmpty) {
              setState(() {
                dontsList.add(dontsInputController.text.trim());
                dontsInputController.clear();
                _syncToProfile();
              });
            }
          },
          onRemove: (index) {
            setState(() {
              dontsList.removeAt(index);
              _syncToProfile();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required TextEditingController inputController,
    required String hintText,
    required Color primaryColor,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 15,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${items.length}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          // List
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "No points added",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...items.asMap().entries.map((entry) {
              return _buildListItem(
                entry.value,
                () => onRemove(entry.key),
                primaryColor,
              );
            }),

          const SizedBox(height: 12),

          // Input Field
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.screenBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Add Button
              Material(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, VoidCallback onRemove, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.screenBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, right: 10),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}