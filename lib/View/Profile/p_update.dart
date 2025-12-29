import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/loading.dart';
import '../../Controllers/profilecontroller.dart';

class EProfile extends StatelessWidget {
  final P_Controller controller = Get.find<P_Controller>();
  final ImagePicker picker = ImagePicker();

  EProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.background),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: Loading());
        }

        final profile = controller.profile.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // ================== GREEN CURVED HEADER WITH AVATAR ==================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: screenHeight * 0.15,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.05,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          final XFile? img = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img == null) return;

                          controller.selectedImage.value = img.path;
                        },
                        child: Stack(
                          children: [
                            // Avatar
                            Obx(() {
                              try {
                                if (controller.selectedImage.value != null) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: FileImage(
                                        File(controller.selectedImage.value!),
                                      ),
                                    ),
                                  );
                                }

                                if ((profile.profilePicture?.trim().isNotEmpty ??
                                    false)) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                        profile.profilePicture!.trim(),
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.error, color: Colors.white),
                                  ),
                                );
                              }
                            }),

                            // Edit Icon Overlay - centered on avatar
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.07),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================== PERSONAL DETAILS TITLE ==================
                    Center(
                      child: Text(
                        "Personal Details",
                        style: AppTextStyles.heading1.copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ================== FORM FIELDS ==================
                    _buildTextField(
                      label: "Full Name",
                      initialValue: profile.fullName ?? "",
                      onChanged: (v) =>
                          controller.profile.update((p) => p!.fullName = v),
                    ),

                    _buildDropdown<int>(
                      label: "Location",
                      value: profile.locationId == 0
                          ? null
                          : profile.locationId,
                      items: controller.locationsList
                          .map(
                            (loc) => {
                              "value": loc["id"] as int,
                              "label": loc["name"] as String,
                            },
                          )
                          .toList(),
                      onChanged: (v) {
                        controller.profile.update(
                          (p) => p!.locationId = v ?? 0,
                        );
                      },
                    ),

                    _buildDropdown<String>(
                      label: "Gender",
                      value: profile.gender,
                      items: [
                        "Male",
                        "Female",
                        "Other",
                      ].map((e) => {"value": e, "label": e}).toList(),
                      onChanged: (v) =>
                          controller.profile.update((p) => p!.gender = v),
                    ),

                    _buildTextField(
                      label: "Age",
                      initialValue: profile.age?.toString() ?? "",
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.profile.update((p) {
                        p!.age = int.tryParse(v.trim());
                      }),
                    ),

                    _buildTextField(
                      label: "Educational Qualification",
                      initialValue: profile.qualification ?? "",
                      onChanged: (v) => controller.profile.update(
                        (p) => p!.qualification = v,
                      ),
                    ),

                    _buildTextField(
                      label: "Total Experience (Years)",
                      initialValue: profile.experienceYears?.toString() ?? "",
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.profile.update((p) {
                        p!.experienceYears = int.tryParse(v) ?? 0;
                      }),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "Specialities",
                      style: AppTextStyles.heading2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildChipSelection(
                      items: controller.specializationList.map((e) {
                        return {
                          "id": e["id"] as int,
                          "label": e["name"] as String,
                        };
                      }).toList(),
                      selected: profile.specializationIds,
                      onChange: (list) {
                        controller.profile.update(
                          (p) => p!.specializationIds = List<int>.from(list),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Work Type",
                      style: AppTextStyles.heading2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildWorkTypeSelection(
                      items: controller.workTypesList.map((value) {
                        return {
                          "value": value,
                          "label": value
                              .replaceAll("_", " ")
                              .toLowerCase()
                              .capitalize!,
                        };
                      }).toList(),
                      selected: profile.workTypes,
                      onChange: (list) {
                        controller.profile.update((p) => p!.workTypes = list);
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "About Me",
                      initialValue: profile.bio ?? "",
                      maxLines: 4,
                      onChanged: (v) =>
                          controller.profile.update((p) => p!.bio = v),
                    ),

                    _buildTextField(
                      label: "Email",
                      initialValue: profile.email ?? "",
                      onChanged: (v) =>
                          controller.profile.update((p) => p!.email = v),
                    ),

                    _buildDropdown<String>(
                      label: "Availability Status",
                      value: profile.availabilityStatus,
                      items: [
                        "AVAILABLE",
                        "BUSY",
                        "ON_LEAVE",
                        "INACTIVE",
                      ].map((e) => {"value": e, "label": e}).toList(),
                      onChanged: (v) => controller.profile.update(
                        (p) => p!.availabilityStatus = v,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================== SAVE BUTTON ==================
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isUpdating.value
                              ? null
                              : () => controller.updateProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isUpdating.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: Loading(),
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================== REUSABLE EDIT FIELDS ==================
  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.heading2.copyWith(fontSize: 15)),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: initialValue)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: initialValue.length),
              ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
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
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<Map<String, dynamic>> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.heading2.copyWith(fontSize: 15)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                dropdownColor: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                items: items
                    .map(
                      (e) => DropdownMenuItem<T>(
                        value: e["value"] as T,
                        child: Text(
                          e["label"] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSelection({
    required List<Map<String, dynamic>> items,
    required List<int> selected,
    required Function(List<int>) onChange,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final id = item["id"] as int;
        final isSelected = selected.contains(id);

        return InkWell(
          onTap: () {
            final newList = List<int>.from(selected);
            if (isSelected) {
              newList.remove(id);
            } else {
              newList.add(id);
            }
            onChange(newList);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              item["label"] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkTypeSelection({
    required List<Map<String, String>> items,
    required List<String> selected,
    required Function(List<String>) onChange,
  }) {
    return Column(
      children: items.map((item) {
        final value = item["value"]!;
        final label = item["label"]!;
        final isSelected = selected.contains(value);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              final list = List<String>.from(selected);
              if (isSelected) {
                list.remove(value);
              } else {
                list.add(value);
              }
              onChange(list);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}