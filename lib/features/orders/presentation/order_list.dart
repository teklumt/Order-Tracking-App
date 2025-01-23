import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paamy_order_tracker/components/my_button.dart';
import 'package:paamy_order_tracker/components/order_tile.dart';
import 'package:paamy_order_tracker/components/my_textField.dart';
import 'package:paamy_order_tracker/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:paamy_order_tracker/features/home/presentation/components/about_project.dart';
import 'package:paamy_order_tracker/features/orders/presentation/controller/cafe_data_controller.dart';

class OrderListScreen extends StatelessWidget {
  OrderListScreen({super.key});

  final orderNumberController = TextEditingController();
  final AuthController authController = Get.find();
  final CafeDataController cafeDataController = Get.find<CafeDataController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;
    if (user != null) {
      // Fetch orders for the logged-in cafe
      cafeDataController.fetchOrders(user.email!);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade100,

          elevation: 4, // Subtle shadow for depth
          actions: [
            IconButton(
                onPressed: () async {
                  await authController.logout();
                },
                icon: const Icon(Icons.logout))
          ],
          title: Obx(() {
            final user = authController.currentUser.value;
            if (user == null) {
              return const Text(
                "Loading...",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Colors.white,
                ),
              );
            }
            return Text(
              "Welcome, ${user.email}",
              // style: const TextStyle(
              //   fontWeight: FontWeight.bold,
              //   fontSize: 22,
              // ),
              style: GoogleFonts.lexend(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
          centerTitle: true, // Center align the title
        ),
        backgroundColor: Colors.white,
        drawer: const AboutProject(),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search and Logout UI
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC8E6C9), Colors.white],
                    begin: AlignmentDirectional.topCenter,
                    end: AlignmentDirectional.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Search Order",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: orderNumberController,
                            labelText: "Order Number",
                            hintText: "65",
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyButton(
                            onTap: () {
                              final query = orderNumberController.text.trim();
                              cafeDataController.searchOrders(query);
                            },
                            label: "Search"),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Pending Orders",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Orders List
              Expanded(
                child: Obx(() {
                  final orders = cafeDataController.filteredOrders;
                  final isLoading = cafeDataController
                      .isLoading.value; // Assuming `isLoading` is available
                  if (isLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(), // Show loading indicator
                    );
                  } else if (orders.isEmpty) {
                    return const Center(
                      child: Text("No orders found."),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: OrderTile(
                          orderNum: order["orderNumber"] is double
                              ? order["orderNumber"] as double
                              : double.tryParse(
                                      order["orderNumber"].toString()) ??
                                  0.0,
                          tableNum: order["tableNumber"] is double
                              ? order["tableNumber"] as double
                              : double.tryParse(
                                      order["tableNumber"].toString()) ??
                                  0.0,
                          onDelete: (orderNumber) {
                            cafeDataController.deleteOrder(
                                orderNumber, cafeDataController.email.value);
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
