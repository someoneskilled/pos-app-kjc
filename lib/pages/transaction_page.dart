// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:project_x/pages/dashboard.dart';

class TransactionPage extends StatefulWidget {
  final List<Map<String, dynamic>> inventory;

  TransactionPage({required this.inventory});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<Map<String, dynamic>> _purchaseList = [];

  String? _selectedBuyerType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  void _addVegetableToPurchase() {
    setState(() {
      _purchaseList.add({'vegetable': null, 'quantity': 0.0});
    });
  }

  double _calculateTotalPrice() {
    double totalPrice = 0.0;

    for (var purchase in _purchaseList) {
      if (purchase['vegetable'] != null) {
        double pricePerKg = double.parse(purchase['vegetable']['price']);
        double quantity = purchase['quantity'];

        totalPrice += pricePerKg * quantity;
      }
    }

    return totalPrice;
  }

  void _completeTransaction() {
    String errorMessage = '';

    for (var purchase in _purchaseList) {
      var vegetable = purchase['vegetable'];
      double quantity = purchase['quantity'];

      if (vegetable == null) {
        errorMessage = 'Please select a vegetable for each entry.';
        break;
      }

      if (quantity <= 0) {
        errorMessage = 'Please enter a valid quantity for ${vegetable['name']}.';
        break;
      }

      double availableQuantity = double.parse(vegetable['quantity']);
      if (quantity > availableQuantity) {
        errorMessage = 'Cannot buy more than available stock for ${vegetable['name']} (Available: $availableQuantity kg)';
        break;
      }
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else {
      for (var purchase in _purchaseList) {
        var vegetable = purchase['vegetable'];
        double quantity = purchase['quantity'];

        if (vegetable != null) {
          vegetable['quantity'] = (double.parse(vegetable['quantity']) - quantity).toString();
        }
      }


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Transaction Complete!"),
            content: Text("Your transaction has been completed successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Dashboard(inventory: widget.inventory),
                    ),
                  );
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Page'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Buyer Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedBuyerType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBuyerType = newValue;
                  _nameController.clear();
                  _rollNumberController.clear();
                  _companyNameController.clear();
                  _phoneNumberController.clear();
                });
              },
              items: <String>['Student', 'Faculty', 'Retailer']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (_selectedBuyerType == 'Student') ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _rollNumberController,
                decoration: InputDecoration(
                  labelText: 'Roll No.',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else if (_selectedBuyerType == 'Retailer') ...[
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone No.',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else if (_selectedBuyerType == 'Faculty') ...[
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            SizedBox(height: 20),
            Text(
              "Select Vegetables:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _purchaseList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            decoration: InputDecoration(
                              labelText: 'Vegetable',
                              border: OutlineInputBorder(),
                            ),
                            value: _purchaseList[index]['vegetable'],
                            onChanged: (Map<String, dynamic>? newValue) {
                              setState(() {
                                _purchaseList[index]['vegetable'] = newValue;
                              });
                            },
                            items: widget.inventory.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> vegetable) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: vegetable,
                                child: Text(vegetable['name']),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Quantity (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              setState(() {
                                _purchaseList[index]['quantity'] = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _purchaseList.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addVegetableToPurchase,
                child: Text(
                  'Add Vegetable',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total Price: ${_calculateTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _completeTransaction,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Complete Transaction',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
