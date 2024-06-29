// request_processing_system

//A new Flutter project.

//Getting Started

import 'package:flutter/material.dart';

// User Model
class User {
  final String id;
  final String name;
  final String phoneNumber;

  User({required this.id, required this.name, required this.phoneNumber});
}

// Ride Request Model
class RideRequest {
  final String id;
  final User user;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime requestTime;

  RideRequest({
    required this.id,
    required this.user,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.requestTime,
  });
}

// Vehicle Model
class Vehicle {
  final String id;
  final String type;
  final String location;
  bool isAvailable;

  Vehicle({
    required this.id,
    required this.type,
    required this.location,
    this.isAvailable = true,
  });
}

// Ride Service Class
class RideService {
  List<Vehicle> _vehicles = [
    Vehicle(id: 'V1', type: 'Car', location: 'TestLocation'),
    Vehicle(id: 'V2', type: 'Van', location: 'Location2'),
    // Add more vehicles as needed
  ];
  List<RideRequest> _activeRides = [];

  List<RideRequest> getActiveRides() => _activeRides;
  List<Vehicle> getVehicles() => _vehicles;

  void requestRide(RideRequest request) {
    print('Requesting ride for user: ${request.user.name}');
    try {
      final availableVehicle = _vehicles.firstWhere(
            (v) => v.isAvailable && v.location == request.pickupLocation,
        orElse: () => throw Exception('No available vehicles at the specified pickup location'),
      );
      availableVehicle.isAvailable = false;
      _activeRides.add(request);
      print('Ride confirmed for ${request.user.name} with vehicle ${availableVehicle.id}');
    } catch (e) {
      throw Exception('No available vehicles at the specified pickup location');
    }
  }

  void completeRide(String rideId) {
    final ride = _activeRides.firstWhere((r) => r.id == rideId);
    final vehicle = _vehicles.firstWhere((v) => v.id == ride.id);
    vehicle.isAvailable = true;
    _activeRides.remove(ride);
    print('Ride completed for ride ID $rideId');
  }
}

// Dashboard Screen to Display Data and User Input Form
class DashboardScreen extends StatefulWidget {
  final RideService rideService;

  DashboardScreen({required this.rideService});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  bool _showTables = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('DashboardScreen initState');
  }

  void _submitRequest() {
    print('Submit request button pressed');
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: DateTime.now().toString(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
      );
      final request = RideRequest(
        id: DateTime.now().toString(),
        user: user,
        pickupLocation: _pickupController.text,
        dropoffLocation: _dropoffController.text,
        requestTime: DateTime.now(),
      );
      try {
        widget.rideService.requestRide(request);
        setState(() {
          _showTables = true; // Show the tables after the first ride request
          _errorMessage = null;
        });
        print('Ride request submitted successfully.');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        print('Error requesting ride: $e');
      }
    } else {
      print('Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DashboardScreen build method called');
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Service Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pickupController,
                      decoration: InputDecoration(labelText: 'Pickup Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the pickup location';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dropoffController,
                      decoration: InputDecoration(labelText: 'Dropoff Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the dropoff location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      child: Text('Request Ride'),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (_showTables) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: rideRequestsTable(),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: vehiclesTable(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget rideRequestsTable() {
    print('Building ride requests table');
    return DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Pickup')),
        DataColumn(label: Text('Dropoff')),
        DataColumn(label: Text('Request Time')),
      ],
      rows: widget.rideService.getActiveRides().map((ride) {
        return DataRow(cells: [
          DataCell(Text(ride.id)),
          DataCell(Text(ride.user.name)),
          DataCell(Text(ride.pickupLocation)),
          DataCell(Text(ride.dropoffLocation)),
          DataCell(Text(ride.requestTime.toString())),
        ]);
      }).toList(),
    );
  }

  Widget vehiclesTable() {
    print('Building vehicles table');
    return DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Location')),
        DataColumn(label: Text('Availability')),
      ],
      rows: widget.rideService.getVehicles().map((vehicle) {
        return DataRow(cells: [
          DataCell(Text(vehicle.id)),
          DataCell(Text(vehicle.type)),
          DataCell(Text(vehicle.location)),
          DataCell(Text(vehicle.isAvailable ? 'Available' : 'In Use')),
        ]);
      }).toList(),
    );
  }
}

// Main Function to Run the App
void main() {
  print('main function called');
  final rideService = RideService();
  runApp(MyApp(rideService: rideService));
}

class MyApp extends StatelessWidget {
  final RideService rideService;

  MyApp({required this.rideService});

  @override
  Widget build(BuildContext context) {
    print('MyApp build method called');
    return MaterialApp(
      title: 'Autonomous Ride Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(rideService: rideService),
    );
  }
}
