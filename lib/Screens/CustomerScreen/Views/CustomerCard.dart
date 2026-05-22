// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
// import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
// import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
// import 'package:mess/Screens/CustomerScreen/Views/CustomerDetailScreen.dart';
// class CustomerCard extends StatelessWidget {
//   final CustomerModel customer;

//   const CustomerCard({
//     super.key,
//     required this.customer,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<CustomerController>();

//     final plan = customer.activeSubscriptions.isNotEmpty
//         ? customer.activeSubscriptions.first.plan.name
//         : "No Plan";

//     final startDate = customer.activeSubscriptions.isNotEmpty
//         ? customer.activeSubscriptions.first.startDate
//         : null;

//     final endDate = customer.activeSubscriptions.isNotEmpty
//         ? customer.activeSubscriptions.first.endDate
//         : null;

//     return InkWell(
//       borderRadius: BorderRadius.circular(14.r),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CustomerDetailScreen(customer: customer),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 14.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14.r),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             )
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             /// 🔷 HEADER
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// Avatar
//                 CircleAvatar(
//                   radius: 20.r,
//                   backgroundColor: const Color(0xFFF3F3F3),
//                   child: Text(
//                     customer.name.isNotEmpty
//                         ? customer.name[0].toUpperCase()
//                         : "C",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                 ),

//                 SizedBox(width: 10.w),

//                 /// Name + Contact
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         customer.name,
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         customer.phone,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         customer.email,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 /// Actions
//                 Row(
//                   children: [
//                     _iconBtn(
//                       icon: Icons.edit_outlined,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => AddCustomerScreen(
//                               customer: customer,
//                               isEdit: true,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     _iconBtn(
//                       icon: Icons.delete_outline,
//                       color: Colors.red,
//                       onTap: () {
//                         _showDeleteDialog(context, controller, customer);
//                       },
//                     ),
//                     _iconBtn(
//                       icon: Icons.chevron_right,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 CustomerDetailScreen(customer: customer),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             SizedBox(height: 14.h),

//             Divider(color: Colors.grey.shade200),

//             SizedBox(height: 12.h),

//             /// 🔷 INFO GRID
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: "Wallet",
//                     value:
//                         "₹${customer.walletBalance.toStringAsFixed(0)}",
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: "Plan",
//                     value: plan,
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 12.h),

//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoItem(
//                     title: "Start Date",
//                     value: startDate != null
//                         ? "${startDate.day}/${startDate.month}/${startDate.year}"
//                         : "-",
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoItem(
//                     title: "End Date",
//                     value: endDate != null
//                         ? "${endDate.day}/${endDate.month}/${endDate.year}"
//                         : "-",
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔘 Reusable icon button
//   Widget _iconBtn({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color color = Colors.black,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.r),
//       child: Padding(
//         padding: EdgeInsets.all(6.w),
//         child: Icon(icon, size: 20, color: color),
//       ),
//     );
//   }

//   void _showDeleteDialog(
//     BuildContext context,
//     CustomerController controller,
//     CustomerModel customer,
//   ) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.warning_amber_rounded,
//                   color: Colors.redAccent, size: 40.sp),
//               SizedBox(height: 10.h),
//               Text(
//                 "Delete Customer?",
//                 style: TextStyle(
//                     fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 6.h),
//               Text(
//                 "This action cannot be undone.",
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//               SizedBox(height: 18.h),

//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(ctx),
//                       child: const Text("Cancel"),
//                     ),
//                   ),
//                   SizedBox(width: 10.w),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         Navigator.pop(ctx);
//                         await controller.deleteCustomer(customer.id);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                       ),
//                       child: const Text("Delete"),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//   void _showDeleteDialog(
//   BuildContext context,
//   CustomerController controller,
//   CustomerModel customer,
// ) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext ctx) {
//       return Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.warning_amber_rounded,
//                 color: const Color.fromARGB(255, 240, 162, 156),
//                 size: 45.sp,
//               ),

//               SizedBox(height: 12.h),

//               Text(
//                 "Delete Customer?",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 18.sp,
//                 ),
//               ),

//               SizedBox(height: 8.h),

//               Text(
//                 "Are you sure you want to delete ${customer.name}?\nThis action cannot be undone.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14.sp,
//                 ),
//               ),

//               SizedBox(height: 20.h),

//               Row(
//                 children: [
//                   /// Cancel
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(ctx);
//                       },
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         side: BorderSide(color: Colors.grey.shade300),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12.h),
//                       ),
//                       child: Text(
//                         "Cancel",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: 10.w),

//                   /// Delete
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         Navigator.pop(ctx); // close dialog first
//                         await controller.deleteCustomer(customer.id);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12.h),
//                       ),
//                       child: Text(
//                         "Delete",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }


// class _InfoItem extends StatelessWidget {
//   final String title;
//   final String value;
//   const _InfoItem({required this.title, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 2.h),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }
