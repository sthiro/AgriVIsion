import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddVegetablePage extends StatefulWidget {
  const AddVegetablePage({super.key});

  @override
  _AddVegetablePageState createState() => _AddVegetablePageState();
}

class _AddVegetablePageState extends State<AddVegetablePage> {
  final Map<String, int> vegetableIds = {
    "Brinjal": 1,
    "Ladies Finger": 2,
    "Potato": 3,
    "Tomato": 4,
    "Cucumber": 5,
    "Spinach": 7,
  };

  List<Map<String, dynamic>> selectedVegetables = [];
  final String apiBaseUrl = "http://192.168.1.114:5000/api/farmers";

  Future<void> addVegetableToDatabase(int vegId, String area) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"veg_id": vegId, "area": area}),
      );

      if (response.statusCode == 200) {
        print("Vegetable added successfully!");
      } else {
        print("Failed to add vegetable: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void addVegetable(String veg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController areaController = TextEditingController();
        return AlertDialog(
          title: Text("Enter Area for $veg"),
          content: TextField(
            controller: areaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Area (in acres)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final area = areaController.text;
                if (area.isNotEmpty && vegetableIds.containsKey(veg)) {
                  final vegId = vegetableIds[veg]!;
                  setState(() {
                    selectedVegetables.add({"veg_id": vegId, "area": area});
                  });
                  addVegetableToDatabase(vegId, area); // Update database
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Vegetables"),
        centerTitle: true,
        backgroundColor: Colors.lightGreen, // Light Green task bar
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light grey background
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: selectedVegetables.length,
                itemBuilder: (context, index) {
                  final vegetable = selectedVegetables[index];
                  final vegName = vegetableIds.entries
                      .firstWhere((entry) => entry.value == vegetable['veg_id'])
                      .key;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$vegName - Area: ${vegetable['area']} acres",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Colors.green, Colors.lightGreen],
                                ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedVegetables.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) => ListView.builder(
                    itemCount: vegetableIds.keys.length,
                    itemBuilder: (context, index) {
                      final vegetable = vegetableIds.keys.elementAt(index);
                      return ListTile(
                        title: Text(
                          vegetable,
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          addVegetable(vegetable);
                        },
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ).copyWith(
                elevation: WidgetStateProperty.resolveWith<double>((_) => 0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const Text(
                  "Add New Vegetable",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
