import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:mess/Screens/ExpenseCategoryScreen/ExpenseCategoryScreen.dart';
import 'package:mess/Screens/ExpenseScreen/Models/ExpenseModel.dart';
import 'package:mess/Screens/ExpenseScreen/Service/ExpenseController.dart';
import 'package:mess/Screens/ExpenseScreen/Views/AddExpenseScreen.dart';
import 'package:mess/Screens/ExpenseScreen/Views/ExpenseCard.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/TitleText.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.put(ExpenseController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshExpenses();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GetBuilder<ExpenseController>(
            builder: (ctrl) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- HEADER ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TittleText(text: "Expenses"),
                      Row(
                        children: [
                          _headerButton(
                            label: "Add Category",
                            onTap: () async {
                              await Get.to(() => const ExpenseCategoryScreen());
                            },
                          ),
                          SizedBox(width: 8.w),
                          _headerButton(
                            label: "Add Expense",
                            onTap: () async {
                              await Get.to(() => const AddExpenseScreen());
                              controller.refreshExpenses();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- SUMMARY ----------
                  _buildSummary(ctrl),

                  SizedBox(height: 16.h),

                  /// ---------- SEARCH ----------
                  TextField(
                    onChanged: (value) => ctrl.updateSearch(value),
                    decoration: InputDecoration(
                      hintText: "Search expenses...",
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.search, size: 20.sp),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey, width: 1.5.w),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- LIST ----------
                  Expanded(child: _buildExpenseList(context, ctrl)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _headerButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.add, size: 14.sp, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.r)),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSummary(ExpenseController controller) {
    final total = controller.listSummary.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                label: "Total Spend",
                value: "₹${total.amount.toStringAsFixed(0)}",
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _statCard(label: "Expenses", value: "${total.count}"),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        /// ---------- STATUS TABS ----------
        Row(
          children: [
            Expanded(
              child: _statusChip(
                controller,
                label: "All",
                filter: null,
                amount: controller.listSummary.total.amount,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _statusChip(
                controller,
                label: "Pending",
                filter: ExpenseStatusFilter.pending,
                amount: controller.listSummary.pending.amount,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _statusChip(
                controller,
                label: "Unpaid",
                filter: ExpenseStatusFilter.unpaid,
                amount: controller.listSummary.unpaid.amount,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _statusChip(
                controller,
                label: "Partial",
                filter: ExpenseStatusFilter.partiallyPaid,
                amount: controller.listSummary.partiallyPaid.amount,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _statusChip(
                controller,
                label: "Paid",
                filter: ExpenseStatusFilter.paid,
                amount: controller.listSummary.paid.amount,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(
    ExpenseController controller, {
    required String label,
    required ExpenseStatusFilter? filter,
    required double amount,
  }) {
    final isSelected = controller.statusFilter == filter;

    return GestureDetector(
      onTap: () => controller.setStatusFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "₹${amount.toStringAsFixed(0)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, ExpenseController controller) {
    if (controller.isLoading && controller.expenses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Text(controller.errorMessage, style: TextStyle(fontSize: 14.sp)),
      );
    }

    final expenses = controller.filteredExpenses;

    if (expenses.isEmpty) {
      return Center(
        child: Text("No matching expenses", style: TextStyle(fontSize: 14.sp)),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshExpenses,
      child: ListView.separated(
        itemCount: expenses.length,
        separatorBuilder: (_, __) => SizedBox(height: 0.h),
        itemBuilder: (context, index) {
          final expense = expenses[index];

          return ExpenseCard(
            title: expense.title,
            amount: expense.amount,
            balanceDue: expense.balanceDue,
            date: expense.date,
            categoryName: expense.categoryName,
            hasReceipt: (expense.receiptUrl ?? '').isNotEmpty,
            status: expense.status,
            isFullyPaid: expense.isFullyPaid,
            onDelete: () => _showDeleteDialog(context, controller, expense.id),
            onRecordPayment:
                () => _showRecordPaymentDialog(context, controller, expense),
            onEdit: () {
              Get.to(
                () => AddExpenseScreen(
                  isEdit: true,
                  expenseId: expense.id,
                  categoryId: expense.categoryId,
                  title: expense.title,
                  amount: expense.amount.toString(),
                  paidAmount: expense.paidAmount.toString(),
                  date: expense.date,
                  description: expense.description,
                  receiptUrl: expense.receiptUrl,
                  status: expense.status,
                  paymentMethod: expense.paymentMethod,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  ExpenseController controller,
  String expenseId,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color.fromARGB(255, 240, 162, 156),
                size: 45.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                "Delete Expense?",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to delete this expense?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await controller.deleteExpense(expenseId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showRecordPaymentDialog(
  BuildContext context,
  ExpenseController controller,
  ExpenseModel expense,
) {
  final paidAmountCtrl = TextEditingController(
    text: expense.balanceDue > 0 ? expense.balanceDue.toStringAsFixed(0) : '',
  );

  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Record Payment",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                "${expense.title} — total ₹${expense.amount.toStringAsFixed(0)}, "
                "already paid ₹${expense.paidAmount.toStringAsFixed(0)}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                "Total paid to date (₹)",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: paidAmountCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "e.g. ${expense.amount.toStringAsFixed(0)}",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final paidAmount = double.tryParse(
                          paidAmountCtrl.text.trim(),
                        );
                        if (paidAmount == null || paidAmount < 0) {
                          Fluttertoast.showToast(
                            msg: "Please enter a valid amount",
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        await controller.recordPayment(
                          id: expense.id,
                          paidAmount: paidAmount,
                          amount: expense.amount <= 0 ? paidAmount : null,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
