import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:mess/Screens/ExpenseCategoryScreen/Service/ExpenseCategoryController.dart';
import 'package:mess/Screens/ExpenseScreen/Service/ExpenseController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class AddExpenseScreen extends StatefulWidget {
  final bool isEdit;
  final String? expenseId;
  final String? categoryId;
  final String? title;
  final String? amount;
  final String? paidAmount;
  final String? date;
  final String? description;
  final String? receiptUrl;
  final String? status;
  final String? paymentMethod;

  const AddExpenseScreen({
    super.key,
    this.isEdit = false,
    this.expenseId,
    this.categoryId,
    this.title,
    this.amount,
    this.paidAmount,
    this.date,
    this.description,
    this.receiptUrl,
    this.status,
    this.paymentMethod,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ExpenseController controller = Get.put(ExpenseController());
  final ExpenseCategoryController categoryController = Get.put(
    ExpenseCategoryController(),
  );

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController paidAmountCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController paymentMethodCtrl = TextEditingController();

  String? selectedCategoryId;
  DateTime selectedDate = DateTime.now();
  String? receiptUrl;
  File? receiptFile;

  /// Only settable on create — logs a placeholder with no amount yet.
  /// Status is otherwise always computed server-side from amount vs
  /// paidAmount and can never be set directly.
  bool isPending = false;

  @override
  void initState() {
    super.initState();
    categoryController.fetchCategories();

    titleCtrl.text = widget.title ?? '';
    amountCtrl.text = widget.amount ?? '';
    paidAmountCtrl.text = widget.paidAmount ?? '';
    descCtrl.text = widget.description ?? '';
    paymentMethodCtrl.text = widget.paymentMethod ?? '';
    selectedCategoryId = widget.categoryId;
    receiptUrl = widget.receiptUrl;
    isPending = !widget.isEdit && widget.status == "PENDING";

    if (widget.date != null && widget.date!.isNotEmpty) {
      selectedDate = DateTime.tryParse(widget.date!) ?? DateTime.now();
    }
  }

  /// Live preview of what status the backend will compute from the
  /// current amount/paidAmount inputs.
  String get _previewStatus {
    if (isPending) return "PENDING";
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    final paid = double.tryParse(paidAmountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return "—";
    if (paid <= 0) return "UNPAID";
    if (paid >= amount) return "PAID";
    return "PARTIALLY_PAID";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickReceipt() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => receiptFile = File(picked.path));

    final uploadedUrl = await controller.uploadReceipt(receiptFile!);
    if (uploadedUrl != null) {
      setState(() => receiptUrl = uploadedUrl);
    }
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF111827)),
            title: Text(
              widget.isEdit ? "Edit Expense" : "Add Expense",
              style: TextStyle(
                color: const Color(0xFF111827),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              child: SizedBox(
                height: 45.h,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading
                          ? null
                          : () async {
                            if (titleCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(msg: "Please enter a title");
                              return;
                            }

                            final amountText = amountCtrl.text.trim();
                            double? amount;
                            if (amountText.isNotEmpty) {
                              amount = double.tryParse(amountText);
                              if (amount == null || amount <= 0) {
                                Fluttertoast.showToast(
                                  msg: "Please enter a valid amount",
                                );
                                return;
                              }
                            } else if (!isPending) {
                              Fluttertoast.showToast(
                                msg: "Please enter a valid amount",
                              );
                              return;
                            }

                            final paidAmountText = paidAmountCtrl.text.trim();
                            double? paidAmount;
                            if (!isPending && paidAmountText.isNotEmpty) {
                              paidAmount = double.tryParse(paidAmountText);
                              if (paidAmount == null || paidAmount < 0) {
                                Fluttertoast.showToast(
                                  msg: "Please enter a valid paid amount",
                                );
                                return;
                              }
                              if (amount != null && paidAmount > amount) {
                                Fluttertoast.showToast(
                                  msg: "Paid amount can't exceed the total amount",
                                );
                                return;
                              }
                            }

                            if (selectedCategoryId == null ||
                                selectedCategoryId!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please select a category",
                              );
                              return;
                            }

                            final success = await controller.saveExpense(
                              id: widget.isEdit ? widget.expenseId : null,
                              categoryId: selectedCategoryId!,
                              title: titleCtrl.text.trim(),
                              amount: amount,
                              paidAmount: paidAmount,
                              date: DateFormat('yyyy-MM-dd').format(selectedDate),
                              isPending: isPending,
                              description: descCtrl.text.trim(),
                              receiptUrl: receiptUrl,
                              paymentMethod: paymentMethodCtrl.text.trim(),
                            );

                            if (success) Get.back();
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child:
                      controller.isLoading
                          ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            widget.isEdit ? "Update Expense" : "Save Expense",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Title *"),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: titleCtrl,
                          decoration: _fieldDecoration("Vegetable Purchase"),
                        ),

                        if (!widget.isEdit) ...[
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: () => setState(() => isPending = !isPending),
                            child: Row(
                              children: [
                                Icon(
                                  isPending
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    "Log as a pending placeholder (fill in the amount later)",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 16.h),
                        _label(isPending ? "Amount (₹)" : "Amount (₹) *"),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: amountCtrl,
                          onChanged: (_) => setState(() {}),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _fieldDecoration(
                            isPending ? "Optional — fill in later" : "1500",
                          ),
                        ),

                        if (!isPending) ...[
                          SizedBox(height: 16.h),
                          _label("Paid Amount (₹)"),
                          SizedBox(height: 10.h),
                          TextField(
                            controller: paidAmountCtrl,
                            onChanged: (_) => setState(() {}),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _fieldDecoration(
                              "0 = Unpaid, full amount = Paid",
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Status will be: $_previewStatus",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],

                        SizedBox(height: 16.h),
                        _label("Payment Method"),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: paymentMethodCtrl,
                          decoration: _fieldDecoration("CASH, UPI, CARD..."),
                        ),
                        SizedBox(height: 16.h),
                        _label("Date *"),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  DateFormat('dd MMM yyyy').format(selectedDate),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _label("Description"),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: descCtrl,
                          maxLines: 3,
                          decoration: _fieldDecoration("Optional notes"),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _sectionCard(
                    child: GetBuilder<ExpenseCategoryController>(
                      builder: (categoryCtrl) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Category *"),
                            SizedBox(height: 12.h),
                            if (categoryCtrl.categories.isEmpty)
                              Text(
                                "No categories yet — add one first",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children:
                                    categoryCtrl.categories.map((category) {
                                      final isSelected =
                                          selectedCategoryId == category.id;
                                      return GestureDetector(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  selectedCategoryId =
                                                      category.id,
                                            ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? AppColors.primary
                                                        .withOpacity(0.1)
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? AppColors.primary
                                                      : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  isSelected
                                                      ? AppColors.primary
                                                      : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Receipt"),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: controller.isUploadingReceipt ? null : _pickReceipt,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child:
                                controller.isUploadingReceipt
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : (receiptFile != null ||
                                        (receiptUrl ?? '').isNotEmpty)
                                    ? Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            "Receipt attached",
                                            style: TextStyle(fontSize: 13.sp),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:
                                              () => setState(() {
                                                receiptFile = null;
                                                receiptUrl = null;
                                              }),
                                          child: Icon(
                                            Icons.close,
                                            size: 16.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 18.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Upload receipt photo",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
